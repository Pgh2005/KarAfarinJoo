import 'package:flutter/foundation.dart';

@immutable
class PersonalInfoModel {
  final String? id;
  final String classId;
  final String studentId;
  final String firstName;
  final String lastName;
  final String contact;
  final String neighborhood;
  final String major;
  final String degree;
  final String satisfiedMajor;
  final String majorReason;
  final String ifReturn;
  final String businessTitle;
  final String businessSatisfied;
  final String businessSlogan;
  final String lifeSlogan;
  final String valueOrientation;
  final String rank;
  final String score;

  const PersonalInfoModel({
    this.id,
    required this.classId,
    required this.studentId,
    this.firstName = '',
    this.lastName = '',
    this.contact = '',
    this.neighborhood = '',
    this.major = '',
    this.degree = 'کارشناسی',
    this.satisfiedMajor = 'بله',
    this.majorReason = '',
    this.ifReturn = '',
    this.businessTitle = '',
    this.businessSatisfied = 'تا حدی',
    this.businessSlogan = '',
    this.lifeSlogan = '',
    this.valueOrientation = 'علم',
    this.rank = '',
    this.score = '',
  });

  PersonalInfoModel copyWith({
    String? id,
    String? classId,
    String? studentId,
    String? firstName,
    String? lastName,
    String? contact,
    String? neighborhood,
    String? major,
    String? degree,
    String? satisfiedMajor,
    String? majorReason,
    String? ifReturn,
    String? businessTitle,
    String? businessSatisfied,
    String? businessSlogan,
    String? lifeSlogan,
    String? valueOrientation,
    String? rank,
    String? score,
  }) {
    return PersonalInfoModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      contact: contact ?? this.contact,
      neighborhood: neighborhood ?? this.neighborhood,
      major: major ?? this.major,
      degree: degree ?? this.degree,
      satisfiedMajor: satisfiedMajor ?? this.satisfiedMajor,
      majorReason: majorReason ?? this.majorReason,
      ifReturn: ifReturn ?? this.ifReturn,
      businessTitle: businessTitle ?? this.businessTitle,
      businessSatisfied: businessSatisfied ?? this.businessSatisfied,
      businessSlogan: businessSlogan ?? this.businessSlogan,
      lifeSlogan: lifeSlogan ?? this.lifeSlogan,
      valueOrientation: valueOrientation ?? this.valueOrientation,
      rank: rank ?? this.rank,
      score: score ?? this.score,
    );
  }

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      id: json['id'] as String?,
      classId: json['class_id'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      major: json['major'] as String? ?? '',
      degree: json['degree'] as String? ?? 'کارشناسی',
      satisfiedMajor: json['satisfied_major'] as String? ?? 'بله',
      majorReason: json['major_reason'] as String? ?? '',
      ifReturn: json['if_return'] as String? ?? '',
      businessTitle: json['business_title'] as String? ?? '',
      businessSatisfied: json['business_satisfied'] as String? ?? 'تا حدی',
      businessSlogan: json['business_slogan'] as String? ?? '',
      lifeSlogan: json['life_slogan'] as String? ?? '',
      valueOrientation: json['value_orientation'] as String? ?? 'علم',
      rank: json['rank'] as String? ?? '',
      score: json['score'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'class_id': classId,
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'contact': contact,
      'neighborhood': neighborhood,
      'major': major,
      'degree': degree,
      'satisfied_major': satisfiedMajor,
      'major_reason': majorReason,
      'if_return': ifReturn,
      'business_title': businessTitle,
      'business_satisfied': businessSatisfied,
      'business_slogan': businessSlogan,
      'life_slogan': lifeSlogan,
      'value_orientation': valueOrientation,
      'rank': rank,
      'score': score,
    };
  }
}
