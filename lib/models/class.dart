import 'package:students/models/attendance.dart';

class Class{
String name;
 String id;
 String division;
List<Attendance> attendaceList = []; // store only id of attendace on firebase
Class({this.name,this.id,this.attendaceList,this.division});
}