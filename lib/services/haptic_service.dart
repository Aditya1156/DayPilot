import 'package:flutter/services.dart';

/// Service for providing haptic feedback throughout the app
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  Future<void> initialize() async {
    // No initialization needed for built-in HapticFeedback
  }

  /// Light tap feedback for button presses
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for task completion
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for important actions
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click for toggles and switches
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Custom success pattern
  Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Custom error pattern
  Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Custom warning pattern
  Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }
}
