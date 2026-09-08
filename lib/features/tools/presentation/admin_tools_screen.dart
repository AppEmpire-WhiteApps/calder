import 'package:flutter/material.dart';

import '../../../core/theme/calder_theme.dart';

class AdminToolsScreen extends StatelessWidget {
  const AdminToolsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const Text(
        'OPERATOR TOOLS',
        style: TextStyle(
          color: CalderTheme.cyan,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Small references for the daily sysadmin shift.',
        style: TextStyle(color: CalderTheme.muted, fontSize: 16),
      ),
      const SizedBox(height: 22),
      _ToolCard(
        icon: Icons.network_check_rounded,
        title: 'CIDR quick reference',
        detail: '/24 = 254 hosts · /28 = 14 hosts · /30 = 2 hosts',
      ),
      _ToolCard(
        icon: Icons.lock_outline_rounded,
        title: 'Permission quick reference',
        detail: '600 private key · 640 shared file · 750 executable directory',
      ),
      _ToolCard(
        icon: Icons.emergency_outlined,
        title: 'Incident first five',
        detail: 'Identify · preserve · contain · communicate · document',
      ),
      _ToolCard(
        icon: Icons.dns_rounded,
        title: 'Common ports',
        detail: '22 SSH · 53 DNS · 80 HTTP · 443 HTTPS · 3389 RDP',
      ),
      _ToolCard(
        icon: Icons.checklist_rounded,
        title: 'Change checklist',
        detail: 'Scope · backup · rollback · observe · record outcome',
      ),
      _ToolCard(
        icon: Icons.shield_outlined,
        title: 'Hardening reminder',
        detail: 'MFA · patch · least privilege · logging · tested backups',
      ),
    ],
  );
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Icon(icon, color: CalderTheme.cyan),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(detail, style: const TextStyle(color: CalderTheme.muted)),
      ),
    ),
  );
}
