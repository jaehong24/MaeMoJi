import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleWebSignInButton extends StatelessWidget {
  const GoogleWebSignInButton({
    super.key,
    required this.googleSignIn,
  });

  final GoogleSignIn googleSignIn;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
