import 'package:supabase_flutter/supabase_flutter.dart';

// นำเข้า Data Models ที่เราเพิ่งสร้างไป
import '../models/unit_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';
import '../models/product_inventory_model.dart';

class ApiService {
  // เรียกใช้งาน Supabase Client
  final _supabase = Supabase.instance.client;

  // ==========================================
  // ส่วนที่ 1: กลุ่ม Master Data (ดึงข้อมูลพื้นฐาน)
  // ==========================================

  // 1. ดึงข้อมูลหน่วยนับทั้งหมด
  Future<List<UnitModel>> fetchUnits() async {
    try {
      // ดึงข้อมูลจากตาราง unit (PostgreSQL มักจะแปลงชื่อตารางเป็นตัวพิมพ์เล็ก)
      final response = await _supabase.from('unit').select();
      return (response as List).map((e) => UnitModel.fromJson(e)).toList();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลหน่วยนับ: $e');
      return [];
    }
  }

  // 2. ดึงข้อมูลหมวดหมู่บัญชีทั้งหมด
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _supabase.from('category').select();
      return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลหมวดหมู่: $e');
      return [];
    }
  }

  // 3. ดึงข้อมูลผู้จำหน่าย/เกษตรกรทั้งหมด
  Future<List<SupplierModel>> fetchSuppliers() async {
    try {
      final response = await _supabase.from('supplier').select();
      return (response as List).map((e) => SupplierModel.fromJson(e)).toList();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลผู้จำหน่าย: $e');
      return [];
    }
  }

  // 4. ดึงข้อมูลสินค้าคงคลังทั้งหมด
  Future<List<ProductInventoryModel>> fetchProducts() async {
    try {
      // เรียงลำดับตาม product_id เพื่อให้ข้อมูลไม่สลับที่กันเวลาดึงใหม่
      final response = await _supabase
          .from('product_inventory')
          .select()
          .order('product_id', ascending: true);
      return (response as List)
          .map((e) => ProductInventoryModel.fromJson(e))
          .toList();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลสินค้า: $e');
      return [];
    }
  }
  // ==========================================
  // ส่วนที่ 2: กลุ่ม Transaction (บันทึกซื้อ-ขาย)
  // ==========================================

  // ฟังก์ชันบันทึกการขายข้าว (รายรับ)
  Future<bool> insertSale({
    required String customerName,
    required int productId,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
  }) async {
    try {
      // 1. บันทึกหัวบิลขาย (Sale Order)
      final saleResponse = await _supabase
          .from('sale_order')
          .insert({'customer_name': customerName, 'total_amount': totalAmount})
          .select()
          .single();

      final saleId = saleResponse['sale_id'];

      // 2. บันทึกรายละเอียดบิล (Sale Detail)
      await _supabase.from('sale_detail').insert({
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
      });

      // 3. ตัดสต๊อกสินค้า (Product Inventory)
      final product = await _supabase
          .from('product_inventory')
          .select('quantity_in_stock')
          .eq('product_id', productId)
          .single();
      final currentQty = product['quantity_in_stock'] as int;
      await _supabase
          .from('product_inventory')
          .update({'quantity_in_stock': currentQty - quantity})
          .eq('product_id', productId);

      // 4. บันทึกลงสมุดบัญชี (รายรับ สมมติให้ category_id = 1)
      await _supabase.from('financial_transaction').insert({
        'category_id': 1,
        'sale_id': saleId,
        'amount': totalAmount,
        'description': 'ขายสินค้าให้ $customerName',
      });

      return true; // บันทึกสำเร็จ
    } catch (e) {
      print('Error insertSale: $e');
      return false; // บันทึกล้มเหลว
    }
  }

  // ฟังก์ชันบันทึกการรับซื้อ (รายจ่าย)
  Future<bool> insertPurchase({
    required int supplierId,
    required int productId,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
  }) async {
    try {
      // 1. บันทึกหัวบิลรับซื้อ
      final purchaseResponse = await _supabase
          .from('purchase_order')
          .insert({'supplier_id': supplierId, 'total_amount': totalAmount})
          .select()
          .single();

      final purchaseId = purchaseResponse['purchase_id'];

      // 2. บันทึกรายละเอียดบิล
      await _supabase.from('purchase_detail').insert({
        'purchase_id': purchaseId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
      });

      // 3. เพิ่มสต๊อกสินค้า
      final product = await _supabase
          .from('product_inventory')
          .select('quantity_in_stock')
          .eq('product_id', productId)
          .single();
      final currentQty = product['quantity_in_stock'] as int;
      await _supabase
          .from('product_inventory')
          .update({'quantity_in_stock': currentQty + quantity})
          .eq('product_id', productId);

      // 4. บันทึกลงสมุดบัญชี (รายจ่าย สมมติให้ category_id = 2)
      await _supabase.from('financial_transaction').insert({
        'category_id': 2,
        'purchase_id': purchaseId,
        'amount': totalAmount,
        'description': 'รับซื้อสินค้าเข้าคลัง',
      });

      return true;
    } catch (e) {
      print('Error insertPurchase: $e');
      return false;
    }
  }

  // ==========================================
  // ส่วนที่ 3: กลุ่ม Dashboard และ สมุดบัญชี
  // ==========================================

  // ฟังก์ชันดึงประวัติการทำธุรกรรมทั้งหมด
  Future<List<Map<String, dynamic>>> fetchFinancialTransactions() async {
    try {
      final response = await _supabase
          .from('financial_transaction')
          .select(
            '*',
          ); // 🌟 ใช้ '*' เพื่อให้ดึงคอลัมน์ id และทุกๆ อย่างมาให้ครบ
      // หรือ .select('id, category_id, amount, description, transaction_date, note')

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  // ฟังก์ชันเพิ่มสินค้าใหม่
  Future<bool> addProduct({
    required String product_name,
    required String description,
    required int unitId,
    required int initialStock,
  }) async {
    try {
      await _supabase.from('product_inventory').insert({
        'product_name': product_name,
        'unit_id': unitId,
        'quantity_in_stock': initialStock,
      });
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // ฟังก์ชันสำหรับเพิ่มจำนวนสต๊อกในสินค้าเดิมที่มีอยู่แล้ว
  Future<bool> addStockToExistingProduct({
    required int productId,
    required int addedQuantity,
  }) async {
    try {
      // 1. ดึงจำนวนสต๊อกปัจจุบันมาก่อน
      final product = await _supabase
          .from('product_inventory')
          .select('quantity_in_stock')
          .eq(
            'product_id',
            productId,
          ) // เช็กชื่อคอลัมน์ PK ในฐานข้อมูล (มักจะเป็น product_id หรือ id)
          .single();

      final currentQty = product['quantity_in_stock'] as int;

      // 2. เอาจำนวนเดิม + จำนวนใหม่ แล้วบันทึกกลับไป
      await _supabase
          .from('product_inventory')
          .update({'quantity_in_stock': currentQty + addedQuantity})
          .eq('product_id', productId);

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  // ==========================================
  // ส่วนที่ 5: จัดการรายชื่อเกษตรกร
  // ==========================================

  // 1. เพิ่มเกษตรกรใหม่
  Future<bool> addSupplier({required String name}) async {
    try {
      await _supabase.from('supplier').insert({'supplier_name': name});
      return true;
    } catch (e) {
      print('Error adding supplier: $e');
      return false;
    }
  }

  // 2. ลบเกษตรกร
  Future<bool> deleteSupplier(int supplierId) async {
    try {
      // หมายเหตุ: เช็กให้ชัวร์ว่าคอลัมน์ Primary Key ในตาราง supplier ของคุณชื่อ 'id' หรือ 'supplier_id'
      // ถ้าเป็นชื่ออื่นให้แก้ตรงคำว่า 'id' ด้านล่างนี้ให้ตรงกันครับ
      await _supabase.from('supplier').delete().eq('supplier_id', supplierId);
      return true;
    } catch (e) {
      print('Error deleting supplier: $e');
      return false;
    }
  }

  // ==========================================
  // ฟังก์ชันยกเลิกบิล และคืนค่าสต๊อก (อัปเดตตาม DB Schema ล่าสุด)
  // ==========================================
  Future<bool> deleteFinancialTransaction(int transactionId) async {
    try {
      // 1. อ่านข้อมูลบิลการเงิน
      final txData = await _supabase
          .from('financial_transaction')
          .select('*')
          .eq('transaction_id', transactionId)
          .maybeSingle();

      if (txData == null) return false;

      // --------------------------------------------------
      // กรณีที่ 1: เป็นบิลรับซื้อ
      // --------------------------------------------------
      if (txData['purchase_id'] != null) {
        int poId = int.parse(txData['purchase_id'].toString());

        // ก. ดึงข้อมูลรายการสินค้า (อิงคอลัมน์ purchase_id ตามภาพ)
        final details = await _supabase
            .from('purchase_detail')
            .select('*')
            .eq('purchase_id', poId);

        // ข. อัปเดตคืนสต๊อก (อิงคอลัมน์ product_id และ quantity ตามภาพ)
        for (var item in details) {
          int productId = int.parse(item['product_id'].toString());
          int qty = int.parse(item['quantity'].toString());

          final stockRes = await _supabase
              .from('product_inventory')
              .select('quantity_in_stock')
              .eq('product_id', productId)
              .maybeSingle();
          if (stockRes != null) {
            int currentStock = int.parse(
              stockRes['quantity_in_stock'].toString(),
            );
            // หักยอดสต๊อกออก เพราะเป็นการยกเลิกการรับซื้อ
            await _supabase
                .from('product_inventory')
                .update({'quantity_in_stock': currentStock - qty})
                .eq('product_id', productId);
          }
        }

        // ค. ลบข้อมูล detail และ order
        await _supabase
            .from('purchase_detail')
            .delete()
            .eq('purchase_id', poId);
        await _supabase
            .from('purchase_order')
            .delete()
            .eq('purchase_id', poId); // ปรับเป็น purchase_id
      }
      // --------------------------------------------------
      // กรณีที่ 2: เป็นบิลขาย
      // --------------------------------------------------
      else if (txData['sale_id'] != null) {
        int soId = int.parse(txData['sale_id'].toString());

        // ก. ดึงข้อมูลรายการสินค้า
        final details = await _supabase
            .from('sale_detail')
            .select('*')
            .eq('sale_id', soId);

        // ข. อัปเดตคืนสต๊อก
        for (var item in details) {
          int productId = int.parse(item['product_id'].toString());
          int qty = int.parse(item['quantity'].toString());

          final stockRes = await _supabase
              .from('product_inventory')
              .select('quantity_in_stock')
              .eq('product_id', productId)
              .maybeSingle();
          if (stockRes != null) {
            int currentStock = int.parse(
              stockRes['quantity_in_stock'].toString(),
            );
            // บวกยอดสต๊อกกลับเข้าไป เพราะเป็นการยกเลิกการขาย
            await _supabase
                .from('product_inventory')
                .update({'quantity_in_stock': currentStock + qty})
                .eq('product_id', productId);
          }
        }

        // ค. ลบข้อมูล detail และ order
        await _supabase.from('sale_detail').delete().eq('sale_id', soId);
        await _supabase
            .from('sale_order')
            .delete()
            .eq('sale_id', soId); // ปรับเป็น sale_id
      }

      // --------------------------------------------------
      // 2. ลบบิลการเงินออกจากระบบ
      // --------------------------------------------------
      await _supabase
          .from('financial_transaction')
          .delete()
          .eq('transaction_id', transactionId);

      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }
}
