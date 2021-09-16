import 'package:flutter/material.dart';

import 'login_page.dart';

class FirstPage extends StatefulWidget {
  @override
  FirstPageState createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Material(
            elevation: 2.0,
            shape: CircleBorder(),
            child: MaterialButton(
              child: Image.asset(
                'assets/images/teacher.png',
                height: 180.0,
                width: 120.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(isTeacher: true,)),
                );
              },
            ),
          ),
          Material(
            elevation: 2.0,
            shape: CircleBorder(),
            child: MaterialButton(
              child: Image.asset(
                'assets/images/student.png',
                height: 180.0,
                width: 120.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(isTeacher: false,)),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
