import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../core/theme.dart';
import 'webview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sfx = StorageService.I.sfxEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(backgroundColor: AppColors.bgDeep, title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _SwitchTile(
            label: 'Sound Effects',
            value: _sfx,
            onChanged: (v) {
              setState(() => _sfx = v);
              StorageService.I.setSfxEnabled(v);
            },
          ),
          const SizedBox(height: 24),
          _LinkTile(
            label: 'Privacy Policy',
            icon: Icons.privacy_tip,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const WebViewScreen(
                  title: 'Privacy Policy', url: AppLinks.privacyPolicy, whiteBackground: true),
            )),
          ),
          const SizedBox(height: 12),
          _LinkTile(
            label: 'Support',
            icon: Icons.support_agent,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const WebViewScreen(
                  title: 'Support', url: AppLinks.support, whiteBackground: false),
            )),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Flux Chip Cascade v1.0.0',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.panelDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.cyan),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.panelDecoration(),
        child: Row(
          children: [
            Icon(icon, color: AppColors.cyan),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
