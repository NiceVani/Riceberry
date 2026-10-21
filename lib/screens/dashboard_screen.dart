import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'inventory_screen.dart';
import 'sale_screen.dart';
import 'purchase_screen.dart';
import '../services/api_service.dart';
import 'manage_supplier_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ตัวแปรเก็บค่าว่าตอนนี้ผู้ใช้เลือกเมนูไหนอยู่ (เริ่มที่ 0 คือหน้าแรก)
  int _selectedIndex = 0;

  // รายการหน้าจอที่จะแสดงเมื่อกดเปลี่ยนเมนูด้านล่าง
  final List<Widget> _pages = [
    const HomeTab(), // 0: หน้าสรุปยอด (จะเขียนแยกไว้ด้านล่าง)
    const PurchaseScreen(),
    const SaleScreen(),
    const InventoryScreen(),
  ];

  // ฟังก์ชันเปลี่ยนหน้าเมื่อผู้ใช้กดแถบเมนู
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนเนื้อหาตรงกลาง จะเปลี่ยนไปตามเมนูที่กด
      body: _pages[_selectedIndex],

      // แถบเมนูด้านล่าง (Bottom Navigation Bar)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.borderLight, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType
              .fixed, // บังคับให้เมนูอยู่กับที่ ไม่ขยับไปมา (ผู้สูงอายุกดง่ายกว่า)
          backgroundColor: AppTheme.bgWhite,
          selectedItemColor:
              AppTheme.primaryPurple, // สีเวลาที่ถูกเลือกเป็นสีม่วง
          unselectedItemColor: AppTheme.textLight, // สีเวลาไม่ได้เลือกเป็นสีเทา
          iconSize: 32, // ปรับไอคอนให้ใหญ่ขึ้น
          selectedFontSize: 16,
          unselectedFontSize: 14,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'หน้าแรก',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'รับซื้อ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco),
              label: 'ขาย',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'คลัง/บัญชี',
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// ส่วนที่ 2: หน้าจอสรุปยอด (Home Tab) สำหรับโชว์ใน Index 0
// =========================================================
// =========================================================
// ส่วนที่ 2: หน้าจอสรุปยอด (Home Tab) สำหรับโชว์ใน Index 0
// =========================================================
class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _apiService = ApiService();

  // 1. เปลี่ยนค่าเริ่มต้นให้เป็น "ทั้งหมด" เพื่อดูยอดสรุปรวมทั้งเดือน
  String _selectedDay = 'ทั้งหมด';
  String _selectedMonth = 'ตุลาคม';
  String _selectedYear = '2569';

  // 2. เพิ่มคำว่า "ทั้งหมด" เข้าไปใน List ของวัน
  final List<String> _days = [
    'ทั้งหมด',
    ...List.generate(31, (index) => (index + 1).toString()),
  ];
  final List<String> _months = [
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
  final List<String> _years = ['2567', '2568', '2569'];

  bool _isLoading = true;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  List<Map<String, dynamic>> _allTransactions =
      []; // เก็บข้อมูลที่โหลดมาทั้งหมด
  List<Map<String, dynamic>> _filteredTransactions =
      []; // เก็บข้อมูลที่ถูกกรองตามวันที่

  @override
  void initState() {
    super.initState();
    _fetchDataFromDB();
  }

  // ฟังก์ชันดึงข้อมูลจากฐานข้อมูล (เรียกแค่ตอนเปิดแอป หรือกดปุ่มรีเฟรช)
  Future<void> _fetchDataFromDB() async {
    setState(() => _isLoading = true);
    _allTransactions = await _apiService.fetchFinancialTransactions();
    _filterData(); // โหลดเสร็จแล้วสั่งให้มันคำนวณและกรองข้อมูลทันที
  }

  // ฟังก์ชันกรองข้อมูลตาม Dropdown ที่เลือก
  // ฟังก์ชันกรองข้อมูลตาม Dropdown ที่เลือก
  // ฟังก์ชันกรองข้อมูลตาม Dropdown ที่เลือก
  void _filterData() {
    int year = int.parse(_selectedYear) - 543;
    int month = _months.indexOf(_selectedMonth) + 1;

    bool isFilterSpecificDay = _selectedDay != 'ทั้งหมด';
    int? day = isFilterSpecificDay ? int.parse(_selectedDay) : null;

    double income = 0;
    double expense = 0;
    List<Map<String, dynamic>> tempList = [];

    for (var t in _allTransactions) {
      if (t['transaction_date'] != null) {
        try {
          DateTime txDate = DateTime.parse(t['transaction_date']).toLocal();

          bool matchYear = txDate.year == year;
          bool matchMonth = txDate.month == month;
          bool matchDay = isFilterSpecificDay ? (txDate.day == day) : true;

          if (matchYear && matchMonth && matchDay) {
            tempList.add(t);

            final amount = (t['amount'] as num).toDouble();
            if (t['category_id'] == 1) {
              income += amount;
            } else if (t['category_id'] == 2) {
              expense += amount;
            }
          }
        } catch (e) {
          print('เกิดข้อผิดพลาดในการแปลงวันที่: $e');
        }
      }
    }

    // 🌟 พระเอกอยู่ตรงนี้: สั่งให้ tempList เรียงลำดับจากล่าสุดไปเก่าสุด ก่อนตัดเอา 5 อันแรก
    tempList.sort((a, b) {
      DateTime dateA =
          DateTime.tryParse(a['transaction_date'] ?? '') ?? DateTime.now();
      DateTime dateB =
          DateTime.tryParse(b['transaction_date'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA); // เอา B เทียบ A จะได้รายการล่าสุดขึ้นก่อน
    });

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      // พอมันเรียงเสร็จแล้ว ค่อยตัดมา 5 อัน
      _filteredTransactions = tempList.take(5).toList();
      _isLoading = false;
    });
  }

  String _formatNumber(double num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'สวัสดีตอนเช้า',
                    style: TextStyle(fontSize: 18, color: AppTheme.textLight),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'คุณลุงสมชาย',
                          style: TextStyle(
                            fontSize: 28,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 🌟 ใช้ GestureDetector แทน ElevatedButton เพื่อตัดปัญหา Error RenderBox ทิ้ง 100%
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageSupplierScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.people_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'จัดการรายชื่อ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- ส่วนที่ 1: Date Filter ---
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: AppTheme.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDateDropdown(
                              'วัน',
                              _selectedDay,
                              _days,
                              (val) {
                                setState(() => _selectedDay = val!);
                                _filterData(); // สั่งกรองข้อมูลและคำนวณใหม่เมื่อเลือกวัน
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _buildDateDropdown(
                              'เดือน',
                              _selectedMonth,
                              _months,
                              (val) {
                                setState(() => _selectedMonth = val!);
                                _filterData(); // สั่งกรองข้อมูลและคำนวณใหม่เมื่อเลือกเดือน
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateDropdown(
                              'ปี พ.ศ.',
                              _selectedYear,
                              _years,
                              (val) {
                                setState(() => _selectedYear = val!);
                                _filterData(); // สั่งกรองข้อมูลและคำนวณใหม่เมื่อเลือกปี
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- ส่วนที่ 2: Summary Cards ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'รายรับ',
                          amount: _formatNumber(_totalIncome),
                          subtitle: '+ เงินเข้า',
                          icon: Icons.arrow_downward,
                          bgColor: AppTheme.successGreen.withOpacity(0.05),
                          textColor: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'รายจ่าย',
                          amount: _formatNumber(_totalExpense),
                          subtitle: '- เงินออก',
                          icon: Icons.arrow_upward,
                          bgColor: AppTheme.dangerOrange.withOpacity(0.05),
                          textColor: AppTheme.dangerOrange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'กำไร',
                          amount: _formatNumber(_totalIncome - _totalExpense),
                          subtitle: 'คงเหลือ',
                          icon: Icons.bar_chart,
                          bgColor: AppTheme.primaryPurple,
                          textColor: Colors.white,
                          isHighlight: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'กิจกรรมล่าสุด',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      // เปลี่ยนปุ่ม Refresh เป็นปุ่ม "ดูทั้งหมด" แทน
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionHistoryScreen(),
                            ),
                          ).then((_) {
                            // ให้รีเฟรชหน้าแดชบอร์ดอัตโนมัติเมื่อกดกลับมา
                            _fetchDataFromDB();
                          });
                        },
                        child: const Text(
                          'ดูทั้งหมด >',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- ส่วนที่ 3: ประวัติกิจกรรมล่าสุด ---
                  _filteredTransactions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'ไม่มีประวัติในวันที่เลือก',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                        )
                      : Column(
                          children: _filteredTransactions.map((tx) {
                            final isIncome = tx['category_id'] == 1;
                            return _buildTransactionListTile(
                              tx['description'] ?? 'ไม่ระบุรายละเอียด',
                              '${isIncome ? '+' : '-'} ฿${tx['amount']}',
                              isIncome,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  // ------------------------------------
  // ส่วนวิดเจ็ตช่วยเหลือยังคงเดิม (ไม่ได้แก้ไข)
  // ------------------------------------
  Widget _buildDateDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textLight,
              ),
              items: items
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isHighlight
            ? null
            : Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isHighlight ? Colors.white70 : textColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isHighlight ? Colors.white70 : AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: isHighlight ? Colors.white : AppTheme.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isHighlight ? Colors.white70 : AppTheme.textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListTile(String title, String amount, bool isIncome) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? AppTheme.successGreen.withOpacity(0.1)
              : AppTheme.dangerOrange.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppTheme.successGreen : AppTheme.dangerOrange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isIncome ? AppTheme.successGreen : AppTheme.dangerOrange,
          ),
        ),
      ),
    );
  }
}
