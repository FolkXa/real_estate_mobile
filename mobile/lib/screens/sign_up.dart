import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedCountryCode = '+44';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _emailValid = true;
  bool _phoneValid = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _birthDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();

    _emailController.addListener(() {
      setState(() {
        _emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text.trim());
      });
    });

    _phoneController.addListener(() {
      setState(() {
        _phoneValid =
            RegExp(r'^\d{9,15}$').hasMatch(_phoneController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String _getReadableErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email address is already registered. Please use a different email or try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      default:
        return 'An error occurred during registration. Please try again.';
    }
  }

  Future<void> _register() async {
    setState(() => _errorMessage = '');

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _birthDateController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    if (!_emailValid || !_phoneValid) {
      setState(
          () => _errorMessage = 'Please enter valid email and phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .orderBy('user_id', descending: true)
          .limit(1)
          .get();

      int nextUserId = 1;
      if (userSnapshot.docs.isNotEmpty) {
        nextUserId = int.parse((userSnapshot.docs.first.data()
                as Map<String, dynamic>)['user_id']) +
            1;
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'active': true,
        'email': _emailController.text.trim(),
        'first_name': _usernameController.text.split(' ').first,
        'last_name': _usernameController.text.split(' ').length > 1
            ? _usernameController.text.split(' ').last
            : '',
        'image_path': '',
        'nick_name': '',
        'password': 'firebase_managed',
        'phone_number': _selectedCountryCode + _phoneController.text.trim(),
        'role': 'user',
        'user_id': nextUserId,
        'username': _usernameController.text.replaceAll(' ', '_').toLowerCase(),
        'birth_date': _birthDateController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getReadableErrorMessage(e.code));
    } catch (e) {
      setState(() =>
          _errorMessage = 'An unexpected error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLabeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _styledContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                _buildLabeledField(
                  "Username",
                  _styledContainer(
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        prefixIcon: Icon(Icons.person_outline,
                            color: Theme.of(context).iconTheme.color),
                        hintText: "yourname",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  "Email",
                  _styledContainer(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        hintText: "youremail@example.com",
                        suffixIcon: Icon(
                          _emailValid ? Icons.check_circle : Icons.error,
                          color: _emailValid ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  "Birth of date",
                  _styledContainer(
                    child: TextField(
                      controller: _birthDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  "Phone Number",
                  _styledContainer(
                    child: Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (CountryCode countryCode) {
                            setState(() {
                              _selectedCountryCode = countryCode.dialCode!;
                            });
                          },
                          initialSelection: 'GB',
                          favorite: const ['US', 'GB', 'TH'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "(123) 456-7890",
                              suffixIcon: Icon(
                                _phoneValid ? Icons.check_circle : Icons.error,
                                color: _phoneValid ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  "Set Password",
                  _styledContainer(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        hintText: "********",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary)
                        : Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
