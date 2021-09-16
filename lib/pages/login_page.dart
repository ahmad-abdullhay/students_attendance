import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:students/models/attendance.dart';
import 'package:students/models/class.dart';
import 'package:students/models/student_user.dart';
import 'package:students/pages/dashbord_page.dart';
import 'package:students/widgets/input_text_field.dart';
import 'package:toast/toast.dart';

import 'Register_page.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, AlReadyInUse }

class LoginPage extends StatefulWidget {
  final bool isTeacher;

  const LoginPage({Key key, @required this.isTeacher}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Scholar', fontSize: 20.0);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  String password;
  String email;
  Future<List<Attendance>> getAttendaceList(List<String> attendaceIds) async {
    List<Attendance> attendaceList = [];
    for (String id in attendaceIds) {
      final attendance =
          FirebaseFirestore.instance.collection('attendance').doc(id);
      var doc = await attendance.get();
      List<String> studentsArray = doc['studentsArray'].cast<String>();
      String date = doc['date'];
      attendaceList.add(Attendance(
          id: attendance.id, studentsList: studentsArray, date: date));
    }
    return attendaceList;
  }

  Future<List<Class>> getStudentCLasses(DocumentSnapshot doc) async {
    List<String> classesIds = doc['classesIds'].cast<String>();
    List<Class> classes = [];
    for (String id in classesIds) {
      final classesRef =
          FirebaseFirestore.instance.collection('classes').doc(id);
      var nameDoc = await classesRef.get();
      String name = nameDoc['className'];
      List<String> attendaceIds = nameDoc['attendaceIdsList'].cast<String>();
      classes.add(Class(
          name: name,
          id: classesRef.id,
          attendaceList: await getAttendaceList(attendaceIds)));
    }
    return classes;
  }

  Future login() async {
    if (!formKey.currentState.validate()) return;
    setState(() {
      isLogin = true;
    });
    var user;
    try {
      final status = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ));
      user = status.user;
    } catch (ex) {
      print(ex);
      authProblems errorType;
      String errorString;
      switch (ex.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = authProblems.UserNotFound;
          errorString = "User Not Found";
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = authProblems.PasswordNotValid;
          errorString = "Password Not Valid";
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorType = authProblems.NetworkError;
          errorString = "Network Error";
          break;
        // ...
        default:
          print('Case ${ex.message} is not jet implemented');
      }

      Toast.show(errorString, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

      user = null;
    }
    StudentUser userM;
    if (user != null) {
      DocumentSnapshot doc = await userRef.doc(user.uid).get();
      userM =
          StudentUser.fromDocument(doc, user.uid, await getStudentCLasses(doc));
      setState(() {
        isLogin = false;
      });
    } else {
      setState(() {
        isLogin = false;
      });
      return;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DashBoard(
            studentUser: userM,
            isTeacher: widget.isTeacher,
          ),
        ),
        (r) => false);
  }

  bool isLogin = false;
  @override
  Widget build(BuildContext context) {
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(50.0),
      color: Colors.teal[300],
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30.0, 15.0, 20.0, 15.0),
        onPressed: () {
          login();
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final rigesterButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(50.0),
      color: Colors.teal[300],
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => RegisterPage(
                        isTeacher: widget.isTeacher,
                      )));
        },
        child: Text("Register",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    Function passValidator = (value) {
      if (value.isEmpty) {
        return 'this field cant be empty';
      } else if (value.length < 6) {
        return 'Password must be more than 5 characters';
      }

      return null;
    };
    Function emailValidator = (value) {
      bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(value);
      if (value.isEmpty) {
        return 'this field cant be empty';
      } else if (!emailValid) {
        return 'Email format not valid';
      }

      return null;
    };
    return Scaffold(
      body: Form(
        key: formKey,
        child: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: isLogin,
            child: Center(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'QR attendance',
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w300,
                                fontSize: 12),
                          ),
                        ),
                        Container(
                          child: Image.asset(
                            "assets/images/logo.Jpg",
                          ),
                          height: 100,
                          width: 200,
                          alignment: Alignment.center,
                        ),
                        InputTextField(
                          hintText: 'Email',
                          textInputType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
                          validator: emailValidator,
                        ),
                        InputTextField(
                          hintText: 'Password',
                          textInputType: TextInputType.visiblePassword,
                          isObscure: true,
                          onChanged: (value) {
                            password = value;
                          },
                          validator: passValidator,
                        ),
                        loginButton,
                        SizedBox(
                          height: 15.0,
                        ),
                        rigesterButton,
                        SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: 'forgot your password?'),
                                TextSpan(
                                    text: 'press here to reset',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {

                                      
                                        if (email == null||email.isEmpty) {
                                          Toast.show(
                                              'please write your email on the email filed',
                                              context,
                                              duration: Toast.LENGTH_LONG,
                                              gravity: Toast.BOTTOM);
                                        } else if (!  RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(email)) {
                                          Toast.show(
                                              'Email format not valid', context,
                                              duration: Toast.LENGTH_LONG,
                                              gravity: Toast.BOTTOM);
                                        } else {
                                          
                                          await _auth.sendPasswordResetEmail(
                                              email: email);
                                          Toast.show(
                                              'reset email sent', context,
                                              duration: Toast.LENGTH_LONG,
                                              gravity: Toast.BOTTOM);
                                        }
                                      }),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
