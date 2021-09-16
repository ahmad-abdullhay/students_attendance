import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:students/models/student_user.dart';
import 'package:students/widgets/input_text_field.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

const password = '**********';


class EditProfilePage extends StatefulWidget {
  final StudentUser studentUser;
  final bool isTeacher;
  const EditProfilePage({Key key, @required this.studentUser,@required this.isTeacher})
      : super(key: key);
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  _EditProfilePageState();

  StudentUser user;

  void _showDialog(BuildContext context, {String title, String msg}) {
    final dialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: <Widget>[
        RaisedButton(
          color: Colors.teal,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Close',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  @override
  void initState() {
    user = widget.studentUser;
    super.initState();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage('assets/images/female-profile.png'),
                    ),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pacifico',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 200,
                      child: Divider(
                        color: Colors.black,
                      ),
                    ),
                    InfoCard(
                      text: user.id,
                      icon: Icons.web,
                    ),
                    InfoCard(
                      text: user.email,
                      icon: Icons.email,
                      onPressed: () async {
                        final emailAddress = 'mailto:${user.email}';

                        if (await launcher.canLaunch(emailAddress)) {
                          await launcher.launch(emailAddress);
                        } else {
                          _showDialog(
                            context,
                            title: 'Sorry',
                            msg: 'Email can not be send. Please try again!',
                          );
                        }
                      },
                    ),
                    InfoCard(
                      text: user.phoneNumber,
                      icon: Icons.phone,
                    ),
                    InfoCard(
                      text: widget.isTeacher? 'Teacher':  'Student',
                      icon: Icons.web,
                    ),
                    InfoCard(
                        text: password,
                        icon: Icons.card_membership,
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return EditDialog();
                              });
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: Text("CANCEL",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 2.1,
                                  color: Colors.black)),
                        ),
                        RaisedButton(
                          onPressed: () {},
                          color: Colors.teal[200],
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "SAVE",
                            style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2.1,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;

  InfoCard({
    @required this.text,
    @required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.teal,
          ),
          title: Text(
            text,
            style: TextStyle(
              fontFamily: 'Source Sans Pro',
              fontSize: 10.0,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
///BY THEMaker
class EditDialog extends StatefulWidget {
  bool important;
  EditDialog({this.important});
  @override
  _EditDialogState createState() => _EditDialogState();
}

///BY THEMaker
class _EditDialogState extends State<EditDialog> {
  void _changePassword(String password) async {
    //Create an instance of the current user.
    final _auth = FirebaseAuth.instance;
    final user = await _auth.currentUser;
    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_) {
      print("Successfully changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  String newpass = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'change password',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputTextField(
            hintText: 'Password',
            textInputType: TextInputType.visiblePassword,
            isObscure: true,
            onChanged: (value) {
              newpass = value;
            },
          )
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                )),
            FlatButton(
              onPressed: () {
                _changePassword(newpass);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
              ),
            ),
          ],
        )
      ],
    );
  }
}
