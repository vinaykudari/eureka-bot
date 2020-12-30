import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  double size;
  Function onTap;
  IconData icon;
  Colors buttonColor;
  Colors splashColor;

  RoundButton(
      {Key key,
      @required this.size,
      @required this.onTap,
      @required this.icon,
      this.buttonColor,
      this.splashColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox.fromSize(
        size: Size(size ?? 45, size ?? 45),
        child: ClipOval(
          child: Material(
            color: buttonColor ?? Colors.grey[400],
            child: InkWell(
              splashColor: splashColor ?? Colors.blue,
              onTap: () => onTap(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
