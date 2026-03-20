import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class SetMonthlyBudgetPage extends StatefulWidget {
  const SetMonthlyBudgetPage({super.key});

  @override
  State<SetMonthlyBudgetPage> createState() => _SetMonthlyBudgetPageState();
}

class _SetMonthlyBudgetPageState extends State<SetMonthlyBudgetPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Map<String, TextEditingController> controllers = {
    'Shopping': TextEditingController(text: '00'),
    'Grocery': TextEditingController(text: '00'),
    'Transport': TextEditingController(text: '00'),
    'Food': TextEditingController(text: '00'),
    'Bills': TextEditingController(text: '00'),
    'Entertainment': TextEditingController(text: '00'),
    'Healthcare': TextEditingController(text: '00'),
    'Education': TextEditingController(text: '00'),
    'Others': TextEditingController(text: '00'),
  };

  final Map<String, IconData> categoryIcons = {
    'Shopping': Icons.shopping_bag,
    'Grocery': Icons.shopping_cart,
    'Transport': Icons.directions_car,
    'Food': Icons.restaurant,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Healthcare': Icons.local_hospital,
    'Education': Icons.school,
    'Others': Icons.more_horiz,
  };

  final Map<String, Color> categoryColors = {
    'Shopping': Color(0xffffb347),
    'Grocery': Color(0xffffca28),
    'Transport': Color(0xff42a5f5),
    'Food': Color(0xffff9800),
    'Bills': Color(0xffff7043),
    'Entertainment': Color(0xffab47bc),
    'Healthcare': Color(0xffef5350),
    'Education': Color(0xff5c6bc0),
    'Others': Color(0xff26a69a),
  };

  bool isLoading = true;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final user = await _dbHelper.getUserByFirebaseUid(firebaseUser.uid);
        if (user != null) {
          currentUserId = user['id'] as int;
          
          // Get current month and year
          final now = DateTime.now();
          final budgets = await _dbHelper.getBudgetsByUserId(
            currentUserId!,
            now.month,
            now.year,
          );

          // Update controllers with saved budgets
          for (var budget in budgets) {
            final category = budget['category'] as String;
            final amount = budget['budget_amount'] as double;
            if (controllers.containsKey(category)) {
              controllers[category]!.text = amount.toStringAsFixed(0);
            }
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading budgets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double get totalBudget {
    return controllers.values.fold(0.0, (sum, controller) {
      return sum + (double.tryParse(controller.text) ?? 0.0);
    });
  }

  Future<void> _saveBudget() async {
    if (currentUserId == null) {
      _showSnackBar('User not found', Colors.red);
      return;
    }

    try {
      final now = DateTime.now();
      
      // Delete existing budgets for this month
      await _dbHelper.deleteBudgetsByUserId(currentUserId!, now.month, now.year);

      // Save new budgets
      for (var entry in controllers.entries) {
        final amount = double.tryParse(entry.value.text) ?? 0.0;
        if (amount > 0) {
          await _dbHelper.createBudget({
            'user_id': currentUserId!,
            'category': entry.key,
            'budget_amount': amount,
            'month': now.month,
            'year': now.year,
          });
        }
      }

      _showSnackBar('Budget saved successfully!', Colors.green);

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showSnackBar('Failed to save budget', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
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
      appBar: AppBar(
        backgroundColor: Color(0xffffedc2),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffffb347),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          'Set Monthly Budget',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Icon
              Center(
                child: Container(
                  width: 180.0,
                  height: 180.0,
                  padding: EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 100.0,
                    color: Color(0xffffb347),
                  ),
                ),
              ),
              
              SizedBox(height: 30.0),
              
              // Total Budget Display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color(0xffffb347),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Monthly Budget',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '\$${totalBudget.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30.0),
              
              Text(
                'Category Budgets',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 15.0),
              
              // Budget Input Fields
              ...controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: categoryColors[entry.key]!.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(
                          categoryIcons[entry.key],
                          color: categoryColors[entry.key],
                          size: 24.0,
                        ),
                      ),
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        width: 100.0,
                        child: TextField(
                          controller: entry.value,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: categoryColors[entry.key],
                          ),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            border: InputBorder.none,
                            prefixStyle: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: categoryColors[entry.key],
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              SizedBox(height: 30.0),
              
              // Save Button
              Center(
                child: GestureDetector(
                  onTap: _saveBudget,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    decoration: BoxDecoration(
                      color: Color(0xffffb347),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffffb347).withOpacity(0.3),
                          blurRadius: 10.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Save Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}