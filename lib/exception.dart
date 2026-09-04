import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/utils.dart';

class ApiException implements Exception {
    ApiException(this.status, this.detail);

    final int status;
    final String detail;

    @override
    String toString() => detail;
}

Future<T?> guard<T>(
    BuildContext context,
    Future<T> Function() action, {
    VoidCallback? on_error,
}) async {
    try {
        return await action();
    } on ApiException catch (e) {
        if (context.mounted) show_error(context, t.common.error(e.detail));
        on_error?.call();
        return null;
    } catch (e) {
        l.e('unexpected: $e');
        if (context.mounted) show_error(context, t.common.error(e.toString()));
        on_error?.call();
        return null;
    }
}
