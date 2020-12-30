import 'package:eureka_remote/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class FindBotScreen extends StatefulWidget {
  String endpoint;
  FindBotScreen({@required this.endpoint});

  @override
  _FindBotScreenState createState() => _FindBotScreenState();
}

class _FindBotScreenState extends State<FindBotScreen> {
  TextEditingController myController = TextEditingController();
  String _newEndpoint;
  dynamic _channel;

  @override
  void initState() {
    super.initState();
    _newEndpoint = widget.endpoint;
    myController.text = widget.endpoint;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eureka'),
        backgroundColor: Colors.blueGrey[500],
      ),
      body: ListView(
        children: [
          Image.asset(
            ('assets/images/bot.png'),
            height: 300,
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(60, 80, 60, 0),
              child: TextField(
                controller: myController,
                onChanged: (text) {
                  setState(() {
                    _newEndpoint = text;
                  });
                },
                cursorColor: Colors.black26,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  labelText: 'Bot Network Address',
                  labelStyle: TextStyle(color: Colors.black38),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black38),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black38),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            child: RaisedButton(
              child: Text('Connect'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: () {
                print(widget.endpoint);
                _channel = IOWebSocketChannel.connect(_newEndpoint);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      endpoint: _newEndpoint,
                      title: 'Remote',
                      channel: _channel,
                    ),
                  ),
                );
              },
            ),
            padding: EdgeInsets.fromLTRB(160, 25, 160, 0),
          )
        ],
      ),
    );
  }
}
