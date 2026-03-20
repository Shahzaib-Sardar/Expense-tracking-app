import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String selectedFilter = 'All';
  List<Map<String, dynamic>> allTransactions = [];
  bool isLoading = true;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final user = await _dbHelper.getUserByFirebaseUid(firebaseUser.uid);
        if (user != null) {
          final userId = user['id'] as int;

          final transactions = await _dbHelper.getAllTransactionsByUserId(userId);
          
          double income = 0.0;
          double expense = 0.0;
          
          for (var transaction in transactions) {
            if (transaction['type'] == 'income') {
              income += transaction['amount'] as double;
            } else {
              expense += transaction['amount'] as double;
            }
          }

          final formattedTransactions = transactions.map((t) {
            return {
              ...t,
              'icon': _getIconForCategory(t['category'] as String, t['type'] as String),
              'color': _getColorForCategory(t['category'] as String, t['type'] as String),
            };
          }).toList();

          setState(() {
            allTransactions = formattedTransactions;
            totalIncome = income;
            totalExpense = expense;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData _getIconForCategory(String category, String type) {
    if (type == 'income') {
      if (category == 'Salary') return Icons.attach_money;
      if (category == 'Freelance') return Icons.work;
      if (category == 'Investment') return Icons.trending_up;
      if (category == 'Business') return Icons.business;
      if (category == 'Gift') return Icons.card_giftcard;
      if (category == 'Bonus') return Icons.monetization_on;
      return Icons.account_balance_wallet;
    }
    
    if (category == 'Shopping') return Icons.shopping_bag;
    if (category == 'Grocery') return Icons.shopping_cart;
    if (category == 'Transport') return Icons.directions_car;
    if (category == 'Food') return Icons.restaurant;
    if (category == 'Bills') return Icons.receipt_long;
    if (category == 'Entertainment') return Icons.movie;
    if (category == 'Healthcare') return Icons.local_hospital;
    if (category == 'Education') return Icons.school;
    return Icons.more_horiz;
  }

  Color _getColorForCategory(String category, String type) {
    if (type == 'income') {
      return Color(0xff8bc34a);
    }
    
    if (category == 'Shopping') return Color(0xffffb347);
    if (category == 'Grocery') return Color(0xff8bc34a);
    if (category == 'Transport') return Color(0xff42a5f5);
    if (category == 'Food') return Color(0xffffca28);
    if (category == 'Bills') return Color(0xffff7043);
    if (category == 'Entertainment') return Color(0xffab47bc);
    if (category == 'Healthcare') return Color(0xffef5350);
    if (category == 'Education') return Color(0xff5c6bc0);
    return Color(0xff26a69a);
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedFilter == 'All') return allTransactions;
    return allTransactions.where((t) => t['type'] == selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffedc2),
      appBar: AppBar(
        backgroundColor: Color(0xffffedc2),
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: Color(0xff3d2846),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xffffb347)))
          : Column(
              children: [
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Income',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '\$${totalIncome.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff8bc34a),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '\$${totalExpense.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffffb347),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      SizedBox(width: 10.0),
                      _buildFilterChip('Income'),
                      SizedBox(width: 10.0),
                      _buildFilterChip('Expense'),
                    ],
                  ),
                ),
                
                SizedBox(height: 20.0),
                
                // Transaction List
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first transaction to see it here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xffffb347) : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Color(0xffffb347).withOpacity(0.3),
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    bool isIncome = transaction['type'] == 'income';
    
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: transaction['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              transaction['icon'],
              color: transaction['color'],
              size: 24.0,
            ),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['category'],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  transaction['note'] ?? '',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.0),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(transaction['date'])),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${(transaction['amount'] as double).toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isIncome ? Color(0xff8bc34a) : Color(0xffffb347),
            ),
          ),
        ],
      ),
    );
  }
}