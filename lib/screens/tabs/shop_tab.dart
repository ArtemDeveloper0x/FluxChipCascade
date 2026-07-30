import 'package:flutter/material.dart';
import '../../core/audio_manager.dart';
import '../../core/constants.dart';
import '../../core/storage_service.dart';
import '../../core/theme.dart';
import '../../game/data/lab_data.dart';
import 'tab_common.dart';

/// Permanent meta-upgrade store. Purchases persist and are applied to every
/// future run (see FluxGame._applyMetaUpgrades).
class ShopTab extends StatefulWidget {
  const ShopTab({super.key, required this.onChanged});
  final VoidCallback onChanged;

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  Future<void> _buy(LabModule m) async {
    final store = StorageService.I;
    final level = store.labLevel(m.id);
    if (level >= m.maxLevel) return;
    final cost = m.costForNext(level);
    if (store.crystals < cost) {
      AudioManager.I.sfx(Sounds.errorNotification, volume: 0.5);
      return;
    }
    await store.spendCrystals(cost);
    await store.incLabLevel(m.id);
    AudioManager.I.sfx(Sounds.buyUpgrade);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final store = StorageService.I;
    return TabScaffold(
      title: 'LAB',
      subtitle: 'Spend crystals on permanent core upgrades',
      accent: AppColors.gold,
      trailing: CrystalChip(amount: store.crystals),
      children: [
        for (final m in kLabModules) ...[
          _ModuleCard(
            module: m,
            level: store.labLevel(m.id),
            crystals: store.crystals,
            onBuy: () => _buy(m),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Center(
          child: Text('Upgrades apply automatically to your next run',
              style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 11)),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard(
      {required this.module,
      required this.level,
      required this.crystals,
      required this.onBuy});
  final LabModule module;
  final int level;
  final int crystals;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final maxed = level >= module.maxLevel;
    final cost = module.costForNext(level);
    final affordable = crystals >= cost;
    final c = module.color;

    return NeonCard(
      accent: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.withValues(alpha: 0.5)),
              ),
              child: Icon(module.icon, color: c, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(labEffectText(module, level),
                      style: TextStyle(
                          color: c.withValues(alpha: 0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(module.description,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.3)),
          const SizedBox(height: 12),
          // level pips
          Row(children: [
            for (int i = 0; i < module.maxLevel; i++)
              Container(
                margin: const EdgeInsets.only(right: 5),
                width: 20,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i < level
                      ? c
                      : AppColors.panelBorder.withValues(alpha: 0.5),
                  boxShadow: i < level
                      ? [BoxShadow(color: c.withValues(alpha: 0.7), blurRadius: 6)]
                      : null,
                ),
              ),
            const Spacer(),
            _BuyButton(
              maxed: maxed,
              affordable: affordable,
              cost: cost,
              color: c,
              onTap: maxed ? null : onBuy,
            ),
          ]),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton(
      {required this.maxed,
      required this.affordable,
      required this.cost,
      required this.color,
      required this.onTap});
  final bool maxed;
  final bool affordable;
  final int cost;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (maxed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.green.withValues(alpha: 0.14),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_rounded, color: AppColors.green, size: 15),
          SizedBox(width: 5),
          Text('MAX',
              style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ]),
      );
    }
    return Opacity(
      opacity: affordable ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.12),
            ]),
            border: Border.all(color: color.withValues(alpha: 0.7)),
            boxShadow: affordable
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 14),
            const SizedBox(width: 5),
            Text('$cost',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
