import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import 'addexpense.dart';
import 'addincome.dart';
import 'monthly_budget.dart';

class ProfilePage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onExpenseAdded;
  final Function(double)? onIncomeAdded;
  final VoidCallback? onDataChanged;
  
  const ProfilePage({
    super.key, 
    this.onExpenseAdded, 
    this.onIncomeAdded,
    this.onDataChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? userImage;
  int? currentUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final user = await _dbHelper.getUserByFirebaseUid(firebaseUser.uid);
        if (user != null) {
          setState(() {
            currentUserId = user['id'] as int;
            userName = user['name'] as String;
            userEmail = user['email'] as String;
            userImage = user['profile_picture_path'] as String?;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${appDir.path}/$fileName');

        await File(pickedFile.path).copy(savedImage.path);

        if (currentUserId != null) {
          await _dbHelper.updateUserProfilePicture(currentUserId!, savedImage.path);
          
          setState(() {
            userImage = savedImage.path;
          });

          widget.onDataChanged?.call();

          _showSnackBar('Profile picture updated!', Colors.green);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Failed to update profile picture', Colors.red);
    }
  }

  Future<void> _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpensePage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      widget.onExpenseAdded?.call(result);
      widget.onDataChanged?.call();
    }
  }

  Future<void> _navigateToAddIncome() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIncomePage()),
    );

    if (result != null && result is double) {
      widget.onIncomeAdded?.call(result);
      widget.onDataChanged?.call();
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
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Color(0xff3d2846),
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
            children: [
              SizedBox(height: 20.0),
              
              // Profile Picture with Edit Button
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xffffb347),
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffffb347).withOpacity(0.3),
                            blurRadius: 15.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75.0),
                        child: userImage != null && File(userImage!).existsSync()
                            ? Image.file(
                                File(userImage!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Color(0xffffb347).withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Color(0xffffb347),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Color(0xffffb347),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.0),
              
              // Name Field
              _buildProfileCard(
                icon: Icons.person,
                label: 'Name',
                value: userName,
                onTap: () {
                  _showEditDialog(context, 'Name', userName, (newValue) async {
                    if (currentUserId != null) {
                      await _dbHelper.updateUser(currentUserId!, {'name': newValue});
                      
                      // Update in Firestore too
                      final firebaseUser = _auth.currentUser;
                      if (firebaseUser != null) {
                        await _firestore.collection('users').doc(firebaseUser.uid).update({
                          'name': newValue,
                        });
                      }
                      
                      setState(() {
                        userName = newValue;
                      });
                      widget.onDataChanged?.call();
                    }
                  });
                },
              ),
              
              SizedBox(height: 15.0),
              
              // Email Field
              _buildProfileCard(
                icon: Icons.email,
                label: 'Email',
                value: userEmail,
                onTap: () {
                  _showSnackBar('Email cannot be changed', Colors.orange);
                },
              ),
              
              SizedBox(height: 15.0),
              
              // Add Expense Button
              _buildActionButton(
                icon: Icons.arrow_downward,
                label: 'Add Expense',
                onTap: _navigateToAddExpense,
              ),
              
              SizedBox(height: 15.0),
              
              // Add Income Button
              _buildActionButton(
                icon: Icons.arrow_upward,
                label: 'Add Income',
                onTap: _navigateToAddIncome,
              ),
              
              SizedBox(height: 15.0),
              
              // Set Monthly Budget Button
              _buildActionButton(
                icon: Icons.account_balance_wallet,
                label: 'Set Monthly Budget',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetMonthlyBudgetPage()),
                  );
                },
              ),
              
              SizedBox(height: 15.0),
              
              // LogOut Button
              _buildActionButton(
                icon: Icons.logout,
                label: 'LogOut',
                onTap: () => _showLogoutDialog(context),
              ),
              
              SizedBox(height: 15.0),
              
              // Delete Account Button
              _buildActionButton(
                icon: Icons.delete,
                label: 'Delete Account',
                onTap: () => _showDeleteAccountDialog(context),
              ),
              
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.0),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: Colors.white, size: 24.0),
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: Colors.white, size: 24.0),
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20.0),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xffffb347), width: 2.0),
            ),
          ),
        ),
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
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
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
              await _auth.signOut();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This will permanently delete:',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            _buildDeleteItem('All your expenses'),
            _buildDeleteItem('All your income records'),
            _buildDeleteItem('All your budgets'),
            _buildDeleteItem('Your profile picture'),
            _buildDeleteItem('Your account data'),
            SizedBox(height: 10),
            Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteAccountCompletely();
            },
            child: Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _deleteAccountCompletely() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xffffb347)),
                SizedBox(height: 15),
                Text('Deleting account...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );

      final firebaseUser = _auth.currentUser;
      
      if (firebaseUser != null) {
        // 1. Delete from SQLite (local database)
        if (currentUserId != null) {
          // Delete all user data from SQLite
          await _dbHelper.deleteAllData();
        }

        // 2. Delete profile picture from phone storage
        if (userImage != null && File(userImage!).existsSync()) {
          await File(userImage!).delete();
        }

        // 3. Delete from Firestore (cloud database)
        try {
          await _firestore.collection('users').doc(firebaseUser.uid).delete();
          print('✅ Firestore user deleted');
        } catch (e) {
          print('⚠️ Firestore delete error: $e');
        }

        // 4. Delete from Firebase Authentication
        try {
          await firebaseUser.delete();
          print('✅ Firebase Auth user deleted');
        } catch (e) {
          print('⚠️ Firebase Auth delete error: $e');
          // If deletion fails, user might need to re-login
          Navigator.pop(context); // Close loading dialog
          _showReauthDialog();
          return;
        }
      }

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      _showSnackBar('Account deleted successfully', Colors.green);

      // Navigate to login
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      print('❌ Delete account error: $e');
      _showSnackBar('Failed to delete account: $e', Colors.red);
    }
  }

  void _showReauthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('Re-authentication Required'),
        content: Text(
          'For security reasons, you need to log in again to delete your account. Please logout and login again, then try deleting.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffffb347),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: Text('Logout & Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}