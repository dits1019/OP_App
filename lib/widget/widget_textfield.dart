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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(width * 0.01),
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
          contentPadding: EdgeInsets.all(width * 0.03),
        ),
      ),
    );
  }
}
