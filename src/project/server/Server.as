package project.server 
{
	import project.common.Gateway;
	
	public class Server
	{		
		public var gateway:Gateway;
		public var ip:String;
		
		//ServerUser
		public var userList:Array = new Array();
		
		public function Server() 
		{
			
		}
		
		public function init(gateway:Gateway):void
		{
			this.gateway = gateway;
		}
		
		public function searchUser(id:String):ServerUser
		{
			for each (var u:ServerUser in userList)
			{
				//trace("u.id:" + u.id + ", id:" + id);
				if (u.id == id)
				{
					return u;
				}
			}
			return null;
		}
		
		public function addUser(ip:String, id:String):void
		{
			var u:ServerUser = searchUser(id);
			if(u == null)
			{
				userList.push(new ServerUser(ip, id));
			}
			else
			{
				trace("[ERROR]addUser fail! userList.length:" + userList.length);
			}
		}
		
		public function removeOneUser(id:String):void
		{
			for (var i:int = 0; i < userList.length; i++)
			{
				var u:ServerUser = userList[i] as ServerUser;
				if (u.id == id)
				{
					userList.splice(i, 1);
					return;
				}
			}
			trace("[ERROR]removeUser fail! userList.length:" + userList.length);
		}
		
		public function getUsersWithout(id:String):Array
		{
			var ret:Array = new Array();
			for each (var u:ServerUser in userList)
			{
				if (u.id != id)
				{
					ret.push(u);
				}
			}
			return ret;
		}
		
		public function receiveLogin(ip:String, id:String):void
		{
			//先添加用户
			addUser(ip, id);
			
			//把其他人的信息发给个人
			sendUserListPosition(ip, id); 
			//把个人信息发给所有人
			broadcastNewUser(ip, id, 0, 0);
		}
		
		public function receiveLogout(ip:String, id:String):void
		{
			//把个人信息发给所有人
			broadcastRemoveUser(ip, id);
			
			//最后才删除
			removeOneUser(id);
		}
		
		public function broadcastNewUser(ip:String, id:String, x:int, y:int):void
		{
			//需要发回派发者
			var us:Array = userList;
			for (var i:int = 0; i < us.length; i++)
			{
				var u:ServerUser = us[i] as ServerUser;
				gateway.scNewUser(u.ip, id, x, y);
			}
		}
		
		public function broadcastRemoveUser(ip:String, id:String):void
		{
			//需要发回派发者
			var us:Array = userList;
			for (var i:int = 0; i < us.length; i++)
			{
				var u:ServerUser = us[i] as ServerUser;
				gateway.scRemoveUser(u.ip, id);
			}
		}
		
		public function receiveMove(ip:String, id:String, x:int, y:int):void
		{
			//如果只有一个人，有可能只收不发
			var u:ServerUser = searchUser(id);
			if (u != null)
			{
				u.setPosition(x, y);
				//trace("=====", u.posX, u.posY);
				broardcastPosition(id, x, y);
			}
			else
			{
				trace("[ERROR]move fail!, userList.length:" + userList.length);
			}
		}
		
		public function broardcastPosition(id:String, x:int, y:int):void
		{
			var us:Array = getUsersWithout(id);
			for (var i:int = 0; i < us.length; i++)
			{
				var u:ServerUser = us[i] as ServerUser;
				gateway.scPosition(u.ip, id, x, y);
			}
		}
		
		public function sendUserListPosition(ip:String, id:String):void
		{
			for each (var u:ServerUser in userList)
			{
				if (u.id != id)
				{
					//trace("ip:", ip, "u.id:", u.id, u.posX, u.posY);
					gateway.scNewUser(ip, u.id, u.posX, u.posY);
				}
			}
		}
	}
}
