import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartlink/dialogs/settings.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/tappable.dart';

const String api_version = '3.0.0-dev.1'; // TODO: get api version from api

const String repo_url = 'https://github.com/firedotguy/smartlink';
const String api_repo_url = 'https://github.com/firedotguy/smartlinkAPI';

/// Общая обёртка страниц: подпись с версией в углу и кнопка настроек.
class AppLayout extends StatefulWidget {
    const AppLayout({required this.child, super.key});
    final Widget child;

    @override
    State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
    String version = 'unknown';

    void _get_version() async {
        final PackageInfo info = await PackageInfo.fromPlatform();
        version = info.version;
        setState(() {});
    }

    void _show_about() {
        showAboutDialog(
            context: context,
            applicationName: t.app.name,
            applicationVersion: t.app.version(version, api_version),
            applicationIcon: Image.asset('assets/favicon-text.png', width: 60, height: 60),
            applicationLegalese: t.app.legalese,
            children: [
                Text(t.app.renderer_warning, style: const TextStyle(color: AppColors.warning)),
                _link(t.app.source_code, repo_url),
                _link(t.app.api_source_code, api_repo_url)
            ]
        );
    }

    Widget _link(String label, String url) {
        return Tappable(
            on_tap: () => open_url(context, url),
            child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.neo,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.neo
                )
            )
        );
    }

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_){
            _get_version();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SelectionArea(
                child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                        widget.child,
                        Tappable(
                            on_tap: _show_about,
                            disable_selection: true,
                            child: Text(
                                t.app.version_badge(version),
                                style: const TextStyle(color: AppColors.secondary, fontSize: 12)
                            )
                        )
                    ]
                )
            ),
            floatingActionButton: Builder(
                builder: (context) => IconButton(
                    tooltip: t.app.settings_tooltip,
                    onPressed: () {
                        l.i('show settings dialog, reason: open settings');
                        showDialog(
                            context: context,
                            builder: (_) => const SettingsDialog(),
                        );
                    },
                    icon: const Icon(Icons.settings, color: AppColors.secondary)
                )
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop
        );
    }
}
