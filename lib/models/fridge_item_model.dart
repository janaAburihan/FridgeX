class FridgeItemModel {
  int? id;
  String name;
  final String source;

  FridgeItemModel({
    this.id,
    required this.name,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'source': source,
    };
  }

  factory FridgeItemModel.fromMap(Map<String, dynamic> map) {
    return FridgeItemModel(
      id: map['id'],
      name: map['name'],
      source: map['source'],
      );
  }
}
