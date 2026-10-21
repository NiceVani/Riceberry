# 🌾 Rice Mill & Inventory Management System
**ระบบบริหารจัดการโรงสีข้าวและคลังสินค้าอัจฉริยะ**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)

แอปพลิเคชันสำหรับบริหารจัดการธุรกิจโรงสีข้าวขนาดย่อม ช่วยบันทึกการรับซื้อ-ขายสินค้า จัดการสต๊อกข้าวแบบ Real-time และสรุปยอดการเงินเพื่อลดข้อผิดพลาดในการทำงาน

---

## ✨ ฟีเจอร์หลัก (Core Features)

*   📊 **Smart Dashboard:** สรุปยอดรายรับ รายจ่าย กำไร และแสดงกิจกรรม 5 รายการล่าสุด กรองข้อมูลตาม วัน/เดือน/ปี ได้ทันที
*   🛒 **Transaction Management:** ระบบบันทึกรับซื้อและขายสินค้า พร้อมคำนวณยอดเงินและบันทึกลงฐานข้อมูล
*   📦 **Real-time Inventory:** อัปเดตยอดสต๊อกสินค้าเข้า-ออกทันทีที่มีการทำรายการ ป้องกันปัญหาสินค้าคลาดเคลื่อน
*   🔄 **Automated Rollback System:** ระบบยกเลิกบิล (Void) ที่จะคำนวณและคืนค่ายอดสต๊อกข้าวกลับเข้าคลังให้อัตโนมัติก่อนลบประวัติการเงิน

---

## 📸 หน้าจอการใช้งาน (Screenshots)
*(นำรูปลากมาวางทับลิงก์ด้านล่างนี้ได้เลย หรืออัปโหลดรูปหน้าจอแอปไปที่โฟลเดอร์ `assets/`)*

| Dashboard | รับซื้อ/ขาย | คลังสินค้า |
| :---: | :---: | :---: |
| <img src="ใส่ลิงก์รูปภาพหน้าจอ1ตรงนี้" width="200"/> | <img src="ใส่ลิงก์รูปภาพหน้าจอ2ตรงนี้" width="200"/> | <img src="ใส่ลิงก์รูปภาพหน้าจอ3ตรงนี้" width="200"/> |

---

## 🛠 สิ่งที่ต้องมีก่อนติดตั้ง (Prerequisites)

*   **Flutter SDK:** เวอร์ชัน 3.x ขึ้นไป
*   **Device/Emulator:** โทรศัพท์มือถือ Android/iOS หรือ Emulator สำหรับรันแอปพลิเคชัน
*   **Database:** บัญชี Supabase ที่สร้างโปรเจกต์และตารางข้อมูลเรียบร้อยแล้ว

---

## 🚀 ขั้นตอนการติดตั้งและใช้งาน

### 1. โคลนโปรเจกต์ (Clone Repository)
```bash
git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
cd your-repo-name ```

2. ติดตั้ง Packages
```bash
flutter pub get 
3. ตั้งค่า API Key (Configuration)
สร้างไฟล์ app_config.dart ไว้ในโฟลเดอร์ lib/ (หรือ lib/config/) และนำ URL กับ Anon Key จากหน้า Dashboard ของ Supabase มาใส่:

Dart
class AppConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
}
⚠️ ข้อควรระวัง: ห้าม Commit ไฟล์นี้ลง GitHub เด็ดขาด ให้ตรวจสอบว่ามีการเพิ่มลงใน .gitignore แล้ว

4. เตรียมข้อมูลตั้งต้น (Initial Data)
เพื่อให้แอปพลิเคชันเปิดใช้งานได้โดยไม่มีข้อผิดพลาด (Null Error) ต้องรันคำสั่ง SQL นี้ใน SQL Editor ของ Supabase เพื่อสร้างข้อมูลพื้นฐาน:

SQL
-- กำหนดหมวดหมู่รายรับและรายจ่าย
INSERT INTO financial_category (category_id, name) VALUES (1, 'รายรับ'), (2, 'รายจ่าย');

-- เพิ่มสินค้าตั้งต้นในคลังอย่างน้อย 1 รายการ
INSERT INTO product_inventory (product_id, name, quantity_in_stock) VALUES (1, 'ข้าวเปลือก', 0);
5. รันแอปพลิเคชัน
Bash
flutter run
👨‍💻 ผู้จัดทำ
วณิชยา พันธ์สอาด

รหัสนิสิต: 67317347

สถาบัน: (ใส่ชื่อภาควิชาและมหาวิทยาลัยของคุณ)


<FollowUp>ต้องการให้ปรับแก้การใช้สี หรือเพิ่มส่วนอธิบายโครงสร้างฐานข้อมูล (Database Schema) ลงใน README ด้วยไหมครับ?</FollowUp>

<ElicitationsGroup>
  <Elicitation>ขอเพิ่มส่วนอธิบายโครงสร้าง Database Schema ด้วย</Elicitation>
  <Elicitation>อยากได้โค้ด SQL สำหรับสร้างตารางทั้งหมดไว้ในนี้เลย</Elicitation>
  <Elicitation>สวยมากครับ ก๊อปปี้ไปใช้งานได้เลย</Elicitation>
</ElicitationsGroup>