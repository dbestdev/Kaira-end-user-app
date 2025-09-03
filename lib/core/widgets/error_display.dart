import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBackgroundColor =
        backgroundColor ??
        (isDark
            ? Colors.red.shade900.withValues(alpha: 0.2)
            : Colors.red.shade50);
    final defaultTextColor =
        textColor ?? (isDark ? Colors.red.shade300 : Colors.red.shade700);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Tiny Error Icon
          Icon(
            icon ?? Icons.error_outline,
            size: 16,
            color: isDark ? Colors.red.shade300 : Colors.red.shade600,
          ),

          const SizedBox(width: 8),

          // Error Message (single line)
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: defaultTextColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Tiny Retry Button
          if (onRetry != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.red.shade100 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.refresh,
                  size: 14,
                  color: isDark ? Colors.red.shade300 : Colors.red.shade600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Success Display Widget
class SuccessDisplay extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const SuccessDisplay({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBackgroundColor =
        backgroundColor ??
        (isDark
            ? Colors.green.shade900.withValues(alpha: 0.2)
            : Colors.green.shade50);
    final defaultTextColor =
        textColor ?? (isDark ? Colors.green.shade300 : Colors.green.shade700);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.green.shade800 : Colors.green.shade200,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Tiny Success Icon
          Icon(
            icon ?? Icons.check_circle_outline,
            size: 16,
            color: isDark ? Colors.green.shade300 : Colors.green.shade600,
          ),

          const SizedBox(width: 8),

          // Success Message (single line)
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: defaultTextColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Loading Display Widget
class LoadingDisplay extends StatelessWidget {
  final String message;
  final Color? color;

  const LoadingDisplay({super.key, this.message = 'Loading...', this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor =
        color ?? (isDark ? Colors.blue.shade300 : Colors.blue.shade600);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Tiny Loading Spinner
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(defaultColor),
            ),
          ),

          const SizedBox(width: 8),

          // Loading Message
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: defaultColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
