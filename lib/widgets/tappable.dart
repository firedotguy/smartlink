import 'package:flutter/material.dart';

class Tappable extends StatelessWidget {
    const Tappable({
        required this.child,
        super.key,
        this.on_tap,
        this.disable_selection = false
    });
    final Widget child;
    final VoidCallback? on_tap;

    final bool disable_selection;

    @override
    Widget build(BuildContext context) {
        final Widget tappable = MouseRegion(
            cursor: on_tap == null? MouseCursor.defer : SystemMouseCursors.click,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: on_tap,
                child: child
            )
        );

        return disable_selection? SelectionContainer.disabled(child: tappable) : tappable;
    }
}
