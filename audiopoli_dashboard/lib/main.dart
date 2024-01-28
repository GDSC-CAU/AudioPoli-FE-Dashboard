import 'package:audiopoli_dashboard/LogContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import './mapContainer.dart';
import './LogContainer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import './TimeContainer.dart';

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
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: styledContainer()
                        ),
                        Expanded(
                          child: styledContainer(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        mapContainer(),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: TimeContainer()
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
            LogContainer(socket: socket)
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