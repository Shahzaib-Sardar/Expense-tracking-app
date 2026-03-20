import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../database/database_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> allExpenses = [];
  double totalIncome = 0.0;
  String userName = "Loading...";
  String? userProfilePicture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final user = await _dbHelper.getUserByFirebaseUid(firebaseUser.uid);
        if (user != null) {
          final userId = user['id'] as int;

          // Load user info
          userName = user['name'] as String;
          userProfilePicture = user['profile_picture_path'] as String?;

          // Load expenses
          final expenses = await _dbHelper.getExpensesByUserId(userId);
          final expensesList = expenses.map((e) {
            return {
              'amount': e['amount'] as double,
              'category': e['category'] as String,
              'date': DateTime.parse(e['date'] as String),
              'note': e['note'] ?? '',
            };
          }).toList();

          // Load income
          final income = await _dbHelper.getTotalIncomeByUserId(userId);

          setState(() {
            allExpenses = expensesList;
            totalIncome = income;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double get totalExpenses {
    return allExpenses.fold(0, (sum, expense) => sum + expense['amount']);
  }

  List<Map<String, dynamic>> get chartExpenses {
    if (allExpenses.isEmpty) {
      return [];
    }

    Map<String, double> categoryTotals = {};
    for (var expense in allExpenses) {
      String category = expense['category'];
      categoryTotals[category] = (categoryTotals[category] ?? 0) + expense['amount'];
    }

    var sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < math.min(2, sortedCategories.length); i++) {
      result.add({
        'category': sortedCategories[i].key,
        'amount': sortedCategories[i].value,
        'color': _getCategoryColor(sortedCategories[i].key),
      });
    }

    if (sortedCategories.length > 2) {
      double othersTotal = 0;
      for (int i = 2; i < sortedCategories.length; i++) {
        othersTotal += sortedCategories[i].value;
      }
      result.add({
        'category': 'Others',
        'amount': othersTotal,
        'color': Color(0xff26a69a),
      });
    }

    return result;
  }

  String get dateRange {
    if (allExpenses.isEmpty) {
      return "No expenses yet";
    }

    DateTime earliest = allExpenses[0]['date'];
    DateTime latest = allExpenses[0]['date'];

    for (var expense in allExpenses) {
      if (expense['date'].isBefore(earliest)) {
        earliest = expense['date'];
      }
      if (expense['date'].isAfter(latest)) {
        latest = expense['date'];
      }
    }

    return "${DateFormat('d MMMM yyyy').format(earliest)} - ${DateFormat('d MMMM yyyy').format(latest)}";
  }

  Color _getCategoryColor(String category) {
    Map<String, Color> categoryColors = {
      'Shopping': Color(0xffffb347),
      'Grocery': Color(0xff8bc34a),
      'Transport': Color(0xff42a5f5),
      'Food': Color(0xffff7043),
      'Entertainment': Color(0xffab47bc),
      'Bills': Color(0xffef5350),
      'Healthcare': Color(0xff26c6da),
      'Education': Color(0xffffa726),
      'Others': Color(0xff26a69a),
    };
    return categoryColors[category] ?? Color(0xff9e9e9e);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xffffedc2),
        body: Center(child: CircularProgressIndicator(color: Color(0xffffb347))),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xffffedc2),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 10.0, top: 50.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Color(0xff3d2846),
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Color(0xff3d2846),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35.0),
                    child: userProfilePicture != null && File(userProfilePicture!).existsSync()
                        ? Image.file(
                            File(userProfilePicture!),
                            height: 70.0,
                            width: 70.0,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 70.0,
                            width: 70.0,
                            decoration: BoxDecoration(
                              color: Color(0xffffb347).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xffffb347),
                            ),
                          ),
                  ),
                ],
              ),

              SizedBox(height: 30.0),

              Text(
                "Manage your\nexpenses",
                style: TextStyle(
                  color: Color(0xff3d2846),
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 20.0),

              // Expenses Card with Chart
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Expenses",
                          style: TextStyle(
                            color: Color(0xff3d2846),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "\$${totalExpenses.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: Color(0xffffb347),
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dateRange,
                      style: TextStyle(
                        color: const Color.fromARGB(134, 0, 0, 0),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 20.0),

                    // Donut Chart and Legend
                    allExpenses.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.pie_chart_outline,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'No expenses to display',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Add your first expense to see the chart',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 180,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CustomPaint(
                                    painter: DonutChartPainter(chartExpenses),
                                    child: Container(),
                                  ),
                                ),
                                SizedBox(width: 20.0),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: chartExpenses.map((expense) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: expense['color'],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    expense['category'],
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '\$${(expense['amount'] as double).toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontSize: 11.0,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),

              SizedBox(height: 20.0),

              // Income and Expenses Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income',
                            style: TextStyle(
                              color: Color(0xff3d2846),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '+\$${totalIncome.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8bc34a),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color(0xff8bc34a),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expenses',
                            style: TextStyle(
                              color: Color(0xff3d2846),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '-\$${totalExpenses.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffffb347),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color(0xffffb347),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.0),

              // Status Message
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: Color(0xffffb347),
                      size: 28,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        totalIncome >= totalExpenses
                            ? 'Your expense plan looks good'
                            : 'You are spending more than earning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff3d2846),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

// Donut Chart Painter
class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> expenses;

  DonutChartPainter(this.expenses);

  @override
  void paint(Canvas canvas, Size size) {
    double total = expenses.fold(0, (sum, expense) => sum + expense['amount']);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2;

    for (var expense in expenses) {
      final sweepAngle = (expense['amount'] / total) * 2 * math.pi;

      final paint = Paint()
        ..color = expense['color']
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) => true;
}