import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showmaker/prompting/parameters.dart' as par;

TextStyle getFont(TextStyle style, par.Fonts font) {
  if (font == par.Fonts.Alegreya) {
    style = GoogleFonts.alegreya(textStyle: style);
  }
  if (font == par.Fonts.FrankRuhlLibre) {
    style = GoogleFonts.frankRuhlLibre(textStyle: style);
  }
  if (font == par.Fonts.Lato) {
    style = GoogleFonts.lato(textStyle: style);
  }
  if (font == par.Fonts.Montserrat) {
    style = GoogleFonts.montserrat(textStyle: style);
  }
  if (font == par.Fonts.OpenSans) {
    style = GoogleFonts.openSans(textStyle: style);
  }
  if (font == par.Fonts.Oswald) {
    style = GoogleFonts.oswald(textStyle: style);
  }
  if (font == par.Fonts.Poppins) {
    style = GoogleFonts.poppins(textStyle: style);
  }
  if (font == par.Fonts.Raleway) {
    style = GoogleFonts.raleway(textStyle: style);
  }
  if (font == par.Fonts.RalewayDots) {
    style = GoogleFonts.ralewayDots(textStyle: style);
  }
  if (font == par.Fonts.Roboto) {
    style = GoogleFonts.roboto(textStyle: style);
  }
  return style;
}
