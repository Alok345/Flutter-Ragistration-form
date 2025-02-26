import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  void registerUser() async {
    setState(() => isLoading = true);

    try {
      // Use phone number as the password for authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: phoneController.text.trim(), // Using mobile number as password
      );

      // Get the UID of the authenticated user
      String uid = userCredential.user!.uid;

      // Store user data inside Firestore under 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'uid': uid,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully!")),
      );

      // Clear fields
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      addressController.clear();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number (used as password)"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerUser,
                    child: const Text("Submit"),
                  ),
          ],
        ),
      ),
    );
  }
}
