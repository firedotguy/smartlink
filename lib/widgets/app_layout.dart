import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/settings.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/info_tile.dart';
import 'package:smartlink/widgets/tappable.dart';


const String repo_url = 'https://github.com/fi-res/smartlink';
const String api_repo_url = 'https://github.com/fi-res/smartlinkAPI';

/// Общая обёртка страниц: подпись с версией в углу и кнопка настроек.
class AppLayout extends StatefulWidget {
    const AppLayout({required this.child, super.key});
    final Widget child;

    @override
    State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
    String version = 'unknown';
    String api_version = 'unknown';
    bool is_dev = false;
    bool is_stable = true;
    bool connection = true;

    void _get_version() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final PackageInfo info = await PackageInfo.fromPlatform();
        version = info.version;
        late Map platform;

        try{
            platform = await get_platform();
        } catch (e) {
            l.e('no connection');
            connection = false;
            setState(() {});
            return;
        }
        api_version = platform['version'];
        is_dev = platform['dev'];
        is_stable = platform['stable'];

        if (!platform['smartlink_compatible_versions'].contains(version)) {
            l.e('version not compatible');
            if (!mounted) return;
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                    title: Text(t.incompatibleVersion.title),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text(t.incompatibleVersion.description),
                            InfoTile(title: t.incompatibleVersion.current, value: version),
                            InfoTile(title: t.incompatibleVersion.compatible, value: platform['smartlink_compatible_versions'].join(' / '))
                        ],
                    )
                )
            );
        } else if (platform['force_dev']) {
            l.e('site under dev');
            if (!mounted) return;
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                    title: Text(t.common.force_dev_title),
                    content: GestureDetector(
                        onTertiaryLongPress: () {
                            Navigator.pop(context);
                        },
                        child: Text(t.common.force_dev)
                    )
                )
            );
        } else if (platform['announcement'] != null && prefs.getString('last_announce') != platform['announcement']['title']) {
            if (!mounted) return;
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                    title: Text(platform['announcement']['title']),
                    content: Text(platform['announcement']['content']),
                    actions: [
                        ElevatedButton(
                            onPressed: () {
                                prefs.setString('last_announce', platform['announcement']['title']);
                                Navigator.pop(context);
                            },
                            child: Text(t.common.close)
                        )
                    ],
                )
            );
        }

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
                if (const bool.fromEnvironment('dart.tool.dart2wasm'))
                Text(t.app.renderer_warning, style: const TextStyle(color: AppColors.success)),
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
                        Column(
                            children: [
                                if (is_dev || !is_stable || !connection)
                                SizedBox(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                            Container(
                                                foregroundDecoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin: const Alignment(-0.05, -0.05),
                                                        end: const Alignment(0.05, 0.05),
                                                        colors: !connection? [AppColors.error, AppColors.error, const Color(0xFFa23d33), const Color(0xFFa23d33)] : [AppColors.warning, AppColors.warning, const Color(0xFF9b8119), const Color(0xFF9b8119)],
                                                        stops: const [0, 0.5, 0.5, 1],
                                                        tileMode: TileMode.repeated,
                                                        transform: const GradientRotation(0.7853982)
                                                    )
                                                ),
                                            ),
                                            Text(!connection? t.common.no_connection : is_dev? t.common.dev_warning : t.common.unstable_warning, style: const TextStyle(color: Colors.black, fontSize: 16))
                                        ]
                                    )
                                ),
                                Expanded(child: widget.child)
                            ]
                        ),
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
