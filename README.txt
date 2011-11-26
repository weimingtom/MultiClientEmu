* About and build:
	1. Emulate multiple clients in only one flash player.
	2. Need run a java echo server, which is in java/TCPEchoServer folder.
	3. Flash document class is "project.common.ClientApp".
	4. If it is built and run in flashdevelop, don't need a flash policy server.
	(if you need, see
	http://code.google.com/p/assql/wiki/JavaPolicyFileServer
	)
	
* Usage:
	1. Run java/TCPEchoServer, 
	   then build and run this flex project,
	   open a flash player. 
	2. Click Login button to login/logout server.
	3. Drag a green ball to send move message.
	
* More:
	if change project.common.Gateway's dataProcess from SOCKET to INVOKE,
	java echo server will be not necessary.
