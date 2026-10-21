import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/unit_model.dart';

class ApiService {
  final _supabase = Supabase.instance.client;

  // ฟังก์ชันดึงข้อมูลหน่วยนับทั้งหมด
  Future<List<UnitModel>> fetchUnits() async {
    try {
      final response = await _supabase
          .from('unit')
          .select(); // ดึงจากตาราง Unit
      return (response as List).map((e) => UnitModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching units: $e');
      return [];
    }
  }
}
