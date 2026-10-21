class UnitModel {
  final int id;
  final String name;

  UnitModel({required this.id, required this.name});

  // แปลงข้อมูลจากฐานข้อมูล (JSON) มาเป็น Object ในแอป
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(id: json['unit_id'] ?? 0, name: json['unit_name'] ?? '');
  }

  // แปลง Object กลับเป็น JSON เพื่อส่งไปบันทึก
  Map<String, dynamic> toJson() {
    return {'unit_name': name};
  }
}
