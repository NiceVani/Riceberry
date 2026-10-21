import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/supplier_model.dart';

class ManageSupplierScreen extends StatefulWidget {
  const ManageSupplierScreen({Key? key}) : super(key: key);

  @override
  State<ManageSupplierScreen> createState() => _ManageSupplierScreenState();
}

class _ManageSupplierScreenState extends State<ManageSupplierScreen> {
  final ApiService _apiService = ApiService();
  List<SupplierModel> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  // โหลดข้อมูลเกษตรกร
  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    final suppliers = await _apiService.fetchSuppliers();
    setState(() {
      _suppliers = suppliers;
      _isLoading = false;
    });
  }

  // ป๊อปอัปสำหรับพิมพ์ชื่อเกษตรกรใหม่
  Future<void> _showAddDialog() async {
    final TextEditingController nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'เพิ่มชื่อเกษตรกร',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'ชื่อ-นามสกุล',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontSize: 18, color: AppTheme.textLight),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.pop(context); // ปิดป๊อปอัป

                  // สั่งบันทึกลงฐานข้อมูล
                  bool success = await _apiService.addSupplier(
                    name: nameController.text.trim(),
                  );
                  if (success) {
                    _fetchSuppliers(); // โหลดข้อมูลใหม่มาโชว์
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
              ),
              child: const Text(
                'บันทึก',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ป๊อปอัปยืนยันการลบ
  Future<void> _showDeleteConfirm(SupplierModel supplier) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'ยืนยันการลบ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.dangerOrange,
            ),
          ),
          content: Text(
            'คุณต้องการลบรายชื่อ "${supplier.name}" ใช่หรือไม่?',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontSize: 18, color: AppTheme.textLight),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // ปิดป๊อปอัป

                // สั่งลบจากฐานข้อมูล (เช็กชื่อตัวแปร id ใน SupplierModel ของคุณด้วยนะครับ)
                bool success = await _apiService.deleteSupplier(supplier.id);
                if (success) {
                  _fetchSuppliers(); // โหลดข้อมูลใหม่มาโชว์
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerOrange,
              ),
              child: const Text(
                'ลบข้อมูล',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'จัดการรายชื่อเกษตรกร',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            )
          : Column(
              children: [
                Expanded(
                  child: _suppliers.isEmpty
                      ? const Center(
                          child: Text(
                            'ยังไม่มีรายชื่อเกษตรกร',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textLight,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _suppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = _suppliers[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: AppTheme.borderLight,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  supplier.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppTheme.dangerOrange,
                                    size: 28,
                                  ),
                                  onPressed: () => _showDeleteConfirm(
                                    supplier,
                                  ), // กดปุ่มถังขยะเพื่อลบ
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // ปุ่มเพิ่มข้อมูลขนาดใหญ่ด้านล่าง
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'เพิ่มเกษตรกรใหม่',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
