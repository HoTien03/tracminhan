import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import thư viện intl
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}

class ThuChi {
  final String date;
  final double amount;
  final String type;
  final String description;
  final String category;
  final String note;

  ThuChi({
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
    this.note='',
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'type': type,
      'description': description,
      'category': category,
    };
  }

  static ThuChi fromJson(Map<String, dynamic> json) {
    return ThuChi(
      date: json['date'],
      amount: json['amount'],
      type: json['type'],
      description: json['description'],
      category: json['category'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    InputPage(),
    CalendarPage(),
    HistoryPage(), // Thêm trang lịch sử giao dịch vào đây
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thu chi'),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: 'Nhập liệu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài khoản',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _type = 'thu';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  List<Category> categories = [
    Category(name: 'Ăn uống', icon: Icons.fastfood, color: Colors.orange),
    Category(name: 'Giải trí', icon: Icons.movie, color: Colors.blue),
    Category(name: 'Mua sắm', icon: Icons.shopping_cart, color: Colors.green),
    Category(name: 'Học tập', icon: Icons.school, color: Colors.yellow),
    Category(name: 'Sức khỏe', icon: Icons.local_hospital, color: Colors.pink),
    Category(name: 'Khác', icon: Icons.more_horiz, color: Colors.grey),
  ];

  List<ThuChi> _thuChiList = [];

  _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTransactions = prefs.getString('transactions');
    if (savedTransactions != null) {
      List<dynamic> transactionsJson = jsonDecode(savedTransactions);
      setState(() {
        _thuChiList = transactionsJson.map((json) => ThuChi.fromJson(json)).toList();
      });
    }
  }

  _saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> transactionsJson = _thuChiList.map((tc) => tc.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(transactionsJson));
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  _saveTransaction() {
    final thuChi = ThuChi(
      date: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      )),
      amount: double.parse(_amountController.text.replaceAll(' ', '')),
      type: _type!,
      description: _descriptionController.text,
      category: _selectedCategory!,
    );

    setState(() {
      _thuChiList.add(thuChi);
    });

    _saveTransactions();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Giao dịch đã được lưu!'),
      duration: Duration(seconds: 2),
    ));

    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  _deleteTransaction(int index) {
    setState(() {
      _thuChiList.removeAt(index);
    });
    _saveTransactions();
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: categories
                .map((category) => DropdownMenuItem<String>(
              value: category.name,
              child: Row(
                children: [
                  Icon(category.icon, color: category.color),
                  SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Danh mục',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Số tiền',
              prefixIcon: Icon(Icons.attach_money),
            ),
            onChanged: (value) {
              String newValue = value.replaceAll(' ', '');
              if (newValue.isNotEmpty && double.tryParse(newValue) != null) {
                final formattedValue = formatNumberWithSpace(int.parse(newValue));
                _amountController.value = TextEditingValue(
                  text: formattedValue,
                  selection: TextSelection.collapsed(offset: formattedValue.length),
                );
              }
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Mô tả',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Thu'),
                  value: 'thu',
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Chi'),
                  value: 'chi',
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveTransaction,
            child: Text('Lưu giao dịch'),
          ),
        ],
      ),
    );
  }

  String formatNumberWithSpace(int number) {
    String numberString = number.toString();
    StringBuffer formattedString = StringBuffer();
    int length = numberString.length;

    for (int i = 0; i < length; i++) {
      formattedString.write(numberString[i]);
      if ((length - i - 1) % 3 == 0 && i != length - 1) {
        formattedString.write(' ');
      }
    }

    return formattedString.toString();
  }
}

// Hàm định dạng số với khoảng cách
String formatNumberWithSpace(int number) {
  String numberString = number.toString();
  StringBuffer formattedString = StringBuffer();
  int length = numberString.length;

  for (int i = 0; i < length; i++) {
    formattedString.write(numberString[i]);
    if ((length - i - 1) % 3 == 0 && i != length - 1) {
      formattedString.write(' ');
    }
  }

  return formattedString.toString();
}


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  List<ThuChi> _thuChiList = [];

  // Hàm lấy số ngày trong tháng
  int _getDaysInMonth(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    return lastDayOfMonth.day;
  }

  // Hàm lấy tên ngày trong tuần (bắt đầu từ Chủ nhật)
  List<String> _getWeekdays() {
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']; // Chủ nhật đến Thứ bảy
  }

  // Hàm lấy ngày đầu tiên của tháng (để căn chỉnh các ngày đúng)
  int _getFirstWeekdayOfMonth(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    return firstDayOfMonth.weekday; // Lấy thứ của ngày 1 trong tháng
  }

  // Hàm tạo lịch tháng
  List<Widget> _buildCalendar() {
    List<Widget> days = [];
    int firstDayOfMonth = _getFirstWeekdayOfMonth(_selectedDate.year, _selectedDate.month);
    int totalDays = _getDaysInMonth(_selectedDate.year, _selectedDate.month);

    // Thêm các ngày trống cho các ô trống trước ngày 1 của tháng
    for (int i = 0; i < firstDayOfMonth; i++) {
      days.add(Container());
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= totalDays; day++) {
      DateTime currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
      double totalIncome = 0;
      double totalExpense = 0;

      // Tính tổng thu chi cho mỗi ngày
      for (var transaction in _thuChiList) {
        DateTime transactionDate = DateFormat('yyyy-MM-dd').parse(transaction.date.split(' ')[0]);
        if (transactionDate.year == currentDate.year && transactionDate.month == currentDate.month && transactionDate.day == currentDate.day) {
          if (transaction.type == 'thu') {
            totalIncome += transaction.amount;
          } else if (transaction.type == 'chi') {
            totalExpense += transaction.amount;
          }
        }
      }

      // Màu sắc cho ô ngày (Xanh nếu thu > chi, Đỏ nếu thu < chi)
      Color dayColor = Colors.transparent;
      if (totalIncome > totalExpense) {
        dayColor = Colors.green[200]!;
      } else if (totalIncome < totalExpense) {
        dayColor = Colors.red[200]!;
      }

      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: _selectedDate.day == day ? Colors.teal : dayColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                color: _selectedDate.day == day ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Hiển thị tháng và năm
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                  });
                },
              ),
            ],
          ),

          // Hiển thị các ngày trong tuần
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: _buildCalendar().length,
            itemBuilder: (context, index) {
              return _buildCalendar()[index];
            },
          ),
        ],
      ),
    );
  }

  // Hàm tải giao dịch
  _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTransactions = prefs.getString('transactions');
    if (savedTransactions != null) {
      List<dynamic> transactionsJson = jsonDecode(savedTransactions);
      setState(() {
        _thuChiList = transactionsJson.map((json) => ThuChi.fromJson(json)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
}



int _getDaysInMonth(int year, int month) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final lastDayOfMonth = DateTime(year, month + 1, 0);
  return lastDayOfMonth.day;
}


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ThuChi> _thuChiList = [];

  // Hàm lấy dữ liệu giao dịch từ SharedPreferences
  _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTransactions = prefs.getString('transactions');
    if (savedTransactions != null) {
      List<dynamic> transactionsJson = jsonDecode(savedTransactions);
      setState(() {
        _thuChiList = transactionsJson.map((json) => ThuChi.fromJson(json)).toList();
      });
    }
  }

  // Hàm tính tổng thu và chi theo ngày
  Map<String, Map<String, double>> _calculateTotalByDay() {
    Map<String, Map<String, double>> totalByDay = {};

    for (var transaction in _thuChiList) {
      String date = transaction.date.split(' ')[0]; // Lấy phần ngày (yyyy-MM-dd)
      if (!totalByDay.containsKey(date)) {
        totalByDay[date] = {'thu': 0, 'chi': 0}; // Khởi tạo thu chi cho ngày mới
      }

      if (transaction.type == 'thu') {
        totalByDay[date]!['thu'] = totalByDay[date]!['thu']! + transaction.amount;
      } else if (transaction.type == 'chi') {
        totalByDay[date]!['chi'] = totalByDay[date]!['chi']! + transaction.amount;
      }
    }

    return totalByDay;
  }




  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, double>> totalByDay = _calculateTotalByDay();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử giao dịch'),
      ),
      body: ListView.builder(
        itemCount: totalByDay.keys.length,
        itemBuilder: (context, index) {
          String date = totalByDay.keys.elementAt(index);
          double totalThu = totalByDay[date]!['thu']!;
          double totalChi = totalByDay[date]!['chi']!;
          double netAmount = totalThu - totalChi;

          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ngày
                  Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.parse(date)),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Thu
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tổng thu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalThu)}',
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // Chi
                  Row(
                    children: [
                      Icon(Icons.money_off, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tổng chi: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalChi)}',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // Lợi nhuận
                  Row(
                    children: [
                      Icon(
                        netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: netAmount >= 0 ? Colors.blue : Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lợi nhuận: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(netAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: netAmount >= 0 ? Colors.blue : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Chi tiết
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Chuyển đến trang chi tiết giao dịch
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailsPage(
                              date: date,
                              transactionsForDay: _thuChiList
                                  .where((transaction) => transaction.date.split(' ')[0] == date)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      child: Text('Xem chi tiết', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class TransactionDetailsPage extends StatelessWidget {
  final String date;
  final List<ThuChi> transactionsForDay;

TransactionDetailsPage({required this.date, required this.transactionsForDay});

// Hàm ánh xạ danh mục với icon
IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Ăn uống':
      return Icons.fastfood;
    case 'Giải trí':
      return Icons.movie;
    case 'Mua sắm':
      return Icons.shopping_cart;
    case 'Học tập':
      return Icons.school;
    case 'Sức khỏe':
      return Icons.local_hospital;
    default:
      return Icons.more_horiz; // Icon mặc định
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết giao dịch - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(date))}'),
      ),
      body: ListView.builder(
        itemCount: transactionsForDay.length,
        itemBuilder: (context, index) {
          var transaction = transactionsForDay[index];

          // Lựa chọn icon tương ứng
          IconData transactionIcon;
          Color iconColor;
          if (transaction.type == 'thu') {
            transactionIcon = Icons.attach_money;
            iconColor = Colors.green;
          } else {
            transactionIcon = Icons.money_off;
            iconColor = Colors.red;
          }

          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(
                getCategoryIcon(transaction.category),
                color: transaction.type == 'thu' ? Colors.green : Colors.red,
                size: 30,
              ),
              title: Text(
                transaction.type == 'thu' ? 'Thu nhập' : 'Chi tiêu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    'Số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount)}',
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Mô tả: ${transaction.description.isNotEmpty ? transaction.description : "Không có"}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class AccountPage extends StatefulWidget {
  @override
  AccountPageState createState() => AccountPageState();
}


class AccountPageState extends State<AccountPage> {
  // Các thông tin người dùng
  final String avatarUrl = 'https://example.com/avatar.jpg'; // Đường dẫn ảnh đại diện
  final String fullName = 'Nguyễn Văn A';
  final String phoneNumber = '0901234567';
  final String birthDate = '01/01/1990';
  double accountBalance = 0; // Số dư tài khoản ban đầu

  // Hàm cập nhật số dư tài khoản
  void updateBalance(double amount, String type) {
    setState(() {
      if (type == 'thu') {
        accountBalance += amount;
      } else if (type == 'chi') {
        accountBalance -= amount;
      }
    });
  }

  // Hàm lấy giao dịch từ trang Lịch sử giao dịch
  void getTransactionsFromHistory() async {
    // Lấy dữ liệu giao dịch từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTransactions = prefs.getString('transactions');
    if (savedTransactions != null) {
      List<dynamic> transactionsJson = jsonDecode(savedTransactions);
      List<ThuChi> transactions = transactionsJson.map((json) => ThuChi.fromJson(json)).toList();

      // Cập nhật số dư cho từng giao dịch
      for (var transaction in transactions) {
        updateBalance(transaction.amount, transaction.type);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getTransactionsFromHistory(); // Lấy dữ liệu giao dịch để cập nhật số dư
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng NumberFormat để định dạng số tiền
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Tài Khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Họ tên: $fullName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Số điện thoại: $phoneNumber',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Ngày sinh: $birthDate',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Số dư tài khoản: ${currencyFormat.format(accountBalance)}', // Định dạng số dư
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hồ Sơ Người Dùng')),
      body: Center(
        child: Text('Chi tiết thông tin người dùng'),
      ),
    );
  }
}