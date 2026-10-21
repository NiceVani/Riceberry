import 'package:flutter/material.dart';

class AppTheme {
  // รหัสสีตาม Palette ในภาพอ้างอิง
  static const Color primaryPurple = Color(0xFF4A1D6B); // สีม่วงเข้ม
  static const Color bgCream = Color(0xFFFAF7F2); // สีพื้นหลังครีม
  static const Color accentGold = Color(0xFFE8A317); // สีทอง
  static const Color successGreen = Color(0xFF1B7F3B); // สีเขียว (รายรับ)
  static const Color dangerOrange = Color(0xFFC2410C); // สีส้มแดง (รายจ่าย)

  // สีเพิ่มเติมสำหรับตัวอักษรและเส้นขอบ
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color bgWhite = Colors.white;
  static const Color bgLight = Color(0xFFF5F5F5);
  static ThemeData get riceberryTheme {
    return ThemeData(
      scaffoldBackgroundColor: bgCream, // ใช้พื้นหลังสีครีมทั้งแอป
      primaryColor: primaryPurple,
      fontFamily: 'Roboto', // หรือเปลี่ยนเป็นฟอนต์ Prompt/Noto Sans Thai
      // 1. แถบนำทางด้านบน (AppBar)
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCream,
        foregroundColor: primaryPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryPurple,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: primaryPurple, size: 32),
      ),

      // 2. การตั้งค่าตัวอักษร (TextTheme)
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 18, color: textDark),
        bodyLarge: TextStyle(
          fontSize: 20,
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: 28,
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 3. การตั้งค่าปุ่มกด (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: bgWhite,
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // ขอบมนสวยงาม
          ),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      // 4. การตั้งค่าช่องกรอกข้อมูล (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgWhite,
        labelStyle: const TextStyle(fontSize: 18, color: textLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryPurple,
            width: 2.5,
          ), // เน้นขอบสีม่วงเวลาพิมพ์
        ),
      ),

      // 5. การตั้งค่า Card (กล่องข้อมูล)
      cardTheme: const CardThemeData(
        color: bgWhite,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ), // กล่องขอบมนโค้งตามแบบ
          side: const BorderSide(
            color: borderLight,
            width: 1,
          ), // เส้นขอบบางๆ สไตล์มินิมอล
        ),
      ),
    );
  }
}
