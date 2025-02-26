import 'package:flutter/material.dart';
import 'package:harshit/Home.dart';
import 'package:harshit/Login.dart'; // Import the Signup page
// import 'package:harshit/Login.dart'; // Import the Login page

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display a random image from a URL
            Image.network(
              'https://i1.sndcdn.com/artworks-uhnP6z8zFV24V7sA-TFDUxQ-t500x500.jpg',
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),

            // Signup Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()), // Navigate to Signup
                );
              },
              child: const Text("Signup"),
            ),
            const SizedBox(height: 10), // Space between buttons

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()), // Navigate to Login
                );
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
