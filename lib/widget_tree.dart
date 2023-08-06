import 'package:budget_tracker_2/auth.dart';
import 'package:budget_tracker_2/pages/login_register_page.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker_2/app.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});


  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot
            .data; // User object if authenticated, otherwise null

        if (user != null) {
          // User is authenticated, navigate to Home page
          return const Home();
        } else {
          // User is not authenticated, navigate to LoginPage
          return const LoginPage();
        }
      }

    );
  }
}