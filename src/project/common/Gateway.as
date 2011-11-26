package project.common 
{
	import flash.net.Socket;
	import flash.utils.Dictionary;
	import project.client.Client;
	import project.server.Server;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.DisplayObjectContainer;
	import flash.utils.ByteArray;
	
	public class Gateway
	{
		private var server:Server;
		private var clients:Dictionary = new Dictionary();
		private static const PORT:int = 9988;
		private var socket:Socket = new Socket();
		
		public static const NONE:int = 0;
		public static const INVOKE:int = 1;
		public static const SOCKET:int = 2;
		
		private var dataProcess:int = SOCKET; // options: INVOKE / SOCKET
		
		private var txtOutput:TextField = new TextField();
		
		private var messageBuffer:ByteArray = new ByteArray();
		
		public function Gateway(server:Server, clis:Array) 
		{
			this.server = server;
			for (var i:int = 0; i < clis.length; i++)
			{
				var client:Client = clis[i];
				this.clients[client.ip] = client;
			}
			this.socket.addEventListener(Event.CLOSE, closeHandler);
			this.socket.addEventListener(Event.CONNECT, connectHandler);
			this.socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			this.socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			this.socket.connect("localhost", PORT);
		}
		
		public function init(container:DisplayObjectContainer):void
		{
			txtOutput.mouseEnabled = false;
			txtOutput.doubleClickEnabled = false;
			txtOutput.mouseWheelEnabled = false;
			txtOutput.autoSize = TextFieldAutoSize.LEFT;
			txtOutput.text = "init\n";
			container.addChild(txtOutput);
		}
		
		private function log(txt:String):void
		{
			txtOutput.appendText(txt + "\n");
		}
		
		private function closeHandler(event:Event):void 
		{
			log("connect close");
		}

		private function connectHandler(event:Event):void 
		{
			log("connect success");
		}

		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			log("ioErrorHandler: " + event);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			log("securityErrorHandler: " + event);
		}
		
		private function socketDataHandler(event:ProgressEvent):void 
		{
			trace("socketDataHandler: " + event);
			onDataPayLoad(event);
		}
		
		private function onDataPayLoad(event:ProgressEvent):void
		{
			try 
			{
				var buf:ByteArray = new ByteArray();
				socket.readBytes(buf, 0, socket.bytesAvailable);
				messageBuffer.writeBytes(buf, 0, buf.length);
				messageBuffer.position = 0;
				while (messageBuffer.bytesAvailable > 2)
				{
					var payloadLength:int = messageBuffer.readShort();
					if (messageBuffer.bytesAvailable >= payloadLength)
					{
						var newMessage:ByteArray = new ByteArray();
						messageBuffer.readBytes(newMessage, 0, payloadLength);
						clientReceive(newMessage);
					}
					else
					{
						messageBuffer.position -= 2;
						break;
					}
				}
				var newBuffer:ByteArray = new ByteArray();
				newBuffer.writeBytes(messageBuffer, messageBuffer.position, messageBuffer.bytesAvailable);
				messageBuffer = newBuffer;
			} 
			catch (e:Error) 
			{
				trace(e.getStackTrace());
			}
		}
		
		public function sendMsg(data:ByteArray):void 
		{
			if (socket && socket.connected)
			{
				socket.writeShort(data.length);
				socket.writeBytes(data);
				socket.flush();
			}
		}
		
		private function clientReceive(buf:ByteArray):void
		{
			var ip:String;
			var id:String;
			var x:int;
			var y:int;
			var client:Client;
			
			if (buf.bytesAvailable > 0)
			{
				var channelID:int = buf.readByte();
				switch(channelID)
				{
					case 1:
						ip = buf.readUTF();
						id = buf.readUTF();
						server.receiveLogin(ip, id);
						trace("===receive", channelID, ip, id);
						break;
						
					case 2:
						ip = buf.readUTF();
						id = buf.readUTF();
						x = buf.readInt();
						y = buf.readInt();
						client = clients[ip] as Client;
						client.onReceiveNewUser(id, x, y);
						trace("===receive", channelID, ip, id, x, y);
						break;
						
					case 3:
						ip = buf.readUTF();
						id = buf.readUTF();
						server.receiveLogout(ip, id);
						trace("===receive", channelID, ip, id);
						break;
						
					case 4:
						ip = buf.readUTF();
						id = buf.readUTF();
						client = clients[ip] as Client;
						client.onRemoveNewUser(id);
						trace("===receive", channelID, ip, id);
						break;
						
					case 5:
						ip = buf.readUTF();
						id = buf.readUTF();
						x = buf.readInt();
						y = buf.readInt();
						server.receiveMove(ip, id, x, y);
						trace("===receive", channelID, ip, id, x, y);
						break;
						
					case 6:
						ip = buf.readUTF();
						id = buf.readUTF();
						x = buf.readInt();
						y = buf.readInt();
						client = clients[ip] as Client;
						client.onReceivePosition(id, x, y);
						trace("===receive", channelID, ip, id, x, y);
						break;
						
					default:
						throw new Error("no match channelID");
						return;
				}
			}
		}
		
		public function csLogin(ip:String, id:String):void
		{
			trace("[" + ip + "][c->s][login]id:", id);
			if (dataProcess == INVOKE) 
			{
				server.receiveLogin(ip, id);
			}
			else if (dataProcess == SOCKET)
			{
				var buf:ByteArray = new ByteArray();
				buf.writeByte(1);
				buf.writeUTF(ip);
				buf.writeUTF(id);
				sendMsg(buf);
			}
		}
		
		public function scNewUser(ip:String, id:String, x:int, y:int):void
		{
			trace("[" + ip + "][c<-s][newUser]id:", id, ", x:", x, ", y", y);
			if (dataProcess == INVOKE) 
			{
				var client:Client = clients[ip] as Client;
				client.onReceiveNewUser(id, x, y);
			}
			else if (dataProcess == SOCKET)
			{
				var buf:ByteArray = new ByteArray();
				buf.writeByte(2);
				buf.writeUTF(ip);
				buf.writeUTF(id);
				buf.writeInt(x);
				buf.writeInt(y);
				sendMsg(buf);
			}
		}

		public function csLogout(ip:String, id:String):void
		{
			trace("[" + ip + "][c->s][logout]id:", id);
			if (dataProcess == INVOKE) 
			{
				server.receiveLogout(ip, id);
			}
			else if (dataProcess == SOCKET)
			{
				var buf:ByteArray = new ByteArray();
				buf.writeByte(3);
				buf.writeUTF(ip);
				buf.writeUTF(id);
				sendMsg(buf);
			}
		}
		
		public function scRemoveUser(ip:String, id:String):void
		{
			trace("[" + ip + "][c<-s][removeUser]id:", id);
			if (dataProcess == INVOKE) 
			{
				var client:Client = clients[ip] as Client;
				client.onRemoveNewUser(id);
			}
			else if (dataProcess == SOCKET)
			{
				var buf:ByteArray = new ByteArray();
				buf.writeByte(4);
				buf.writeUTF(ip);
				buf.writeUTF(id);
				sendMsg(buf);
			}
		}
		
		public function csMove(ip:String, id:String, x:int, y:int):void
		{
			trace("[" + ip + "][c->s][move]id:", id, ", x:", x, ", y:", y);
			if (dataProcess == INVOKE) 
			{
				server.receiveMove(ip, id, x, y);
			}
			else if (dataProcess == SOCKET)
			{
				var buf:ByteArray = new ByteArray();
				buf.writeByte(5);
				buf.writeUTF(ip);
				buf.writeUTF(id);
				buf.writeInt(x);
				buf.writeInt(y);
				sendMsg(buf);
			}
		}
		
		public function scPosition(ip:String, id:String, x:int, y:int):void
		{
			trace("[" + ip + "][c<-s][position]id:", id, ", x:", x, ", y:", y);
			if (dataProcess == INVOKE) 
			{
				var client:Client = clients[ip] as Client;
				client.onReceivePosition(id, x, y);
			}
			else if (dataProcess == SOCKET)
			{
				var buf:ByteArray = new ByteArray();
				buf.writeByte(6);
				buf.writeUTF(ip);
				buf.writeUTF(id);
				buf.writeInt(x);
				buf.writeInt(y);
				sendMsg(buf);
			}
		}
	}
}
