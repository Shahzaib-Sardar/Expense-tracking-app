import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController amountController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String selectedSource = 'Salary';
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  final List<String> incomeSources = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Gift',
    'Bonus',
    'Other',
  ];

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

  Future<void> _submitIncome() async {
    String amount = amountController.text.trim();
    
    if (amount.isEmpty) {
      _showSnackBar('Please enter an amount', Colors.red);
      return;
    }

    double? amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      _showSnackBar('Please enter a valid amount', Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get current user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _showSnackBar('User not logged in', Colors.red);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get user from database
      final user = await _dbHelper.getUserByFirebaseUid(firebaseUser.uid);
      if (user == null) {
        _showSnackBar('User not found in database', Colors.red);
        setState(() {
          isLoading = false;
        });
        return;
      }

      final userId = user['id'] as int;

      // Save income to SQLite
      await _dbHelper.createIncome({
        'user_id': userId,
        'amount': amountValue,
        'source': selectedSource,
        'date': selectedDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        isLoading = false;
      });

      _showSnackBar('Income added successfully!', Colors.green);

      // Return the income amount to the parent
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context, amountValue);
      });

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Failed to add income: $e', Colors.red);
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
          'Add Income',
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
              
              // Income Image/Icon
              Center(
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  padding: EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Color(0xffffedc2),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Icon(
                    Icons.attach_money,
                    size: 120.0,
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
              
              // Select Source Label
              Text(
                'Select Source',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              
              // Source Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSource,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    items: incomeSources.map((String source) {
                      return DropdownMenuItem<String>(
                        value: source,
                        child: Text(source),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSource = newValue!;
                      });
                    },
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
                  onTap: isLoading ? null : _submitIncome,
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
    super.dispose();
  }
}