import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/drawing_canvas_view.dart';

/// Painter for checkered grid pattern demonstrating transparency under alpha colors.
class CheckeredPatternPainter extends CustomPainter {
  const CheckeredPatternPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()
      ..color = isDark ? const Color(0xFF383535) : const Color(0xFFFFFFFF);
    final darkPaint = Paint()
      ..color = isDark ? const Color(0xFF222020) : const Color(0xFFE2E8F0);
    const boxSize = 7.0;

    for (double y = 0; y < size.height; y += boxSize) {
      for (double x = 0; x < size.width; x += boxSize) {
        final isEven = ((x / boxSize).floor() + (y / boxSize).floor()) % 2 == 0;
        final rect = Rect.fromLTWH(
          x,
          y,
          (size.width - x).clamp(0.0, boxSize),
          (size.height - y).clamp(0.0, boxSize),
        );
        canvas.drawRect(rect, isEven ? lightPaint : darkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckeredPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Formats a Flutter [Color] into a hex string (#RRGGBB or #AARRGGBB if opacity < 1.0).
String colorToHex(Color color) {
  final a = (color.a * 255.0).round().clamp(0, 255);
  final r = (color.r * 255.0).round().clamp(0, 255);
  final g = (color.g * 255.0).round().clamp(0, 255);
  final b = (color.b * 255.0).round().clamp(0, 255);

  final rHex = r.toRadixString(16).padLeft(2, '0').toUpperCase();
  final gHex = g.toRadixString(16).padLeft(2, '0').toUpperCase();
  final bHex = b.toRadixString(16).padLeft(2, '0').toUpperCase();

  if (a < 255) {
    final aHex = a.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$aHex$rHex$gHex$bHex';
  } else {
    return '#$rHex$gHex$bHex';
  }
}

/// Dialog presenting a full color wheel, shade/brightness control, opacity slider,
/// real-time preview with transparency grid, and Apply / Cancel confirmation.
class DrawingColorPickerDialog extends StatefulWidget {
  const DrawingColorPickerDialog({super.key, required this.initialColorHex});

  final String initialColorHex;

  static Future<String?> show(
    BuildContext context, {
    required String initialColorHex,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          DrawingColorPickerDialog(initialColorHex: initialColorHex),
    );
  }

  @override
  State<DrawingColorPickerDialog> createState() =>
      _DrawingColorPickerDialogState();
}

class _DrawingColorPickerDialogState extends State<DrawingColorPickerDialog> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = parseHexColor(widget.initialColorHex);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacityPercent = (_currentColor.a * 100).round();
    final hexString = colorToHex(_currentColor);

    return Dialog(
      backgroundColor: colors.backgroundColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(
          color: isDark ? Colors.white12 : colors.numberButtonBorder,
          width: 1.0,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: colors.operatorButton.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      color: isDark
                          ? colors.operatorButton
                          : colors.accentHighContrast,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Drawing Color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textPrimary),
                    tooltip: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Current-Color Real-time Preview Box
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF282525)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isDark ? Colors.white12 : colors.numberButtonBorder,
                  ),
                ),
                child: Row(
                  children: [
                    // Preview Swatch with checkered transparency background
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isDark
                              ? Colors.white24
                              : colors.numberButtonBorder,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(
                            painter: CheckeredPatternPainter(isDark: isDark),
                          ),
                          Container(color: _currentColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Color code and Opacity details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hexString,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isDark
                                              ? colors.operatorButton
                                              : colors.accentHighContrast)
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  'Opacity $opacityPercent%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? colors.operatorButton
                                        : colors.accentHighContrast,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Full Color Wheel & Hue Ring Picker with Shade/Brightness area
              Center(
                child: HueRingPicker(
                  pickerColor: _currentColor,
                  onColorChanged: (color) {
                    setState(
                      () => _currentColor = color.withValues(
                        alpha: _currentColor.a,
                      ),
                    );
                  },
                  enableAlpha: false,
                  displayThumbColor: true,
                  colorPickerHeight: 210.0,
                  hueRingStrokeWidth: 22.0,
                ),
              ),
              const SizedBox(height: 8),

              // Opacity Slider with explicit percentage label
              Row(
                children: [
                  Icon(
                    Icons.opacity_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Opacity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$opacityPercent%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? colors.operatorButton
                          : colors.accentHighContrast,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: colors.operatorButton,
                  inactiveTrackColor: isDark
                      ? const Color(0xFF3D3A3A)
                      : colors.numberButtonBorder,
                  thumbColor: colors.operatorButton,
                  overlayColor: colors.operatorButton.withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                ),
                child: Slider(
                  value: _currentColor.a,
                  min: 0.05,
                  max: 1.0,
                  divisions: 95,
                  onChanged: (val) {
                    setState(() {
                      _currentColor = _currentColor.withValues(alpha: val);
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons: Cancel and Apply
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(hexString),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.operatorButton,
                      foregroundColor: colors.operatorText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
