import 'package:flutter/material.dart';

class DynamicallySizedText extends StatefulWidget {
  static const double defaultFontSize = 14;

  final String text;
  final int maxLines;
  final double minFontSize;
  final TextStyle? style;

  const DynamicallySizedText(
    this.text, {
    required this.maxLines,
    this.minFontSize = 12,
    this.style,
    super.key,
  });

  @override
  State<DynamicallySizedText> createState() => _DynamicallySizedTextState();
}

class _DynamicallySizedTextState extends State<DynamicallySizedText> {
  late double _currentFontSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustFontSize());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // * Initialize with the default style if not provided
    _currentFontSize = widget.style?.fontSize ??
        DefaultTextStyle.of(context).style.fontSize ??
        DynamicallySizedText.defaultFontSize;
  }

  void _adjustFontSize() {
    final maxWidth = context.size?.width ?? double.infinity;

    if (maxWidth == double.infinity) {
      return; // * Exit if size is not yet available
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.style?.copyWith(fontSize: _currentFontSize) ??
            TextStyle(fontSize: _currentFontSize),
      ),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    // * Keep adjusting the font size upon overflow
    while (textPainter.didExceedMaxLines &&
        _currentFontSize > widget.minFontSize) {
      setState(() => _currentFontSize -= 1);

      textPainter.text = TextSpan(
        text: widget.text,
        style: widget.style?.copyWith(fontSize: _currentFontSize) ??
            TextStyle(fontSize: _currentFontSize),
      );

      textPainter.layout(maxWidth: maxWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: widget.style?.copyWith(fontSize: _currentFontSize) ??
          TextStyle(fontSize: _currentFontSize),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
