import 'package:flutter/foundation.dart';

@immutable
class TalentRowModel {
  final String rank;
  final String title;
  final String description;

  const TalentRowModel({
    required this.rank,
    required this.title,
    required this.description,
  });

  factory TalentRowModel.empty(int index) {
    return TalentRowModel(rank: '${index + 1}', title: '', description: '');
  }

  factory TalentRowModel.fromJson(Map<String, dynamic> json) {
    return TalentRowModel(
      rank: (json['rank'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'rank': rank, 'title': title, 'description': description};
  }

  TalentRowModel copyWith({String? rank, String? title, String? description}) {
    return TalentRowModel(
      rank: rank ?? this.rank,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

@immutable
class TalentModel {
  final String classId;
  final String studentId;
  final String highestCategory;
  final String lowestTalent;
  final String twoDimType;
  final String fourDimType;
  final String bestTeam;
  final List<TalentRowModel> rows;

  const TalentModel({
    required this.classId,
    required this.studentId,
    required this.highestCategory,
    required this.lowestTalent,
    required this.twoDimType,
    required this.fourDimType,
    required this.bestTeam,
    required this.rows,
  });

  factory TalentModel.empty({
    required String classId,
    required String studentId,
  }) {
    return TalentModel(
      classId: classId,
      studentId: studentId,
      highestCategory: '',
      lowestTalent: '',
      twoDimType: '',
      fourDimType: '',
      bestTeam: '',
      rows: List.generate(5, TalentRowModel.empty),
    );
  }

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'];

    List<TalentRowModel> parsedRows = [];
    if (rawRows is List) {
      parsedRows = rawRows
          .whereType<Map>()
          .map(
            (item) => TalentRowModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (parsedRows.length < 5) {
      parsedRows = [
        ...parsedRows,
        ...List.generate(5 - parsedRows.length, (index) {
          return TalentRowModel.empty(parsedRows.length + index);
        }),
      ];
    }

    return TalentModel(
      classId: (json['class_id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      highestCategory: (json['highest_category'] ?? '').toString(),
      lowestTalent: (json['lowest_talent'] ?? '').toString(),
      twoDimType: (json['two_dim_type'] ?? '').toString(),
      fourDimType: (json['four_dim_type'] ?? '').toString(),
      bestTeam: (json['best_team'] ?? '').toString(),
      rows: parsedRows.take(5).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'student_id': studentId,
      'highest_category': highestCategory,
      'lowest_talent': lowestTalent,
      'two_dim_type': twoDimType,
      'four_dim_type': fourDimType,
      'best_team': bestTeam,
      'rows': rows.map((e) => e.toJson()).toList(),
    };
  }

  TalentModel copyWith({
    String? classId,
    String? studentId,
    String? highestCategory,
    String? lowestTalent,
    String? twoDimType,
    String? fourDimType,
    String? bestTeam,
    List<TalentRowModel>? rows,
  }) {
    return TalentModel(
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      highestCategory: highestCategory ?? this.highestCategory,
      lowestTalent: lowestTalent ?? this.lowestTalent,
      twoDimType: twoDimType ?? this.twoDimType,
      fourDimType: fourDimType ?? this.fourDimType,
      bestTeam: bestTeam ?? this.bestTeam,
      rows: rows ?? this.rows,
    );
  }
}
