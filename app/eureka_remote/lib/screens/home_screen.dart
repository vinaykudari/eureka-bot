import 'dart:convert';

import 'package:control_pad/views/joystick_view.dart';
import 'package:eureka_remote/components/base/round_button.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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
  String _interfaceType;
  double _speed = 50;
  dynamic _channel;
  double _alpha = 0;
  String initUrl = "http://192.168.1.15:8000/video/";
  VlcPlayerController _videoViewController;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
    _interfaceType = 'proximity';

    _videoViewController = new VlcPlayerController(onInit: () {
      _videoViewController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic proximity = {'front': 0, 'rear': 0};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey[500],
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                if (_interfaceType == 'proximity') {
                  _interfaceType = 'camera';
                  _alpha = 90;
                } else {
                  _interfaceType = 'proximity';
                  _alpha = 0;
                }
                setState(() {
                  _interfaceType = _interfaceType;
                });
              },
              child: Icon(
                (_interfaceType == 'proximity')
                    ? Icons.camera_alt_outlined
                    : Icons.car_repair,
                size: 26.0,
              ),
            ),
          ),
        ],
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
              if (_interfaceType == 'proximity') {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(00),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            if (proximity['front'] < 100)
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
                            (proximity['front'] / 10).toString() + ' cm' ?? '',
                            style: TextStyle(fontSize: 60, color: Colors.white),
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
                            if (proximity['rear'] > 80)
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
                            (proximity['rear'] > 80 ? 'close' : 'safe'),
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 130, 0, 130),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      RotatedBox(
                        child: SizedBox(
                          // height: 850,
                          width: 500,
                          child: VlcPlayer(
                            aspectRatio: 16 / 9,
                            url: initUrl,
                            isLocalMedia: false,
                            controller: _videoViewController,
                            options: [
                              '--quiet',
                              '-vvv',
                              '--no-drop-late-frames',
                              '--no-skip-frames',
                              '--rtsp-tcp',
                            ],
                            hwAcc: HwAcc.AUTO,
                            placeholder: Container(
                              height: 250.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[CircularProgressIndicator()],
                              ),
                            ),
                          ),
                        ),
                        quarterTurns: 5,
                      )
                    ],
                  ),
                );
              }
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
                      if (value != -1) {
                        _speed = value;
                      }
                      _setSpeed(_speed);
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
      'speed': _speed,
      'turn_right': true,
      'turn_left': -1,
    };
    _channel.sink.add(json.encode(data));
  }

  void _turnLeft() {
    Map data = {
      'x': -1,
      'y': -1,
      'speed': _speed,
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
      'x': (x - _alpha) % 360,
      'y': y,
      'speed': _speed,
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

  void playOrPauseVideo() {
    String state = _videoViewController.playingState.toString();

    if (state == "PlayingState.PLAYING") {
      _videoViewController.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      _videoViewController.play();
      setState(() {
        isPlaying = true;
      });
    }
  }
}
