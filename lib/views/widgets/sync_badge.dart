import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Badge visual de status de sincronização — RF14
class SyncBadge extends StatelessWidget {
  final bool sincronizado;

  const SyncBadge({super.key, required this.sincronizado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: sincronizado
            ? AppTheme.successColor.withValues(alpha: 0.12)
            : AppTheme.warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sincronizado ? AppTheme.successColor : AppTheme.warningColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sincronizado ? Icons.cloud_done : Icons.cloud_upload_outlined,
            size: 13,
            color:
                sincronizado ? AppTheme.successColor : AppTheme.warningColor,
          ),
          const SizedBox(width: 4),
          Text(
            sincronizado ? 'Sincronizado' : 'Pendente de Envio',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: sincronizado
                  ? AppTheme.successColor
                  : AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }
}
