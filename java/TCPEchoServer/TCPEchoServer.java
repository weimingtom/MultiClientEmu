import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketAddress;

public class TCPEchoServer 
{
	public static void main(String[] args) throws IOException {
		int servPort = 9988;
		int BUFSIZE = 32;
		ServerSocket servSock = new ServerSocket(servPort);
		int recvMsgSize;
		byte[] receiveBuf = new byte[BUFSIZE];
		System.out.println("Listen at " + servPort);
		while (true) {
			Socket clntSock = servSock.accept();
			SocketAddress clientAddress = clntSock.getRemoteSocketAddress();
			System.out.println("Connect at " + clientAddress);
			InputStream in = clntSock.getInputStream();
			OutputStream out = clntSock.getOutputStream();
			while ((recvMsgSize = in.read(receiveBuf)) != -1) {
				out.write(receiveBuf, 0, recvMsgSize);
			}
			clntSock.close();
		}
	}
}
