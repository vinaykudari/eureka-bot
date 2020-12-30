import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:control_pad/control_pad.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Eureka Remote';
    final endpoint = 'ws://192.168.1.15:8000/ws';

    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        channel: IOWebSocketChannel.connect(endpoint),
        endpoint: endpoint,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String endpoint;
  WebSocketChannel channel;

  MyHomePage(
      {Key key,
      @required this.title,
      @required this.channel,
      @required this.endpoint})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                print(proximity);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 250, 0, 250),
                  alignment: Alignment.center,
                  child: FlatButton(
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
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
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
                        begin: const FractionalOffset(0.0, 0),
                        end: const FractionalOffset(0.0, 1.0),
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
                    SizedBox.fromSize(
                      size: Size(45, 45),
                      child: ClipOval(
                        child: Material(
                          color: Colors.grey[400],
                          child: InkWell(
                            splashColor: Colors.blue,
                            onTap: () {
                              _turnLeft();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.rotate_right), // icon// text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                    ),
                    SizedBox.fromSize(
                      size: Size(45, 45),
                      child: ClipOval(
                        child: Material(
                          color: Colors.grey[400],
                          child: InkWell(
                            splashColor: Colors.blue,
                            onTap: () {
                              _turnRight();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.rotate_left),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                padding: EdgeInsets.fromLTRB(25, 10, 0, 0),
              ),
              Container(
                // color: Colors.blueGrey[100],
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
                    print(value);
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
