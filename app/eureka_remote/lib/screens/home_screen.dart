import 'dart:convert';

import 'package:control_pad/views/joystick_view.dart';
import 'package:eureka_remote/components/base/round_button.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  WebSocketChannel channel;

  HomeScreen(
      {Key key,
      @required this.title,
      @required this.channel,
      @required this.endpoint})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String endpoint;
  double _speed = 50;
  dynamic _channel;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
  }

  @override
  Widget build(BuildContext context) {
    dynamic proximity = {'front': 0, 'back': 0};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey[500],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder(
            stream: _channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                proximity = json.decode(snapshot.data);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 250, 0, 250),
                  alignment: Alignment.center,
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _channel = IOWebSocketChannel.connect(widget.endpoint);
                      });
                    },
                    child: Text('Reconnect'),
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(00),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          if (proximity['front'] > 100)
                            Colors.red[200]
                          else
                            Colors.blue[200],
                          Colors.white,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(0.0, 1.0),
                        stops: [0, 0.8],
                        tileMode: TileMode.clamp,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        child: Text(
                          proximity['front'].toString() ?? '',
                          style: TextStyle(fontSize: 80, color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(0, 80, 0, 80),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          if (proximity['back'] > 100)
                            Colors.red[200]
                          else
                            Colors.blue[200],
                        ],
                        begin: FractionalOffset(0.0, 0),
                        end: FractionalOffset(0.0, 1.0),
                        stops: [0, 1],
                        tileMode: TileMode.clamp,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        child: Text(
                          proximity['back'].toString() ?? '',
                          style: TextStyle(fontSize: 80, color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(0, 100, 0, 60),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                child: Column(
                  children: [
                    RoundButton(
                      size: 45,
                      onTap: _turnRight,
                      icon: Icons.rotate_right,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                    ),
                    RoundButton(
                      size: 45,
                      onTap: _turnLeft,
                      icon: Icons.rotate_left,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(25, 10, 0, 0),
              ),
              Container(
                child: Padding(
                  child: JoystickView(
                    backgroundColor: Colors.grey,
                    innerCircleColor: Colors.grey[600],
                    opacity: 0.5,
                    size: 180,
                    onDirectionChanged: (x, y) => _changeDirection(x, y),
                  ),
                  padding: EdgeInsets.fromLTRB(25, 50, 30, 20),
                ),
              ),
              RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  min: 10,
                  max: 100,
                  divisions: 9,
                  value: _speed,
                  onChanged: (double value) {
                    setState(() {
                      _speed = value;
                      _setSpeed(value);
                    });
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _turnRight() {
    Map data = {
      'x': -1,
      'y': -1,
      'speed': -1,
      'turn_right': true,
      'turn_left': -1,
    };
    _channel.sink.add(json.encode(data));
  }

  void _turnLeft() {
    Map data = {
      'x': -1,
      'y': -1,
      'speed': -1,
      'turn_right': -1,
      'turn_left': true,
    };
    _channel.sink.add(json.encode(data));
  }

  void _setSpeed(speed) {
    Map data = {
      'x': -1,
      'y': -1,
      'speed': speed,
      'turn_right': -1,
      'turn_left': -1,
    };
    _channel.sink.add(json.encode(data));
  }

  void _changeDirection(x, y) {
    Map data = {
      'x': x,
      'y': y,
      'speed': -1,
      'turn_right': -1,
      'turn_left': -1,
    };
    _channel.sink.add(json.encode(data));
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
