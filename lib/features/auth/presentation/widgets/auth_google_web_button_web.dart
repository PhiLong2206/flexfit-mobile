import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

class AuthGoogleWebButton extends StatelessWidget {
  const AuthGoogleWebButton({super.key, this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: google_web.renderButton(
              configuration: google_web.GSIButtonConfiguration(
                type: google_web.GSIButtonType.standard,
                theme: google_web.GSIButtonTheme.filledBlack,
                size: google_web.GSIButtonSize.large,
                text: google_web.GSIButtonText.continueWith,
                shape: google_web.GSIButtonShape.pill,
                logoAlignment: google_web.GSIButtonLogoAlignment.left,
                minimumWidth: 320,
              ),
            ),
          ),
          if (isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x99000000),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
