import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  // บังคับให้ Flutter เตรียมความพร้อม Widget ก่อนรันแอป (จำเป็นสำหรับการเรียกใช้ await ใน main)
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่าและเชื่อมต่อฐานข้อมูล Supabase ตั้งแต่เริ่มเปิดแอปพลิเคชัน
  await Supabase.initialize(
    url: 'https://efjwomtfksfpqniordys.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmandvbXRma3NmcHFuaW9yZHlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTExNzQyNjAsImV4cCI6MjEwNjc1MDI2MH0.gCV_-MtJTdkfc-uN23bFPn9o0KjaeqAa_i6Nx8d9i7g', // <-- เอา Key จาก Supabase มาใส่ตรงนี้
  );

  runApp(const RiceberryFactoryApp());
}

class RiceberryFactoryApp extends StatelessWidget {
  const RiceberryFactoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riceberry Factory',
      debugShowCheckedModeBanner:
          false, // เอาป้าย Debug มุมขวาบนออกเพื่อความสวยงาม
      theme: AppTheme.riceberryTheme, // เรียกใช้ธีม ม่วง-ครีม ที่เราสร้างไว้
      home:
          const DashboardScreen(), // กำหนดให้เปิดแอปมาเจอหน้า Dashboard เป็นหน้าแรก
    );
  }
}
