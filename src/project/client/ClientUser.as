package project.client 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.text.TextFieldAutoSize;
	
	public class ClientUser
	{	
		public var id:String;
		public var r:int = 20;
		
		public var isDrag:Boolean = false;
		
		public var sprite:Sprite = new Sprite();
		public var txtID:TextField = new TextField();
		public var client:Client;
		
		private var _timer:Timer = new Timer(10);
		private var useTimer:Boolean = true;
		
		public function ClientUser(id:String, client:Client) 
		{
			this.id = id;
			this.client = client;
			
			if (id == client.view.id)
			{
				sprite.graphics.beginFill(0x00FF00);
			}
			else
			{
				sprite.graphics.beginFill(0xFF0000);
			}
			sprite.graphics.drawCircle(r, r, r);
			sprite.graphics.endFill();
			
			//防止被鼠标点到文本域
			txtID.autoSize = TextFieldAutoSize.LEFT;
			txtID.text = id;
			txtID.x = 0;
			txtID.y = 10;
			txtID.mouseEnabled = false;
			txtID.mouseWheelEnabled = false;
			sprite.addChild(txtID);
			//防止被鼠标点到文本域
			sprite.mouseChildren = false;
			sprite.doubleClickEnabled = false;
			sprite.addEventListener(Event.ADDED, onAdded);
		}
		
		public function setPosition(x:int, y:int):void
		{
			sprite.x = x;
			sprite.y = y;
		}
		
		public function onAdded(e:Event):void
		{
			sprite.removeEventListener(Event.ADDED, onAdded);	
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function toString():String
		{
			return "id: " + id + ", x: " + sprite.x + ", y: " + sprite.y;
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			if (!useTimer)
			{
				if (isDrag) 
				{
					client.getGateWay().csMove(client.ip, id, sprite.x, sprite.y);
				}
			}
			e.updateAfterEvent();
		}
		
		private function onTimer(e:TimerEvent):void
		{
			if (isDrag) 
			{
				client.getGateWay().csMove(client.ip, id, sprite.x, sprite.y);
			}
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if (isDrag == false && client.view.id == id)
			{
				sprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				sprite.startDrag(false, new Rectangle(0, 0, 360 - r * 2, 260 - r * 2));
				sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				e.stopImmediatePropagation();
				isDrag = true;
				if (useTimer)
				{
					_timer.start();
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			if(isDrag)
			{
				sprite.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				sprite.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				sprite.stopDrag();
				if(useTimer)
				{
					_timer.stop();
				}
				isDrag = false;
			}
		}
	}
}