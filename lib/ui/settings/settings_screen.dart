import 'package:flutter/material.dart';
import '../../core/theme/theme_manager.dart';
import 'package:stepflow/l10n/app_localizations.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              AppLocalizations.of(context)!.myInfo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Color(0xFF38BDF8)),
                  title: Text(AppLocalizations.of(context)!.checkHistory),
                  subtitle: Text(AppLocalizations.of(context)!.historySubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              AppLocalizations.of(context)!.themeSettings,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: themeManager,
                  builder: (context, child) {
                    return SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.darkTheme),
                      subtitle: Text(AppLocalizations.of(context)!.darkThemeSubtitle),
                      value: themeManager.isDarkMode,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onChanged: (value) {
                        themeManager.toggleTheme(value);
                      },
                      activeColor: const Color(0xFF38BDF8),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
