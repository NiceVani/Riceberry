import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_inventory_model.dart';
import '../services/api_service.dart';
import 'add_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiService _apiService = ApiService();
  List<ProductInventoryModel> _products = [];
  String _searchQuery = ''; // <-- ตัวแปรที่แจ้ง Error อยู่ตรงนี้ครับ
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  // ฟังก์ชันดึงข้อมูลจาก Supabase
  Future<void> _fetchInventory() async {
    final products = await _apiService.fetchProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  // ฟังก์ชันกรองข้อมูลสินค้าตามคำค้นหา
  List<ProductInventoryModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // ป้องกันหน้าจอพังเวลาคีย์บอร์ดเด้งขึ้นมาบัง
      resizeToAvoidBottomInset: false,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // สั่งให้เปิดหน้า AddProductScreen และรอรับผลลัพธ์ว่าบันทึกสำเร็จหรือไม่ (result)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          // ถ้ารับค่ากลับมาเป็น true (บันทึกสำเร็จ) ให้เรียกฟังก์ชันโหลดข้อมูลคลังสินค้าใหม่ทันที
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('เพิ่มสินค้าสำเร็จ!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            _fetchInventory();
          }
        },
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        label: const Text(
          'เพิ่มสินค้า',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'คลังสินค้า',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),

            // ช่องค้นหาสินค้า
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'ค้นหาชื่อสินค้า...',
                  hintStyle: const TextStyle(color: AppTheme.textLight),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.primaryPurple,
                    size: 28,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                    borderSide: const BorderSide(
                      color: AppTheme.primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // รายการสินค้า
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryPurple,
                      ),
                    )
                  : _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'ไม่พบสินค้าที่ค้นหา',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textLight,
                        ),
                      ),
                    )
                  : ListView.builder(
                      // เปลี่ยนมาใช้ .only เพื่อเจาะจงระยะแต่ละด้าน
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 8.0,
                        bottom:
                            80.0, // เพิ่มระยะด้านล่าง 80 พิกเซลเพื่อดันให้พ้นปุ่ม
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final bool isLowStock = product.quantityInStock < 50;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isLowStock
                                  ? AppTheme.dangerOrange
                                  : AppTheme.borderLight,
                              width: isLowStock ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // ส่วนที่ 1: ชื่อสินค้าและสถานะ
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isLowStock
                                            ? 'สินค้าใกล้หมด!'
                                            : 'พร้อมขาย',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isLowStock
                                              ? AppTheme.dangerOrange
                                              : AppTheme.successGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // ส่วนที่ 2: ตัวเลขจำนวนและหน่วย (จัดเองไม่ง้อ ListTile)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${product.quantityInStock}',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: isLowStock
                                            ? AppTheme.dangerOrange
                                            : AppTheme.primaryPurple,
                                      ),
                                    ),
                                    Text(
                                      product.unitId == 2 ? 'แพ็ค' : 'กิโลกรัม',
                                      style: const TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
