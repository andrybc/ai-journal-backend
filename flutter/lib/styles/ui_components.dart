import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'text_styles.dart';

/// A utility class for common UI components and widgets used throughout the app
class AppUI {
  /// Creates a standard loading indicator
  static Widget loadingIndicator({double size = 20}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  /// Creates a standard message card for errors or success messages
  static Widget messageCard({
    required BuildContext context,
    required String? message,
    bool isError = false,
  }) {
    if (message == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isError ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final textColor =
        isError ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(message, style: TextStyle(color: textColor)),
        ),
      ),
    );
  }

  /// Creates a standard snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? Colors.green.shade700 : Colors.black87,
        duration: duration,
      ),
    );
  }

  /// Creates a standard empty state widget
  static Widget emptyState({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onActionPressed,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgAssetIcon(asset: icon, size: 75, color: Colors.white),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: AppTextStyle.h3),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmall,
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.add),
            label: Text(actionText),
          ),
        ],
      ),
    );
  }
}

/// A widget for displaying SVG assets with better error handling
class SvgAssetIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const SvgAssetIcon({
    super.key,
    required this.asset,
    this.size = 24,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      semanticsLabel: 'Icon',
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      width: size,
      height: size,
      placeholderBuilder:
          (context) => Container(
            padding: const EdgeInsets.all(15),
            child: const CircularProgressIndicator(),
          ),
    );
  }
}
