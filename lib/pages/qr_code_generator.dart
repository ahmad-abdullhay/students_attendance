import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:students/models/attendance.dart';
import 'package:students/models/class.dart';

class QrCodeGeneratorPage extends StatefulWidget {
  @override
  _QrCodeGeneratorPageState createState() => _QrCodeGeneratorPageState();
}

class _QrCodeGeneratorPageState extends State<QrCodeGeneratorPage> {
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
  bool isLoading = false;
  getClassesList() async {
    setState(() {
      isLoading = true;
    });
    List<Class> classNames = [];
    final classesRef = FirebaseFirestore.instance.collection('classes');
    QuerySnapshot allNames = await classesRef.get();
    for (int i = 0; i < allNames.docs.length; i++) {
      var a = allNames.docs[i];
    List<String> attendaceIds = a['attendaceIdsList'].cast<String>();
      classNames.add(Class(
        name: a['className'], id: a.id,
        division: a['division'],
      attendaceList: await getAttendaceList(attendaceIds),
      
      ));
    }
    classesList = classNames;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getClassesList();
    super.initState();
  }

  List<Class> classesList = [];
  Class currentClass;
  Uint8List bytes = Uint8List(0);
  Future _generateBarCode(String classId, String attendanceId) async {
    DateTime timeNow = DateTime.now();
    String time =
        '${timeNow.year}-${timeNow.month}-${timeNow.day} ${timeNow.hour}:${timeNow.minute}:${timeNow.second}';

         Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
        String positionString = '${position.latitude},${position.longitude}';
    String code = '$attendanceId@$classId@$time@$positionString';
    print(code);
    Uint8List result = await scanner.generateBarCode(code);
    setState(() { this.bytes = result;});
  }
  bool isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR code Generator'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ModalProgressHUD(
            inAsyncCall: isGenerating,
                      child: Column(
                children: [
                  _qrCodeWidget(bytes, context, () async {
                    setState(() {
                      isGenerating = true;
                    });
                    var ref =
                        FirebaseFirestore.instance.collection('attendance');
                    var now = DateTime.now();
                    String date = '${now.day}/${now.month}/${now.year}';
                    var doc = await ref.add({"date": date, "studentsArray": []});
                    currentClass.attendaceList.add(Attendance(
                      id: doc.id,
                      date: date,
                      studentsList: [],
                    ));
                    final classRef = FirebaseFirestore.instance.collection('classes');
                    List attendaceIdsList = [];
                    for (Attendance attendance in  currentClass.attendaceList)
                      attendaceIdsList.add(attendance.id);
                     await classRef.doc(currentClass.id).update({
                      "attendaceIdsList":  attendaceIdsList
                       });            
                    _generateBarCode(currentClass.id, doc.id);
                    setState(() {
                       isGenerating = false;
                    });
                  }),
                  DropdownButton(
                    hint: Text('Select class to generate QR code for it'),
                    value: currentClass,
                    onChanged: (newValue) {
                      setState(() {
                        currentClass = newValue;
                      });
                    },
                    items: classesList.map((c) {
                      return DropdownMenuItem(
                        child: new Text(c.name+" - " +c.division),
                        value: c,
                      );
                    }).toList(),
                  ),
                ],
              ),
          ),
    );
  }

  Widget _qrCodeWidget(
      Uint8List bytes, BuildContext context, Function onPressed) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Card(
        elevation: 6,
        child: Column(
          children: <Widget>[
            Text('  Generate Qrcode', style: TextStyle(fontSize: 15)),
            Divider(
              color: Colors.black,
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 190,
                    child: bytes.isEmpty
                        ? Center(
                            child: Text('Empty code ... ',
                                style: TextStyle(color: Colors.black38)),
                          )
                        : Image.memory(bytes),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7, left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        RaisedButton(
                          child: Text(
                            'remove',
                            style: TextStyle(fontSize: 15, color: Colors.teal),
                            textAlign: TextAlign.left,
                          ),
                          onPressed: () =>
                              this.setState(() => this.bytes = Uint8List(0)),
                        ),
                        RaisedButton(
                          child: Text(
                            'Generate',
                            style: TextStyle(fontSize: 15, color: Colors.teal),
                            textAlign: TextAlign.left,
                          ),
                          onPressed: onPressed,
                        ),

                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(height: 2, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
