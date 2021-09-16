import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:students/models/class.dart';

class StudentUser {
  String firebaseID;
  String id;
  String name;
  String email;
  String phoneNumber;
  String level;
  List<Class> classesList = [];
  StudentUser({this.id, this.name, this.email, this.phoneNumber, this.level,this.classesList,this.firebaseID});

  factory StudentUser.fromDocument(DocumentSnapshot doc,String firebaseID,List<Class>classesList ) {
    return StudentUser(
        name: doc['Name'],
        id: doc['UserId'],
        email: doc['Email'],
        level: doc['Level'],
        phoneNumber: doc['PhoneNumber'],
        classesList:classesList,
        firebaseID: firebaseID
        );
  }
}
