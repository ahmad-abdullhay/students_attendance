import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:students/models/student_user.dart';
import 'package:students/pages/dashbord_page.dart';
import 'package:students/widgets/input_text_field.dart';
import 'package:toast/toast.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final bool isTeacher;

  const RegisterPage({Key key, @required this.isTeacher}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final userRef = Firestore.instance.collection('users');

class _RegisterPageState extends State<RegisterPage> {
  TextStyle style = TextStyle(fontFamily: 'Scholar', fontSize: 20.0);
  String id;
  String name;
  String email;
  String phoneNumber;
  String level;
  String password;
  bool isRegistering = false;

  Future<void> firestore_reg() async {
    final snapshot = await _auth.currentUser;

    WidgetsFlutterBinding.ensureInitialized();
    await userRef.document(snapshot.uid).setData({
      "Name": name,
      "Email": snapshot.email,
      "PhoneNumber": phoneNumber,
      "UserId": id,
      "isStd": true,
      "Level": level,
      "classesIds": [],
    });
  }

  Future register() async {
    if (!formKey.currentState.validate()) return;
    setState(() {
      isRegistering = true;
    });

    var user;
    try {
      user = (await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;
    } catch (ex) {
      print(ex);
      user = null;
      authProblems errorType;
      String errorString;
      switch (ex.message) {
        case 'The email address is already in use by another account.':
          errorType = authProblems.AlReadyInUse;
          errorString = "Email already in use";
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
    }
    if (user != null) {
      setState(() {
        isRegistering = false;
      });
    } else {
      setState(() {
        isRegistering = false;
      });
      return;
    }
    firestore_reg();
    StudentUser studentUser = StudentUser(
        firebaseID: user.uid,
        email: email,
        id: id,
        phoneNumber: phoneNumber,
        level: '5',
        name: name,
        classesList: []);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => DashBoard(
            studentUser: studentUser,
            isTeacher: widget.isTeacher,
          ),
        ),
        (r) => false);
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(50.0),
      color: Colors.teal[200],
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30.0, 15.0, 20.0, 15.0),
        onPressed: () {
          register();
        },
        child: Text("Register",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    final cancelButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(50.0),
      color: Colors.teal[200],
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.pop(
            context,
          );
        },
        child: Text("CANCEL",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    Function validator = (value) {
      if (value.isEmpty) {
        return 'this field cant be empty';
      }
      return null;
    };
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
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: isRegistering,
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InputTextField(
                          hintText: 'ID',
                          onChanged: (value) {
                            id = value;
                          },
                          validator: validator,
                        ),
                        InputTextField(
                          hintText: 'Name',
                          onChanged: (value) {
                            name = value;
                          },
                          validator: validator,
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
                          hintText: 'Phone Number',
                          textInputType: TextInputType.phone,
                          onChanged: (value) {
                            phoneNumber = value;
                          },
                          validator: validator,
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
                        registerButton,
                        SizedBox(
                          height: 10.0,
                        ),
                        cancelButton,
                        SizedBox(
                          height: 10.0,
                        ),
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
