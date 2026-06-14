import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../theme/app_theme.dart';

class ApiEndpointBanner extends StatelessWidget {
  const ApiEndpointBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiConfig.resolveBaseUrl(
      isWeb: kIsWeb,
      platformName: defaultTargetPlatform.name,
    );
    final isProduction = ApiConfig.isProductionUrl(baseUrl);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isProduction
                  ? MaeMojiColors.increase
                  : MaeMojiColors.maintain,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isProduction ? 'PROD' : 'DEV',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: MaeMojiColors.ink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              baseUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: MaeMojiColors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
