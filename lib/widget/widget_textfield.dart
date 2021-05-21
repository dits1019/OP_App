import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  TextEditingController controller;
  String hint;
  IconData icon;
  TextInputType inputType;
  bool hideText;

  LoginTextField(
      {this.controller,
      this.hint,
      this.icon,
      this.inputType,
      this.hideText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        obscureText: hideText,
        keyboardType: inputType,
        controller: controller,
        style: TextStyle(fontFamily: 'Yangjin', fontSize: 17),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 17),
          hintText: hint,
          suffixIcon: Icon(
            icon,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }
}
