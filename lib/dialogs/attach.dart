import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:smartlink/main.dart';
import 'package:url_launcher/url_launcher.dart';

/// A dialog that displays customer and task attachments such as images or PDFs.
///
/// This widget supports both mobile and web platforms.
/// On web, images are rendered using `HtmlElementView` via `dart:ui_web`.
class AttachDialog extends StatelessWidget {
  /// Constructs the [AttachDialog].
  ///
  /// [data] must be a map containing `customer` and `task` attachment lists.
  /// [load] indicates if loading indicator should be shown.
  const AttachDialog({required this.data, required this.load, super.key});
  /// The attachment data to be displayed.
  final Map? data;
  /// Whether the dialog should show a loading spinner.
  final bool load;

  Widget _buildImage(String url, String id) {
    l.i('proccessing image $url');
    if (!kIsWeb) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 500,
          maxWidth: 800,
        ),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            l.e('error loading image');
            return const Text('Ошибка загрузки изображения');
          },
        ),
      );
    }

    ui_web.PlatformViewRegistry().registerViewFactory(id, (int _) {
      final element = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.maxWidth = '100%'
        ..style.maxHeight = '500px'
        ..style.height = 'auto'
        ..style.border = 'none'
        ..style.objectFit = 'contain';
      return element;
    });

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 800,
        maxHeight: 500,
      ),
      child: HtmlElementView(viewType: id),
    );
  }

  Future<void> _openUrl(link) async {
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: kIsWeb? LaunchMode.platformDefault : LaunchMode.externalApplication);
    } else {
      l.e('unclickable link: $link');
    }
  }

  Widget _buildPdf(String url, String id) {
    l.i('proccessing pdf $url');
    return ElevatedButton.icon(
      onPressed: () async => await _openUrl(url),
      label: const Text('Открыть PDF'),
      icon: const Icon(Icons.picture_as_pdf)
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(12),
      contentPadding: const EdgeInsets.all(16),
      title: const Text('Вложения'),
      content: load
          ? const Center(child: AngularProgressBar())
          : Column(
            children: [
              const Text('Вложения абонента', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (data!['customer'].isEmpty)
              const Text('Нет данных', style: TextStyle(color: AppColors.secondary)),
              ...data!['customer'].map<Widget>((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Дата добавления: ${e['date']}'),
                      const SizedBox(height: 6),
                      e['extension'] == 'pdf'? _buildPdf(e['url'], e['id']) : _buildImage(e['url'], e['id']),
                    ],
                  ),
                );
              }).toList(),
              const Text('Вложения задания', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (data!['task'].isEmpty)
              const Text('Нет данных', style: TextStyle(color: AppColors.secondary)),
              ...data!['task'].map<Widget>((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Дата добавления: ${e['date']}'),
                      const SizedBox(height: 6),
                      e['extension'] == 'pdf'? _buildPdf(e['url'], e['id']) : _buildImage(e['url'], e['id']),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
