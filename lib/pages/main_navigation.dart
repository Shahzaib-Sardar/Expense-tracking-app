import 'package:flutter/material.dart';
import 'home.dart';
import 'transaction_history.dart';
import 'profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _refreshAllPages() {
    // Just refresh the current page by rebuilding
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Home(key: ValueKey('home_${DateTime.now().millisecondsSinceEpoch}')),
      TransactionHistoryPage(key: ValueKey('history_${DateTime.now().millisecondsSinceEpoch}')),
      ProfilePage(
        onExpenseAdded: (expense) {
          _refreshAllPages();
        },
        onIncomeAdded: (income) {
          _refreshAllPages();
        },
        onDataChanged: () {
          _refreshAllPages();
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Refresh data when switching tabs
            _refreshAllPages();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xffffedc2),
          selectedItemColor: Color(0xffffb347),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.0,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xffffb347).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xffffb347).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.history),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xffffb347).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.person),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}