import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    if (uid != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: phoneController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        await _firestore.collection('users').doc(uid).set({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'uid': uid,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User registered successfully!")),
        );

        Navigator.pushReplacementNamed(context, '/dashboard');

        nameController.clear();
        emailController.clear();
        phoneController.clear();
        addressController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Form"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name", suffixText: "*"),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email", suffixText: "*"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email address';
                  const emailRegex = r'^[^@]+@[^@]+\\.[^@]+';
                  return !RegExp(emailRegex).hasMatch(value) ? 'Please enter a valid email address' : null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number (used as password)", suffixText: "*"),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address", suffixText: "*"),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: registerUser, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}
