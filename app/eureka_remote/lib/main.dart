import 'package:eureka_remote/screens/find_bot_screen.dart';
import 'package:eureka_remote/screens/home_screen.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Eureka Remote';
    final endpoint = 'ws://192.168.1.15:8000/ws';

    return MaterialApp(
      title: title,
      home: FindBotScreen(
        endpoint: endpoint,
      ),
    );
  }
}
