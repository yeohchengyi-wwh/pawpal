import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/connection.dart';
import 'package:pawpal/frontend/loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late double height, width;
  bool visible = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 40,
                      color: Colors.blue[700],
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Join PawPal Today!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Create your account to start your pet adoption journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 8),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (visible) {
                            visible = false;
                          } else {
                            visible = true;
                          }
                          setState(() {});
                        },
                        icon: Icon(Icons.visibility),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (visible) {
                            visible = false;
                          } else {
                            visible = true;
                          }
                          setState(() {});
                        },
                        icon: Icon(Icons.visibility),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        registerDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Register', style: TextStyle(fontSize: 18)),
                    ),
                  ),

                  SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text('Already have an account? Login here'),
                  ),

                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registerDialog() {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please enter a valid email address'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!RegExp(r'^[0-9]{10,12}$').hasMatch(phone)) {
      SnackBar snackBar = const SnackBar(
        content: Text(
          'Phone number must be 10-12 digits and in number format only',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password.length < 6) {
      SnackBar snackBar = const SnackBar(
        content: Text('Passwords must be at least 6 characters'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password != confirmPassword) {
      SnackBar snackBar = const SnackBar(
        content: Text('Passwords do not match'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('Before registering user with email: $email');
              registerUser(email, password, name, phone);
            },
            child: Text('Register'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
        content: Text('Are you sure you want to register this account?'),
      ),
    );
  }

  void registerUser(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Registering...'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
    await http
        .post(
          Uri.parse('${Connection.baseUrl}/pawpal/api/register.php'),
          body: {
            'email': email,
            'name': name,
            'phone': phone,
            'password': password,
          },
        )
        .then((response) {
          // log(response.body);
          // log(response.statusCode.toString());
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            log(jsonResponse);
            if (resarray['status'] == 'success') {
              if (!mounted) return;
              SnackBar snackBar = const SnackBar(
                content: Text('Registration successful'),
              );
              if (isLoading) {
                if (!mounted) return;
                Navigator.pop(context); // Close the loading dialog
                setState(() {
                  isLoading = false;
                });
              }
              Navigator.pop(context); // Close the registration dialog
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else {
              if (!mounted) return;
              SnackBar snackBar = SnackBar(content: Text(resarray['message']));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          } else {
            if (!mounted) return;
            SnackBar snackBar = const SnackBar(
              content: Text('Registration failed. Please try again.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        })
        .timeout(
          Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            SnackBar snackBar = const SnackBar(
              content: Text('Request timed out. Please try again.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        );

    if (isLoading) {
      if (!mounted) return;
      Navigator.pop(context); // Close the loading dialog
      setState(() {
        isLoading = false;
      });
    }
  }
}
