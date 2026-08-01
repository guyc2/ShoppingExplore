import 'package:flutter/material.dart';

/// Semantic color tokens for ShoppingExplore Material 3 themes.
/// Avoid using hardcoded hex values in UI presentation widgets; use [Theme.of(context).colorScheme] instead.
abstract class AppColors {
  // Brand Vibrant Accents
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimaryContainer = Color(0xFF312E81);

  static const Color secondary = Color(0xFF10B981); // Crisp Emerald
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD1FAE5);
  static const Color onSecondaryContainer = Color(0xFF065F46);

  static const Color tertiary = Color(0xFFF59E0B); // Amber Accent
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Light Theme Surfaces & Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color onBackgroundLight = Color(0xFF0F172A);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color onSurfaceVariantLight = Color(0xFF475569);
  static const Color outlineLight = Color(0xFFCBD5E1);

  // Dark Theme Surfaces & Backgrounds (Sleek Dark Slate)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color onBackgroundDark = Color(0xFFF8FAFC);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);
  static const Color outlineDark = Color(0xFF475569);

  // Feedback Colors
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // Priority Colors (for ShoppingItem badges)
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityNone = Color(0xFF64748B);
}
