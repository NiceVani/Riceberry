import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/unit_model.dart';
import '../models/product_inventory_model.dart'; // อย่าลืม import model สินค้า

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // ตัวแปรสำหรับฟอร์มสร้างสินค้าใหม่
  String? _productName;
  int? _selectedUnitId;

  // ตัวควบคุมช่องกรอกจำนวน (ใช้ร่วมกันทั้ง 2 โหมด)
  final TextEditingController _qtyController = TextEditingController(text: '0');

  List<UnitModel> _units = [];
  List<ProductInventoryModel> _products = [];
  bool _isLoading = true;

  // *** ตัวแปรสำคัญ: ถ้าเป็น null แปลว่าผู้ใช้เลือก "เพิ่มสินค้าใหม่"
  ProductInventoryModel? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  // ดึงทั้งข้อมูลหน่วย และข้อมูลสินค้าเดิม มาพร้อมกัน
  Future<void> _fetchData() async {
    final units = await _apiService.fetchUnits();
    final products = await _apiService.fetchProducts();

    setState(() {
      _units = units;
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // เช็กว่ากำลังอยู่ในโหมดสร้างของใหม่ใช่หรือไม่? (ถ้า _selectedProduct เป็น null คือสร้างใหม่)
    bool isCreatingNew = _selectedProduct == null;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'จัดการสต๊อก / สินค้า',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPurple),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Dropdown เลือกรูปแบบ (สร้างใหม่ หรือ เลือกของเดิม)
                      _buildLabel('เลือกรายการสินค้า'),
                      DropdownButtonFormField<ProductInventoryModel?>(
                        value: _selectedProduct,
                        decoration: _inputDecoration('เลือกสินค้า...'),
                        isExpanded: true,
                        items: [
                          // ตัวเลือกที่ 1: สำหรับสร้างสินค้าใหม่
                          const DropdownMenuItem<ProductInventoryModel?>(
                            value: null,
                            child: Text(
                              '+ เพิ่มสินค้าชนิดใหม่',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // ตัวเลือกที่เหลือ: ดึงจากฐานข้อมูล
                          ..._products.map((product) {
                            return DropdownMenuItem<ProductInventoryModel?>(
                              value: product,
                              child: Text(
                                product.name,
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedProduct = value;
                            _qtyController.text =
                                '0'; // รีเซ็ตตัวเลขทุกครั้งที่เปลี่ยนโหมด
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // 2. ส่วนที่จะแสดง "เฉพาะตอนเลือกเพิ่มสินค้าชนิดใหม่" เท่านั้น
                      if (isCreatingNew) ...[
                        _buildLabel('ชื่อสินค้าใหม่'),
                        TextFormField(
                          style: const TextStyle(fontSize: 18),
                          decoration: _inputDecoration(
                            'เช่น ข้าวหอมมะลิ 105 เกรด A',
                          ),
                          onSaved: (value) => _productName = value,
                          validator: (value) =>
                              isCreatingNew && (value == null || value.isEmpty)
                              ? 'กรุณากรอกชื่อสินค้า'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('หน่วยวัด'),
                        DropdownButtonFormField<int>(
                          decoration: _inputDecoration('เลือกหน่วย'),
                          isExpanded: true,
                          items: _units.map((unit) {
                            return DropdownMenuItem<int>(
                              value: unit.id,
                              child: Text(
                                unit.name,
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedUnitId = value),
                          validator: (value) => isCreatingNew && value == null
                              ? 'กรุณาเลือกหน่วยวัด'
                              : null,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 3. ช่องกรอกจำนวน (ใช้ร่วมกันทั้ง 2 โหมด)
                      _buildLabel(
                        isCreatingNew
                            ? 'ยอดยกมาเริ่มต้น'
                            : 'จำนวนที่ต้องการเพิ่มในสต๊อก',
                      ),
                      TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: _inputDecoration('0'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'กรุณาระบุจำนวน'
                            : null,
                      ),
                      const SizedBox(height: 40),

                      // 4. ปุ่มบันทึก
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              bool success = false;
                              final int qty =
                                  int.tryParse(_qtyController.text) ?? 0;

                              if (isCreatingNew) {
                                // โหมด 1: บันทึกสินค้าใหม่
                                success = await _apiService.addProduct(
                                  product_name: _productName!,
                                  description: '', // ส่งค่าว่างไปเผื่อไว้
                                  unitId: _selectedUnitId!,
                                  initialStock: qty,
                                );
                              } else {
                                // โหมด 2: เพิ่มสต๊อกสินค้าเดิม
                                success = await _apiService
                                    .addStockToExistingProduct(
                                      productId: _selectedProduct!
                                          .id, // เช็กชื่อตัวแปร id ใน ProductInventoryModel ของคุณ
                                      addedQuantity: qty,
                                    );
                              }

                              Navigator.pop(context); // ปิดวงกลมโหลด

                              if (success) {
                                Navigator.pop(
                                  context,
                                  true,
                                ); // กลับไปหน้าคลังสินค้า พร้อมสั่งให้รีเฟรช
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('เกิดข้อผิดพลาดในการบันทึก'),
                                    backgroundColor: AppTheme.dangerOrange,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isCreatingNew
                                ? 'บันทึกรายการสินค้าใหม่'
                                : 'อัปเดตสต๊อก',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textLight),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
      ),
    );
  }
}
