package project.client 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import project.common.Gateway;
	import flash.events.MouseEvent;
	
	public class Client
	{		
		public var ip:String;
		
		//ClientUser
		public var userList:Array = new Array();
		
		public var view:ClientView;
		public var gateway:Gateway;
		//public var isConnected:Boolean = false;
		public var isLogin:Boolean = false;
		
		public function Client(view:ClientView, ip:String) 
		{
			this.view = view;
			this.ip = ip;
		}
		
		public function newClientUser(id:String, x:int, y:int):ClientUser
		{
			for each(var u:ClientUser in userList)
			{
				if (u != null && u.id == id)
				{
					return null;
				}
			}
			var user:ClientUser = new ClientUser(id, this);
			userList.push(user);
			user.setPosition(x, y);
			view.spContainer.addChild(user.sprite);
			
			return user;
		}
		
		public function removeAllClientUsers():void
		{
			for each(var u:ClientUser in userList)
			{
				view.spContainer.removeChild(u.sprite);
			}
			userList = new Array();
		}
		
		public function removeClientUser(id:String):void
		{
			for (var i:int = 0; i < userList.length; i++)
			{
				var u:ClientUser = userList[i] as ClientUser;
				if (u.id == id)
				{
					view.spContainer.removeChild(u.sprite);
					userList.splice(i, 1);
					break;
				}
			}
		}
		
		public function init(gateway:Gateway):void
		{
			this.gateway = gateway;
			trace("init");
			view.btnLogin.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:Event):void 
		{
			if (isLogin == false)
			{
				gateway.csLogin(ip, view.id);
			}
			else
			{
				gateway.csLogout(ip, view.id);
			}
		}
		
		public function getGateWay():Gateway
		{
			return this.gateway;
		}
		
		
		public function onReceiveNewUser(id:String, x:int, y:int):void
		{
			if(id == view.id)
			{
				if(isLogin == false)
				{
					isLogin = true;
					newClientUser(id, x, y);
				}
			}
			else
			{
				newClientUser(id, x, y);
			}
		}
		
		public function onRemoveNewUser(id:String):void
		{
			if(id == view.id)
			{
				if(isLogin == true)
				{
					isLogin = false;
					removeAllClientUsers();
				}
			}
			else
			{
				removeClientUser(id);
			}
		}
		
		public function onReceivePosition(id:String, x:int, y:int):void
		{
			if (id == view.id)
			{
				return;
			}
			for each(var u:ClientUser in userList)
			{
				if (u != null && u.id == id)
				{
					u.setPosition(x, y);
				}
			}
		}
	}
}
