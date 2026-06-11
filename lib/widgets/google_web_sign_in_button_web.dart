import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

class GoogleWebSignInButton extends StatelessWidget {
  const GoogleWebSignInButton({
    super.key,
    required this.googleSignIn,
  });

  final GoogleSignIn googleSignIn;

  @override
  Widget build(BuildContext context) {
    final platform = GoogleSignInPlatform.instance;
    if (platform is! GoogleSignInPlugin) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: platform.renderButton(
        configuration: GSIButtonConfiguration(
          type: GSIButtonType.standard,
          theme: GSIButtonTheme.outline,
          size: GSIButtonSize.large,
          text: GSIButtonText.continueWith,
          shape: GSIButtonShape.rectangular,
          logoAlignment: GSIButtonLogoAlignment.left,
          minimumWidth: 320,
        ),
      ),
    );
  }
}
