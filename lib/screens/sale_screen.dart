import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_inventory_model.dart';
import '../services/api_service.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({Key? key}) : super(key: key);

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  List<ProductInventoryModel> _products = [];
  bool _isLoading = true;

  // ตัวแปรเก็บค่าจากฟอร์ม
  String? _customerName;
  ProductInventoryModel? _selectedProduct;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ฟังก์ชันแสดงหน้าต่างยืนยันก่อนบันทึก
  Future<void> _showConfirmationDialog({
    required String title,
    required String summaryText,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // บังคับให้ต้องกดปุ่ม ยกเลิก หรือ ยืนยัน เท่านั้น (กดพื้นที่ว่างเพื่อปิดไม่ได้)
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryPurple,
                size: 32,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          content: Text(
            summaryText,
            style: const TextStyle(
              fontSize: 20,
              color: AppTheme.textDark,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          actions: <Widget>[
            Row(
              children: [
                // 1. ปุ่มยืนยัน (สลับมาไว้ด้านซ้าย)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // ปิดหน้าต่างก่อน
                        onConfirm(); // รันโค้ดบันทึก
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ยืนยันบันทึก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12), // ระยะห่างตรงกลาง
                // 2. ปุ่มยกเลิก (สลับมาไว้ด้านขวา)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // ปิดหน้าต่าง
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppTheme.primaryPurple,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ดึงรายการสินค้ามาแสดงใน Dropdown
  Future<void> _fetchProducts() async {
    final products = await _apiService.fetchProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  // คำนวณยอดรวมอัตโนมัติ
  void _calculateTotal() {
    final int qty = int.tryParse(_qtyController.text) ?? 0;
    final double price = double.tryParse(_priceController.text) ?? 0.0;
    setState(() {
      _totalAmount = qty * price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPurple),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'บันทึกขายข้าว',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 1. ชื่อลูกค้า
                      _buildLabel('ชื่อลูกค้า / ผู้ซื้อ'),
                      TextFormField(
                        style: const TextStyle(fontSize: 20),
                        decoration: _inputDecoration(
                          'เช่น ร้านป้าแจ๋ว, คุณสมศักดิ์',
                        ),
                        onSaved: (value) => _customerName = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'กรุณากรอกชื่อลูกค้า'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // 2. เลือกสินค้า
                      _buildLabel('สินค้าที่ขาย'),
                      DropdownButtonFormField<ProductInventoryModel>(
                        decoration: _inputDecoration('เลือกสินค้า...'),
                        isExpanded: true,
                        items: _products.map((product) {
                          return DropdownMenuItem(
                            value: product,
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProduct = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'กรุณาเลือกสินค้า' : null,
                      ),
                      const SizedBox(height: 16),

                      // 3. จำนวน และ ราคาต่อหน่วย (แบ่งครึ่งจอ)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('จำนวน'),
                                TextFormField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 20),
                                  decoration: _inputDecoration('0'),
                                  onChanged: (_) => _calculateTotal(),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'ระบุจำนวน'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('ราคา/หน่วย (บาท)'),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 20),
                                  decoration: _inputDecoration('0.00'),
                                  onChanged: (_) => _calculateTotal(),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'ระบุราคา'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 4. สรุปยอดรวม (กรอบสีเขียวเพื่อให้ดูเป็นรายรับ)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.successGreen),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ราคารวมทั้งสิ้น',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '฿ ${_totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 5. ปุ่มบันทึกขนาดใหญ่
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // 1. เช็กว่ากรอกข้อมูลครบไหม
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              // 2. เด้งหน้าต่างแจ้งเตือนขึ้นมาถามก่อนเลย!
                              _showConfirmationDialog(
                                title: 'ยืนยันการบันทึก',
                                summaryText:
                                    'ต้องการบันทึกข้อมูลการขายนี้ใช่หรือไม่?\n\n'
                                    'ยอดเงินรวม: ฿${_totalAmount.toStringAsFixed(2)}',

                                // 3. ถ้าคุณลุงกด "ยืนยัน" ค่อยรันโค้ดบันทึกข้อมูลของเดิม
                                onConfirm: () async {
                                  // --- เริ่มโค้ดบันทึกเดิมของคุณ ---
                                  // แสดงวงกลมโหลดข้อมูล
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  // เรียกใช้งาน ApiService
                                  final success = await _apiService.insertSale(
                                    customerName: _customerName!,
                                    productId: _selectedProduct!.id,
                                    quantity: int.parse(_qtyController.text),
                                    unitPrice: double.parse(
                                      _priceController.text,
                                    ),
                                    totalAmount: _totalAmount,
                                  );

                                  // ปิดวงกลมโหลดข้อมูล
                                  Navigator.pop(context);

                                  if (success) {
                                    // ล้างฟอร์ม
                                    _formKey.currentState!.reset();
                                    _qtyController.clear();
                                    _priceController.clear();
                                    setState(() {
                                      _selectedProduct = null;
                                      _totalAmount = 0.0;
                                    });
                                    // แจ้งเตือนสำเร็จ
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('บันทึกการขายสำเร็จ!'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  } else {
                                    // แจ้งเตือนข้อผิดพลาด
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'เกิดข้อผิดพลาดในการบันทึก',
                                        ),
                                        backgroundColor: AppTheme.dangerOrange,
                                      ),
                                    );
                                  }
                                  // --- จบโค้ดบันทึกเดิมของคุณ ---
                                },
                              );
                            }
                          },
                          // ตกแต่งปุ่ม
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'บันทึกการขาย',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ), // เผื่อระยะด้านล่างกันแถบเมนูบัง
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // วิดเจ็ตช่วยสร้างข้อความ Label ให้เป็นมาตรฐานเดียวกัน
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

  // รูปแบบช่องกรอกข้อมูล (InputDecoration)
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
