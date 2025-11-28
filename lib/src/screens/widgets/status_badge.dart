import 'package:flutter/material.dart';
import '../../theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customText;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.customText,
    this.fontSize,
    this.padding,
  });

  String get _displayText {
    if (customText != null) return customText!;

    switch (status.toLowerCase()) {
      case 'en_attente':
      case 'en attente':
        return 'En attente';
      case 'confirmé':
      case 'confirme':
        return 'Confirmé';
      case 'célébré':
      case 'celebre':
        return 'Célébré';
      case 'annulé':
      case 'annule':
        return 'Annulé';
      default:
        return status;
    }
  }

  Color get _backgroundColor {
    return AppTheme.getStatusColor(status.toLowerCase()).withOpacity(0.1);
  }

  Color get _textColor {
    return AppTheme.getStatusColor(status.toLowerCase());
  }

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'en_attente':
      case 'en attente':
        return Icons.schedule;
      case 'confirmé':
      case 'confirme':
        return Icons.check_circle_outline;
      case 'célébré':
      case 'celebre':
        return Icons.check_circle;
      case 'annulé':
      case 'annule':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: (fontSize ?? 12) + 2,
            color: _textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _displayText,
            style: TextStyle(
              color: _textColor,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusIcon extends StatelessWidget {
  final String status;
  final double size;
  final Color? color;

  const StatusIcon({
    super.key,
    required this.status,
    this.size = 24,
    this.color,
  });

  IconData get _icon {
    switch (status.toLowerCase()) {
      case 'en_attente':
      case 'en attente':
        return Icons.schedule;
      case 'confirmé':
      case 'confirme':
        return Icons.check_circle_outline;
      case 'célébré':
      case 'celebre':
        return Icons.check_circle;
      case 'annulé':
      case 'annule':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      size: size,
      color: color ?? AppTheme.getStatusColor(status.toLowerCase()),
    );
  }
}