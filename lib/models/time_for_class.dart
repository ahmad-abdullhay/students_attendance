import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeForClass {
  TimeOfDay startTime;
  TimeOfDay endTime;
  int day;

  TimeForClass({this.startTime, this.endTime, this.day});

  factory TimeForClass.fromDocument(DocumentSnapshot doc) {
    Timestamp s = doc['start'];
    Timestamp e = doc['end'];
    DateTime sd = s.toDate();
    DateTime ed = e.toDate();
    int d = doc['day'];

    return TimeForClass(
        day: d,
        startTime: TimeOfDay.fromDateTime(sd),
        endTime: TimeOfDay.fromDateTime(ed));
  }
}
