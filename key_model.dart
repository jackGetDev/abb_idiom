class IdiomModel {
  final String key;
  final List<String> values;

  IdiomModel({required this.key, required this.values});

factory IdiomModel.fromJson(Map<String, dynamic> json) {
  return IdiomModel(
    key: json['key'] as String,
    values: List<String>.from(json['values']),
  );
}
}
