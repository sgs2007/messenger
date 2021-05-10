import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleButton extends StatelessWidget {
  const SimpleButton({
    Key key,
    @required this.buttonTitle,
    this.width,
    this.height,
    @required this.onTap,
  }) : super(key: key);

  final String buttonTitle;
  final double width, height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width ?? size.width * 0.4,
            height: height ?? 45,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(-3, 3),
                  blurRadius: 4,
                  spreadRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                buttonTitle,
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
