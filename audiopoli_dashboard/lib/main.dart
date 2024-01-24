import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import './mapContainer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    // 서버와 연결을 설정
    socket = IO.io('http://34.64.68.234:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    // 서버 연결 시
    socket.on('connect', (_) {
      print('connected to server');
      // 서버에 메시지 전송 예시
      socket.emit('serverMessage', 'hello from Flutter!');
    });

    // 서버로부터 메시지 수신
    socket.on('serverMessage', (data) {
      print('Server: $data');
    });

    // 현재 시간을 받는 이벤트
    socket.on('time', (data) {
      print('Current time: ${data['time']}');
    });

    // 연결 해제 시
    socket.on('disconnect', (_) => print('disconnected from server'));
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: TimeDisplayContainer(socket: socket,)
                        ),
                        Expanded(
                          child: styledContainer(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: mapContainer(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: styledContainer(),
            ),
          ],
        ),
      ),
    );
  }
}

class styledContainer extends StatelessWidget {
  styledContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1.5,
            blurRadius: 1.5,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class TimeDisplayContainer extends StatefulWidget {
  late IO.Socket socket;
  TimeDisplayContainer({Key? key, required this.socket}) : super(key: key);

  @override
  _TimeDisplayContainerState createState() => _TimeDisplayContainerState();
}

class _TimeDisplayContainerState extends State<TimeDisplayContainer> {
  String _time = "ㅁㄴㅇㅁㄴㅇ";

  @override
  void initState() {
    super.initState();
    widget.socket.on('time', (data) {
      setState(() {
        _time = data['time'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      color: Colors.blueAccent,
      child: Text(
        _time,
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}