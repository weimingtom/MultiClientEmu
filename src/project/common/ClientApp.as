package project.common
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import project.client.Client;
	import project.client.ClientView;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import project.server.Server;
	
	[SWF(width='800', height='600', backgroundColor='#CCCCCC', frameRate='24')]
	public class ClientApp extends Sprite
	{
		private var view1:ClientView = new ClientView("user 1", 0, 0);
		private var view2:ClientView = new ClientView("user 2", 400, 0);
		private var view3:ClientView = new ClientView("user 3", 0, 300);
		private var view4:ClientView = new ClientView("user 4", 400, 300);
		
		private var client1:Client = new Client(view1, "192.168.0.111");
		private var client2:Client = new Client(view2, "192.168.0.112");
		private var client3:Client = new Client(view3, "192.168.0.113");
		private var client4:Client = new Client(view4, "192.168.0.114");
		
		private var server:Server = new Server();
		
		private var gateway:Gateway = new Gateway(server, [
			client1, client2, client3, client4
		]);
		
		public function ClientApp() 
		{
			trace("app start...");
			view1.added(this);
			view2.added(this);
			view3.added(this);
			view4.added(this);
			
			gateway.init(this);
			
			client1.init(gateway);
			client2.init(gateway);
			client3.init(gateway);
			client4.init(gateway);
			
			server.init(gateway);
		}
	}
}
