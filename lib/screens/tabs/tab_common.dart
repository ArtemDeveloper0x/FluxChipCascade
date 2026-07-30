import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Shared header + scroll wrapper used by every bottom-nav tab so they read as
/// one consistent hub.
class TabScaffold extends StatelessWidget {
  const TabScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.children,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.neonTitle(size: 26, color: accent)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    );
  }
}

/// Crystal balance chip shown in tab headers.
class CrystalChip extends StatelessWidget {
  const CrystalChip({super.key, required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgDeep.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.18), blurRadius: 12),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 16),
        const SizedBox(width: 6),
        Text('$amount',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 15)),
      ]),
    );
  }
}

/// Simple neon panel card wrapper.
class NeonCard extends StatelessWidget {
  const NeonCard(
      {super.key,
      required this.child,
      this.accent,
      this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final Color? accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = accent ?? AppColors.panelBorder;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgPanel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.12), blurRadius: 14)],
      ),
      child: child,
    );
  }
}
