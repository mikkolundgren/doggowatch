import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FlatButton(
            child: Text(
              'Tuloillaan!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
