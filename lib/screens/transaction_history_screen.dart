import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  // เก็บข้อมูลทั้งหมดจากฐานข้อมูล
  List<Map<String, dynamic>> _allTransactions = [];

  // เก็บข้อมูลที่ผ่านการกรอง (ค้นหา/เลือกวัน) เพื่อนำไปแสดงผล
  List<Map<String, dynamic>> _displayedTransactions = [];

  // ตัวควบคุมช่องค้นหา
  final TextEditingController _searchController = TextEditingController();

  // ตัวแปรเก็บวันที่ที่เลือก (ถ้าเป็น null คือไม่ได้กรองวัน)
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // ดักจับเวลาพิมพ์ข้อความในช่องค้นหา ให้เรียกฟังก์ชันกรองข้อมูล
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchFinancialTransactions();

    // เรียงลำดับจากล่าสุดไปเก่าสุด
    data.sort((a, b) {
      DateTime dateA =
          DateTime.tryParse(a['transaction_date'] ?? '') ?? DateTime.now();
      DateTime dateB =
          DateTime.tryParse(b['transaction_date'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    setState(() {
      _allTransactions = data;
      _applyFilters(); // โหลดเสร็จสั่งกรองข้อมูล 1 รอบ
      _isLoading = false;
    });
  }

  // ----------------------------------------------------
  // ระบบกรองข้อมูล (ค้นหาข้อความ + กรองวันที่)
  // ----------------------------------------------------
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> temp = List.from(_allTransactions);

    // 1. กรองด้วยข้อความค้นหา (ค้นจากรายละเอียด หรือ โน้ต)
    if (query.isNotEmpty) {
      temp = temp.where((tx) {
        final desc = (tx['description'] ?? '').toString().toLowerCase();
        final note = (tx['note'] ?? '').toString().toLowerCase();
        return desc.contains(query) || note.contains(query);
      }).toList();
    }

    // 2. กรองด้วยวันที่ (ถ้ามีการเลือกวันไว้)
    if (_selectedDate != null) {
      temp = temp.where((tx) {
        if (tx['transaction_date'] == null) return false;
        DateTime txDate = DateTime.parse(tx['transaction_date']).toLocal();
        return txDate.year == _selectedDate!.year &&
            txDate.month == _selectedDate!.month &&
            txDate.day == _selectedDate!.day;
      }).toList();
    }

    setState(() {
      _displayedTransactions = temp;
    });
  }

  // ฟังก์ชันเปิดปฏิทินให้เลือกวัน
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _applyFilters();
    }
  }

  // แปลงวันที่เป็นภาษาไทย
  String _formatThaiDate(DateTime date) {
    const months = [
      '',
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    return '${date.day} ${months[date.month]} ${date.year + 543}';
  }

  // จัดกลุ่มข้อมูลแยกตาม "วันที่" โดยใช้ข้อมูลที่ผ่านการกรองแล้ว (_displayedTransactions)
  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var tx in _displayedTransactions) {
      if (tx['transaction_date'] != null) {
        DateTime date = DateTime.parse(tx['transaction_date']).toLocal();
        String dateString = _formatThaiDate(date);

        if (!grouped.containsKey(dateString)) {
          grouped[dateString] = [];
        }
        grouped[dateString]!.add(tx);
      }
    }
    return grouped;
  }

  // 1. หน้าต่างป๊อปอัปยืนยันก่อนลบ
  Future<void> _showDeleteConfirm(Map<String, dynamic> tx) async {
    // 🌟 ดึง transaction_id มาใช้งานตรงๆ ตามข้อมูลจากฐานข้อมูล
    final int transactionId =
        int.tryParse(tx['transaction_id'].toString()) ?? 0;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.dangerOrange,
                size: 32,
              ),
              SizedBox(width: 10),
              Text(
                'ยกเลิกรายการ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dangerOrange,
                ),
              ),
            ],
          ),
          content: Text(
            'ต้องการลบรายการ:\n"${tx['description'] ?? 'ไม่ระบุ'}"\nจำนวนเงิน ฿${tx['amount'] ?? 0} ใช่หรือไม่?\n\n'
            '*ยอดสต๊อกข้าวที่เกี่ยวข้องกับบิลนี้ จะถูกอัปเดตคืนค่าอัตโนมัติ',
            style: const TextStyle(
              fontSize: 18,
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
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppTheme.textLight,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ปิด',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        if (transactionId > 0) {
                          _executeDelete(transactionId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'เกิดข้อผิดพลาด: รหัสรายการไม่ถูกต้อง',
                              ),
                              backgroundColor: AppTheme.dangerOrange,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ยืนยันลบ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  // 2. ฟังก์ชันเรียก API สำหรับลบ และโชว์หน้าโหลด
  Future<void> _executeDelete(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.dangerOrange),
      ),
    );

    bool success = await _apiService.deleteFinancialTransaction(id);

    Navigator.pop(context); // ปิดหน้าโหลด

    if (success) {
      _fetchData(); // ดึงข้อมูลมาแสดงใหม่
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ยกเลิกรายการสำเร็จ'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการยกเลิกรายการ'),
          backgroundColor: AppTheme.dangerOrange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedTx = _groupTransactionsByDate();
    final dateKeys = groupedTx.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'ประวัติย้อนหลัง',
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
                // ----------------------------------------------------
                // ส่วนค้นหา (Search Bar) และ ปุ่มเลือกวัน (Date Filter)
                // ----------------------------------------------------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // ช่องค้นหา
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'ค้นหารายการ, ชื่อ...',
                            hintStyle: const TextStyle(
                              color: AppTheme.textLight,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.primaryPurple,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppTheme.textLight,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      FocusScope.of(
                                        context,
                                      ).unfocus(); // ซ่อนคีย์บอร์ด
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: AppTheme.bgLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ปุ่มปฏิทิน
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedDate != null
                                ? AppTheme.primaryPurple
                                : AppTheme.bgLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDate != null
                                  ? AppTheme.primaryPurple
                                  : AppTheme.borderLight,
                            ),
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: _selectedDate != null
                                ? Colors.white
                                : AppTheme.primaryPurple,
                            size: 28,
                          ),
                        ),
                      ),

                      // ปุ่มกากบาทลบวันที่ (จะโชว์เมื่อมีการเลือกวันไว้เท่านั้น)
                      if (_selectedDate != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = null;
                            });
                            _applyFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.dangerOrange,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ----------------------------------------------------
                // ส่วนแสดงผลรายการบิล
                // ----------------------------------------------------
                Expanded(
                  child: _displayedTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่พบรายการที่ค้นหา',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppTheme.textLight,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dateKeys.length,
                          itemBuilder: (context, index) {
                            String dateTitle = dateKeys[index];
                            List<Map<String, dynamic>> dailyTx =
                                groupedTx[dateTitle]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    dateTitle,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryPurple,
                                    ),
                                  ),
                                ),
                                ...dailyTx.map((tx) {
                                  final isIncome = tx['category_id'] == 1;
                                  final amountStr =
                                      '${isIncome ? '+' : '-'} ฿${tx['amount']}';
                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: AppTheme.borderLight,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: isIncome
                                            ? AppTheme.successGreen.withOpacity(
                                                0.1,
                                              )
                                            : AppTheme.dangerOrange.withOpacity(
                                                0.1,
                                              ),
                                        child: Icon(
                                          isIncome
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isIncome
                                              ? AppTheme.successGreen
                                              : AppTheme.dangerOrange,
                                        ),
                                      ),
                                      title: Text(
                                        tx['description'] ?? 'ไม่ระบุ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle:
                                          tx['note'] != null &&
                                              tx['note'].toString().isNotEmpty
                                          ? Text(
                                              tx['note'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: AppTheme.textLight,
                                              ),
                                            )
                                          : null,
                                      // เปลี่ยน trailing เป็น Row เพื่อใส่ยอดเงินคู่กับปุ่มถังขยะ
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            amountStr,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isIncome
                                                  ? AppTheme.successGreen
                                                  : AppTheme.dangerOrange,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // ปุ่มถังขยะสำหรับลบ
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: AppTheme.dangerOrange,
                                            ),
                                            onPressed: () {
                                              // เปลี่ยนจาก tx['id'] เป็น tx['transaction_id']
                                              if (tx['transaction_id'] !=
                                                  null) {
                                                _showDeleteConfirm(tx);
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'ไม่สามารถยกเลิกได้: ไม่พบรหัสรายการ',
                                                    ),
                                                    backgroundColor:
                                                        AppTheme.dangerOrange,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
