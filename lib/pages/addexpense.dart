import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String selectedCategory = 'Grocery';
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  int? currentUserId;

  final List<String> categories = [
    'Grocery',
    'Shopping',
    'Transport',
    'Food',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final user = await _dbHelper.getUserByFirebaseUid(firebaseUser.uid);
      if (user != null) {
        setState(() {
          currentUserId = user['id'] as int;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffffb347),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<Map<String, dynamic>> _checkBudget(int userId, String category, double newAmount) async {
    final now = DateTime.now();
    
    // Get budget for this category
    final budgets = await _dbHelper.getBudgetsByUserId(userId, now.month, now.year);
    double? budgetLimit;
    
    for (var budget in budgets) {
      if (budget['category'] == category) {
        budgetLimit = budget['budget_amount'] as double;
        break;
      }
    }

    // If no budget set, allow expense
    if (budgetLimit == null) {
      return {'allowed': true, 'message': ''};
    }

    // Get current month's expenses for this category
    final allExpenses = await _dbHelper.getExpensesByUserId(userId);
    double currentMonthTotal = 0;

    for (var expense in allExpenses) {
      DateTime expenseDate = DateTime.parse(expense['date'] as String);
      if (expenseDate.month == now.month && 
          expenseDate.year == now.year && 
          expense['category'] == category) {
        currentMonthTotal += expense['amount'] as double;
      }
    }

    double totalAfterExpense = currentMonthTotal + newAmount;
    double remaining = budgetLimit - totalAfterExpense;

    if (totalAfterExpense > budgetLimit) {
      return {
        'allowed': false,
        'exceeded': true,
        'budgetLimit': budgetLimit,
        'currentTotal': currentMonthTotal,
        'newTotal': totalAfterExpense,
        'overspent': totalAfterExpense - budgetLimit,
        'message': 'This expense will exceed your $category budget by \$${(totalAfterExpense - budgetLimit).toStringAsFixed(2)}!'
      };
    } else if (remaining < budgetLimit * 0.2) {
      // Warning when less than 20% remaining
      return {
        'allowed': true,
        'warning': true,
        'budgetLimit': budgetLimit,
        'remaining': remaining,
        'message': 'Warning: Only \$${remaining.toStringAsFixed(2)} left in your $category budget!'
      };
    }

    return {'allowed': true, 'message': ''};
  }

  Future<void> _submitExpense() async {
    String amount = amountController.text.trim();
    String note = noteController.text.trim();
    
    if (amount.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
      return;
    }

    double? amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      _showSnackBar('Please enter a valid amount', Colors.red);
      return;
    }

    if (currentUserId == null) {
      _showSnackBar('User not found', Colors.red);
      return;
    }

    // Check budget before adding expense
    final budgetCheck = await _checkBudget(currentUserId!, selectedCategory, amountValue);

    if (budgetCheck['exceeded'] == true) {
      // Show confirmation dialog for budget exceeded
      _showBudgetExceededDialog(
        budgetCheck['message'],
        budgetCheck['budgetLimit'],
        budgetCheck['currentTotal'],
        budgetCheck['newTotal'],
        budgetCheck['overspent'],
        amountValue,
        note,
      );
      return;
    } else if (budgetCheck['warning'] == true) {
      // Show warning but allow to continue
      _showBudgetWarningDialog(budgetCheck['message'], amountValue, note);
      return;
    }

    // No budget issues, proceed
    await _saveExpense(amountValue, note);
  }

  void _showBudgetExceededDialog(String message, double budgetLimit, double currentTotal, 
      double newTotal, double overspent, double amount, String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Budget Exceeded!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 15),
            _buildBudgetRow('Budget Limit:', '\$${budgetLimit.toStringAsFixed(2)}'),
            _buildBudgetRow('Already Spent:', '\$${currentTotal.toStringAsFixed(2)}'),
            _buildBudgetRow('New Expense:', '\$${amount.toStringAsFixed(2)}', Colors.orange),
            Divider(),
            _buildBudgetRow('Total After:', '\$${newTotal.toStringAsFixed(2)}', Colors.red),
            _buildBudgetRow('Over Budget:', '\$${overspent.toStringAsFixed(2)}', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _saveExpense(amount, note);
            },
            child: Text('Add Anyway', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBudgetWarningDialog(String message, double amount, String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text('Budget Warning'),
          ],
        ),
        content: Text(message, style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffffb347),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _saveExpense(amount, note);
            },
            child: Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExpense(double amount, String note) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (currentUserId == null) {
        _showSnackBar('User not found in database', Colors.red);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Save expense to SQLite
      await _dbHelper.createExpense({
        'user_id': currentUserId!,
        'amount': amount,
        'category': selectedCategory,
        'date': selectedDate.toIso8601String(),
        'note': note.isEmpty ? null : note,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        isLoading = false;
      });

      // Create expense object to pass back
      Map<String, dynamic> expenseData = {
        'amount': amount,
        'category': selectedCategory,
        'date': selectedDate,
        'note': note,
      };

      _showSnackBar('Expense added successfully!', Colors.green);

      // Navigate back with the expense data
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context, expenseData);
      });

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Failed to add expense: $e', Colors.red);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Add Expense',
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
              SizedBox(height: 20.0),
              
              // Expense Image/Icon
              Center(
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Color(0xffffedc2),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    size: 100,
                    color: Color(0xffffb347),
                  ),
                ),
              ),
              
              SizedBox(height: 40.0),
              
              // Enter Amount Label
              Text(
                'Enter Amount',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              
              // Amount TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 15.0,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 25.0),
              
              // Select Category Label
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              
              // Category Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 25.0),
              
              // Note Label
              Text(
                'Note (Optional)',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              
              // Note TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 15.0,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 25.0),
              
              // Date Picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  decoration: BoxDecoration(
                    color: Color(0xffffb347).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color(0xffffb347).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0xffffb347),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffffb347),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 50.0),
              
              // Submit Button
              Center(
                child: GestureDetector(
                  onTap: isLoading ? null : _submitExpense,
                  child: Container(
                    width: 150.0,
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    decoration: BoxDecoration(
                      color: isLoading ? Colors.grey : Color(0xffffb347),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffffb347).withOpacity(0.3),
                          blurRadius: 10.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Submit',
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
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}