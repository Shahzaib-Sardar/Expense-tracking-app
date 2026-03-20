import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffedc2),
      body: Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
        child: Column(
          children: [
            SizedBox(height: 120.0),
            Image.asset("images/onboard.png"),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    Text(
                      "Manage your daily\nlife expenses",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0),
                      child: Text(
                        "Expense Tracker is a simple and efficient personal finance management app that allows you to track your daily expenses and income.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Login page
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(60.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            decoration: BoxDecoration(
                              color: Color(0xffffb347),
                              borderRadius: BorderRadius.circular(60.0),
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "Get Started",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}