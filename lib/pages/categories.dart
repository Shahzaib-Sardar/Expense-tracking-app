import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Grocery',
      'icon': Icons.shopping_cart,
      'color': Color(0xff8bc34a),
      'count': 12
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Color(0xffee6856),
      'count': 8
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': Color(0xff42a5f5),
      'count': 15
    },
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': Color(0xffffca28),
      'count': 20
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': Color(0xffab47bc),
      'count': 5
    },
    {
      'name': 'Bills',
      'icon': Icons.receipt_long,
      'color': Color(0xffff7043),
      'count': 6
    },
    {
      'name': 'Healthcare',
      'icon': Icons.local_hospital,
      'color': Color(0xffef5350),
      'count': 3
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': Color(0xff5c6bc0),
      'count': 4
    },
    {
      'name': 'Others',
      'icon': Icons.more_horiz,
      'color': Color(0xff26a69a),
      'count': 10
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffef9e7),
      appBar: AppBar(
        backgroundColor: Color(0xfffef9e7),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffee6856),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          'Categories',
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
              // Category Icon
              Center(
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  padding: EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image.asset(
                    'images/expense.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              SizedBox(height: 30.0),
              
              Text(
                'Select a Category',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 20.0),
              
              // Categories Grid
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to category details or filter expenses
                      print('Selected: ${categories[index]['name']}');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: categories[index]['color'].withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              categories[index]['icon'],
                              color: categories[index]['color'],
                              size: 30.0,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            categories[index]['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            '${categories[index]['count']} items',
                            style: TextStyle(
                              fontSize: 11.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}