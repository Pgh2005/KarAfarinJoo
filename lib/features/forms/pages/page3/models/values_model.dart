class ValuesModel {
  final List<String> valuesList;

  ValuesModel({required this.valuesList});

  factory ValuesModel.empty() =>
      ValuesModel(valuesList: List.generate(10, (_) => ''));

  factory ValuesModel.fromJson(Map<String, dynamic> json) {
    final list = (json['values_list'] as List?)?.cast<String>() ?? [];
    final paddedList = List<String>.generate(
      10,
      (i) => i < list.length ? list[i] : '',
    );
    return ValuesModel(valuesList: paddedList);
  }

  Map<String, dynamic> toJson(String studentId, String classId) => {
    'student_id': studentId,
    'class_id': classId,
    'values_list': valuesList,
    'updated_at': DateTime.now().toIso8601String(),
  };

  ValuesModel copyWith({List<String>? valuesList}) {
    return ValuesModel(valuesList: valuesList ?? this.valuesList);
  }
}
