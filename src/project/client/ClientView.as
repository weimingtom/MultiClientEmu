package project.client 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	
	public class ClientView
	{
		public var txtUserList:TextField = new TextField();
		public var btnLogin:SimpleButton = new LoginButton();
		public var spContainer:Sprite = new Sprite();
		
		public var id:String;
		public var dx:int;
		public var dy:int;
		
		public function ClientView(id:String, dx:int, dy:int) 
		{
			this.id = id;
			this.dx = dx;
			this.dy = dy;
		}
		
		public function added(container:DisplayObjectContainer):void
		{
			btnLogin.x = 0;
			spContainer.addChild(btnLogin);			
			txtUserList.text = id + " userList:";
			txtUserList.autoSize = TextFieldAutoSize.LEFT;
			txtUserList.x = 0;
			txtUserList.y = 20;
			txtUserList.mouseEnabled = false;
			txtUserList.mouseWheelEnabled = false;
			
			spContainer.graphics.beginFill(0xFFFFFF, 1);
			spContainer.graphics.drawRect(0, 0, 360, 260); //560);
			spContainer.graphics.endFill();
			spContainer.addChild(txtUserList);
			spContainer.x = this.dx + 20;
			spContainer.y = this.dy + 20;
			container.addChild(spContainer);
		}
	}
}
