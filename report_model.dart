


import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final Timestamp id;
  final String num;
  final String description;

  final double onHim;
  final double forHim;


  Report({
    required this.id,
    required this.num,
    required this.description,

    required this.onHim,
    required this.forHim,

  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      num: map['num'].toString(),
      description: map['description'],
      onHim: double.parse(map['onhim'].toString()),
      forHim:double.parse(map['forhim'].toString()),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'num': num,
      'description':description,
      'onhim': onHim,
      'forhim': forHim,
    };
  }
}

