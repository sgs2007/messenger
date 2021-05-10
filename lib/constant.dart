import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

LinearGradient spaceGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF000000),
    Color(0xFF00008B),
    Color(0xFF0000CD),
    Color(0xFF8B008B),
    Color(0xFFDA70D6),
    Color(0xFF8B008B),
    Color(0xFF0000FF),
    Color(0xFF0000CD),
    Color(0xFF00008B),
    Color(0xFF000000),
  ],
);

const kPrimaryColor = Color(0xFF00BF6D);
const kSecondaryColor = Color(0xFFFE9901);
const kContentColorLightTheme = Color(0xFFF5FCF9);
const kContentColorDarkTheme = Color(0xFF1D1D35);

var logoTitleStyle = GoogleFonts.orbitron(
  color: Colors.white,
  fontSize: 21,
  fontWeight: FontWeight.bold,
);
