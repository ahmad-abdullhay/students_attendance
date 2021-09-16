import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:students/models/attendance.dart';
import 'package:students/models/class.dart';
import 'package:students/models/student_user.dart';
import 'package:students/pages/Register_page.dart';

class AttendancePage extends StatefulWidget {
  final StudentUser studentUser;

  const AttendancePage({Key key, this.studentUser}) : super(key: key);
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
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
   Future<List<Class>> getStudentCLasses( DocumentSnapshot doc) async {
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
  Future<void> getAttendance() async {
     DocumentSnapshot doc = await userRef.doc(widget.studentUser.firebaseID).get();
   widget.studentUser.classesList = await getStudentCLasses( doc);
    
    setState(() {
      isLoading = false;
    });
  }
  @override
  void initState() {
    getAttendance();
    super.initState();
  }
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Attendace List'),
        ),
        body: isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.studentUser.classesList.length,
            itemBuilder: (BuildContext context, int index) {
              return AttendanceListTile(
                classModel: widget.studentUser.classesList[index],
                studentUser: widget.studentUser,
              );
            },
          ),
        ));
  }
}

class AttendanceListTile extends StatefulWidget {
  final Class classModel;
  final StudentUser studentUser;
  const AttendanceListTile({Key key, this.classModel, this.studentUser})
      : super(key: key);
  @override
  _AttendanceListTileState createState() => _AttendanceListTileState();
}

class _AttendanceListTileState extends State<AttendanceListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
               decoration: BoxDecoration(border: Border.all
                (
            color: Colors.grey

        )
        ), 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(

                child: Text(
                  widget.classModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                ),
              ),
            ),
            
SizedBox (
            height: 100,
            width: 1,
         child: const DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.grey
    ),
  ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 100,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.classModel.attendaceList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AttendanceCard(
                      classModel: widget.classModel,
                      isAttended: widget
                          .classModel.attendaceList[index].studentsList
                          .contains(
                        widget.studentUser.firebaseID,
                      ),
                      attendace: widget.classModel.attendaceList[index],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final Class classModel;
  final Attendance attendace;
  final bool isAttended;

  const AttendanceCard(
      {Key key, this.classModel, this.attendace, this.isAttended})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: 100,
      height: 100,
      child: Card(
        color: isAttended ? Colors.green : Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(isAttended ? 'Attended' : 'Not Attended'),
            Text(attendace.date),
          ],
        ),
      ),
    );
  }
}
