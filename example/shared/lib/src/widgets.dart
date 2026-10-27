// The building blocks of both screens, drawn like the native example apps: rounded cards on a
// grouped background, uppercase section headers and iOS system colors (light and dark).

import 'package:flutter/material.dart';

class Palette {
  const Palette._(this.dark);

  factory Palette.of(BuildContext context) => Palette._(Theme.of(context).brightness == Brightness.dark);

  final bool dark;

  Color get background => dark ? Colors.black : const Color(0xFFF2F2F7);
  Color get card => dark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get inset => dark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
  Color get label => dark ? Colors.white : Colors.black;
  Color get secondaryLabel => dark ? const Color(0x99EBEBF5) : const Color(0x993C3C43);
  Color get separator => dark ? const Color(0x99545458) : const Color(0x4A3C3C43);

  Color get blue => dark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
  Color get purple => dark ? const Color(0xFFBF5AF2) : const Color(0xFFAF52DE);
  Color get green => dark ? const Color(0xFF30D158) : const Color(0xFF34C759);
  Color get red => dark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);
  Color get orange => dark ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500);
  Color get gray => const Color(0xFF8E8E93);

  /// The hero card's blue gradient.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A85FF), Color(0xFF3B3BD9)],
  );
}

ThemeData exampleTheme(Brightness brightness) {
  final palette = Palette._(brightness == Brightness.dark);
  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: palette.blue, brightness: brightness, primary: palette.blue),
    scaffoldBackgroundColor: palette.background,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.label,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(color: palette.separator, thickness: 0.5, space: 0.5),
  );
}

/// A rounded card on the grouped background.
class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = EdgeInsets.zero, this.color, this.radius = 14});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color ?? Palette.of(context).card,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: padding,
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 4, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(fontSize: 13, color: Palette.of(context).secondaryLabel),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// A small rounded label: the key chip and the callback badges.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.color, this.monospace = false});

  final String text;
  final Color color;
  final bool monospace;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: monospace ? 'Menlo' : null,
            fontFamilyFallback: monospace ? const ['Courier', 'monospace'] : null,
          ),
        ),
      );
}

/// Label on the left, value on the right; used by the configuration card.
class ValueRow extends StatelessWidget {
  const ValueRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 15, color: Palette.of(context).secondaryLabel)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      );
}

const monospace = TextStyle(fontFamily: 'Menlo', fontFamilyFallback: ['Courier', 'monospace']);
