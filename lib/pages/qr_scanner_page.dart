import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:students/models/class.dart';
import 'package:students/models/student_user.dart';

class QrScannerPage extends StatefulWidget {
  final StudentUser studentUser;

  const QrScannerPage({Key key, this.studentUser}) : super(key: key);
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  Uint8List bytes = Uint8List(0);
  TextEditingController _outputController;
  bool isLoading;
  @override
  initState() {
    
    super.initState();
    this._outputController = new TextEditingController();
  }
  // 15 minute in release
  int lateMinutes = 1150000;
  // 50 in release
  double distanceRange = 50000000;
  Class classModel;
  bool isScanned = false;
  bool isWaiting = false;
  String message = 'Dont Forget scanning the code to verify your attendacne';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: SafeArea(
        child: Center(
          child: ModalProgressHUD(
            inAsyncCall: isWaiting,
                      child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: _scan,
                  child: Text('Open Camera To Scan'),
                ),
                SizedBox(
                  height: 100,
                ),
                isScanned
                    ? Card(
                        color: Colors.green,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Attendacnce verified',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.white),
                              ),
                              Icon(
                                Icons.check,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                classModel.name,
                                style:
                                    TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _scan() async {
    String barcode = await scanner.scan();
    this._outputController.text = barcode;
    scanCheck(
       barcode);
  }

  Future<bool> timeAndLocationCheck(String time, String location) async {
    bool isInTime = false;
    bool isAtLocation = false;
    isAtLocation = await locationCheck(location);
    isInTime = timeCheck(time);
    if (isAtLocation && isInTime)
      return true;
    else
      return false;
  }

  Future<bool> locationCheck(String location) async {
    List<String> locationSplit = location.split(',');
    double endLatitude = double.parse(locationSplit[0]);
    double endLongitude = double.parse(locationSplit[1]);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude, endLatitude, endLongitude);

    if (distance < distanceRange) return true;
    return false;
  }

  bool timeCheck(String time) {
    var now = DateTime.now();
   var parsedTime  = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(time);
    if (now.isBefore(parsedTime.add(Duration(minutes: lateMinutes))))
      return true;
    return false;
  }

  Future<bool> addAttendance(String attendacneID, classID) async {
    // find class
    Class classModel;
    for (Class c in widget.studentUser.classesList) {
      if (c.id == classID) {
        classModel = c;
        break;
      }
    }
    if (classModel == null) return false;

    this.classModel = classModel;
     final attendance =
          FirebaseFirestore.instance.collection('attendance').doc(attendacneID);
if (attendance == null) return false;
          var doc = await attendance.get();
          if (doc == null) return false;
      List<String> studentsArray = doc['studentsArray'].cast<String>();
    studentsArray.add(widget.studentUser.firebaseID);
  //  if (!attendance.studentsList.contains(widget.studentUser.firebaseID)) {

   //   attendance.studentsList.add(widget.studentUser.firebaseID);
      final userRef = FirebaseFirestore.instance.collection('attendance');
      await userRef.doc(attendacneID).update({
        "studentsArray":studentsArray,
      });
   // }
    return true;
  }

  Future<void> scanCheck(String code) async {
    print(code);
    for (Class c in widget.studentUser.classesList)
    print(c.id);
    setState(() {
      isWaiting = true;
      isScanned = false;
    });
    List<String> splitCode = code.split('@');
    
    if (splitCode.length == 4) {
      String attendanceId = splitCode[0];
      String classId = splitCode[1];
      String time = splitCode[2];
      String location = splitCode[3];
      if (await timeAndLocationCheck(time, location)) {
        if (await addAttendance(attendanceId, classId)) {
          setState(() {
            isScanned = true;
                  isWaiting = false;

          });
        } else {
           setState(() {
          message =
              'This class is not on your classes list';
               isWaiting = false;
        });
        }
      } else {
        setState(() {
          message =
              'Sorry you are too late or too far from the QR code location';
               isWaiting = false;
        });
      }
    } else {
      setState(() {
        message = 'Not University QR code please Scan Another QR Code';
         isWaiting = false;
      });
    }
  }
}
