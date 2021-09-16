import 'package:firebase_core/firebase_core.dart';
import 'package:students/pages/first_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = true;
  Future<void> init() async {
    await Firebase.initializeApp();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      home: isLoading ? Container() :  FirstPage()
    
    );
  }
}
