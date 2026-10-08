import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/bangla_number.dart';
import '../providers/theme_provider.dart';

class AnimatedNumber extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const AnimatedNumber({
    Key? key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
  }) : super(key: key);

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
      _previousValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = Provider.of<ThemeProvider>(context).isBanglaDigits;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final formatted = BanglaNumber.format(
          _animation.value,
          isBanglaDigits: isBangla,
          decimalDigits: 2,
        );
        return Text(
          '${widget.prefix}$formatted${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
