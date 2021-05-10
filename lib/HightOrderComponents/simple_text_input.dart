import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleTextInput extends StatelessWidget {
  const SimpleTextInput({
    Key key,
    @required this.hintText,
    this.width,
    this.height,
    @required this.controller,
  }) : super(key: key);

  final double width, height;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          width: width ?? size.width * 0.7,
          height: height ?? 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            color: Colors.white.withOpacity(0.4),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
