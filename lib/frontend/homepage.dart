import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/frontend/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawpal/frontend/submitpetscreen.dart';
import 'package:pawpal/frontend/mainpage.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = "Loading...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PawPal Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
       actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'pet_listing') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(user: widget.user),
                  ),
                );
              } else if (value == 'logout') {
                confirmationLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'pet_listing',
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Pet Listing'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormPetSubmssion(user: widget.user),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void confirmationLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', false);
    await prefs.remove('email');
    await prefs.remove('password');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // Remove all previous routes
    );
  }
}
