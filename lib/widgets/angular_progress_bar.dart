import 'package:flutter/material.dart';
import 'package:smartlink/theme.dart';

/// Полоса загрузки со скошенными краями и бегущим индикатором.
class AngularProgressBar extends StatefulWidget {
    /// Creates an angular progress bar with customizable dimensions and colors.
    const AngularProgressBar({
        super.key,
        this.width = 200,
        this.height = 10,
        this.background_color = AppColors.main,
        this.color = AppColors.neo,
    });
    /// Width of the progress bar. Defaults to 200.
    final double width;
    /// Height of the progress bar. Defaults to 10.
    final double height;
    /// Background color of the progress bar.
    final Color background_color;
    /// Color of the animated runner.
    final Color color;

    @override
    State<AngularProgressBar> createState() => _AngularProgressBarState();
}

class _AngularProgressBarState extends State<AngularProgressBar>
        with SingleTickerProviderStateMixin {
    late final AnimationController _controller;

    @override
    void initState() {
        super.initState();
        _controller = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 2),
        )..repeat();
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: widget.width,
            height: widget.height,
            child: ClipPath(
                clipper: _AngularClipper(),
                child: Stack(
                    children: [
                        CustomPaint(
                            size: Size(widget.width, widget.height),
                            painter: _BarBackgroundPainter(background_color: widget.background_color),
                        ),
                        AnimatedBuilder(
                            animation: _controller,
                            builder: (_, _) {
                                final double runner_width = widget.width / 5;
                                final double travel_width = widget.width + runner_width;
                                final double dx = _controller.value * travel_width - runner_width;
                                return Positioned(
                                    left: dx,
                                    child: Container(
                                        width: runner_width,
                                        height: widget.height,
                                        decoration: BoxDecoration(
                                            color: widget.color,
                                            borderRadius: BorderRadius.circular(widget.height),
                                        ),
                                    ),
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}

/// Строит шестиугольный контур полосы загрузки.
Path _bar_path(Size size) {
    final double w = size.width;
    final double h = size.height;

    return Path()
        ..moveTo(h / 2, 0)
        ..lineTo(w - h / 2, 0)
        ..lineTo(w, h / 2)
        ..lineTo(w - h / 2, h)
        ..lineTo(h / 2, h)
        ..lineTo(0, h / 2)
        ..close();
}

class _BarBackgroundPainter extends CustomPainter {
    _BarBackgroundPainter({required this.background_color});
    final Color background_color;

    @override
    void paint(Canvas canvas, Size size) {
        final Paint paint = Paint()
            ..color = background_color
            ..style = PaintingStyle.fill;

        canvas.drawPath(_bar_path(size), paint);
    }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _AngularClipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) => _bar_path(size);

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
