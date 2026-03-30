import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginPage> {
  bool _isObscure = true;

  // controller for recive input from 'Email' & 'Password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // log in with Firebase ( Authentication )
  Future<void> signInWithEmailPassword() async {
    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.of(context).pop();

      if (mounted) {
        // login succes >> move to search_page.dart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      String errorMessage = 'Invalid email or password.';

      if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Storytelling Management',
          style: GoogleFonts.shortStack(color: Colors.black, fontSize: 28),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 450,
          height: 400,
          padding: EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.black),
            // gradient color in box login
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // shade color from light blue to white
              colors: [Color(0xFFEBF8FF), Colors.white],
              // light blue start at top and white start at center (linear)
              stops: [0.0, 0.5],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Log in',
                    style: GoogleFonts.shortStack(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter your admin acount below',
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // create TextFormField to input 'Email'
                  Expanded(
                    child: TextFormField(
                      controller: _emailController, // connect _emailController
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'name@example.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress, // keyboard @
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // create TextFormField to input 'Password'
                  Expanded(
                    child: TextFormField(
                      controller:
                          _passwordController, // connect _passwordController
                      obscureText: _isObscure, // hide password
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '******',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // eye icon
                        // _isObscure is true => close eye
                        // _isObscure is false => open eye
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          // press eye button
                          onPressed: () {
                            // change true <=> false
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  // gradient color for button login
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB4E1FF), Color(0xFFF3FFBD)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                // create button for login
                child: ElevatedButton(
                  onPressed: signInWithEmailPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Forget your password?', style: TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
