import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../providers/ai_providers.dart';
import '../services/haptic_service.dart';

/// Daily mood selector widget with energy level
class MoodSelectorDialog extends ConsumerStatefulWidget {
  final Function(String mood, int energyLevel) onMoodSelected;

  const MoodSelectorDialog({
    super.key,
    required this.onMoodSelected,
  });

  @override
  ConsumerState<MoodSelectorDialog> createState() => _MoodSelectorDialogState();
}

class _MoodSelectorDialogState extends ConsumerState<MoodSelectorDialog>
    with SingleTickerProviderStateMixin {
  String? selectedMood;
  int selectedEnergyLevel = 3;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<MoodOption> moods = [
    MoodOption(emoji: '😄', label: 'Great', color: AppColors.successColor),
    MoodOption(emoji: '😊', label: 'Happy', color: AppTheme.primaryPeach),
    MoodOption(emoji: '😐', label: 'Okay', color: AppColors.infoColor),
    MoodOption(emoji: '😩', label: 'Tired', color: AppColors.warningColor),
    MoodOption(emoji: '😰', label: 'Stressed', color: AppColors.errorColor),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceLight,
                AppColors.primaryExtraLight,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPeach.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppTheme.primaryPeach,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How are you feeling?',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Help us adapt your day',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Mood Selection
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: moods.map((mood) {
                  final isSelected = selectedMood == mood.emoji;
                  return GestureDetector(
                    onTap: () {
                      HapticService().lightImpact();
                      setState(() {
                        selectedMood = mood.emoji;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mood.color.withAlpha(25)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? mood.color : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: mood.color.withAlpha(40),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood.emoji,
                            style: TextStyle(
                              fontSize: isSelected ? 40 : 36,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? mood.color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Energy Level Slider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Energy Level',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getEnergyColor(selectedEnergyLevel)
                                .withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$selectedEnergyLevel/5',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _getEnergyColor(selectedEnergyLevel),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 24,
                        ),
                        activeTrackColor: _getEnergyColor(selectedEnergyLevel),
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbColor: _getEnergyColor(selectedEnergyLevel),
                        overlayColor:
                            _getEnergyColor(selectedEnergyLevel).withAlpha(30),
                      ),
                      child: Slider(
                        value: selectedEnergyLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (value) {
                          HapticService().selectionClick();
                          setState(() {
                            selectedEnergyLevel = value.toInt();
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Low',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          'High',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticService().lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Skip for now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: selectedMood == null
                          ? null
                          : () {
                              HapticService().mediumImpact();
                              ref
                                  .read(moodProvider.notifier)
                                  .setMood(selectedMood!, selectedEnergyLevel);
                              widget.onMoodSelected(
                                  selectedMood!, selectedEnergyLevel);
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue'),
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

  Color _getEnergyColor(int level) {
    switch (level) {
      case 1:
        return AppColors.errorColor;
      case 2:
        return AppColors.warningColor;
      case 3:
        return AppColors.infoColor;
      case 4:
        return AppTheme.primaryPeach;
      case 5:
        return AppColors.successColor;
      default:
        return AppColors.infoColor;
    }
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
}
