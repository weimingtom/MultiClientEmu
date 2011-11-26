package project.server 
{
	public class ServerUser
	{		
		public var ip:String;
		public var id:String;
		public var posX:int;
		public var posY:int;
		
		public function ServerUser(ip:String, id:String) 
		{
			this.ip = ip;
			this.id = id;
		}
		
		public function setPosition(x:int, y:int):void
		{
			this.posX = x;
			this.posY = y;
		}
	}
}
