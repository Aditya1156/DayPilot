import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Card displaying motivational quotes and productivity tips
class MotivationalQuoteCard extends StatefulWidget {
  const MotivationalQuoteCard({super.key});

  @override
  State<MotivationalQuoteCard> createState() => _MotivationalQuoteCardState();
}

class _MotivationalQuoteCardState extends State<MotivationalQuoteCard> {
  late Map<String, String> currentQuote;
  bool _isVisible = true;

  final List<Map<String, String>> quotes = [
    {
      'quote': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
    },
    {
      'quote': 'Success is the sum of small efforts repeated day in and day out.',
      'author': 'Robert Collier',
    },
    {
      'quote': 'Don\'t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'quote': 'The way to get started is to quit talking and begin doing.',
      'author': 'Walt Disney',
    },
    {
      'quote': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
    },
    {
      'quote': 'You don\'t have to be great to start, but you have to start to be great.',
      'author': 'Zig Ziglar',
    },
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'quote': 'Small daily improvements over time lead to stunning results.',
      'author': 'Robin Sharma',
    },
    {
      'quote': 'Your limitation—it\'s only your imagination.',
      'author': 'Anonymous',
    },
    {
      'quote': 'Push yourself, because no one else is going to do it for you.',
      'author': 'Anonymous',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomQuote();
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final visible = prefs.getBool('quote_visible') ?? true;
    if (mounted) {
      setState(() {
        _isVisible = visible;
      });
    }
  }

  Future<void> _saveVisibility(bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quote_visible', visible);
  }

  void _selectRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote = quotes[random.nextInt(quotes.length)];
    });
  }

  void _dismissCard() {
    setState(() {
      _isVisible = false;
    });
    _saveVisibility(false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
            theme.colorScheme.secondary.withAlpha((0.05 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Quote content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Daily Inspiration',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        // Refresh button
                        InkWell(
                          onTap: _selectRandomQuote,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.refresh,
                                size: 16,
                                color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                              ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${currentQuote['quote'] ?? ''}"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '— ${currentQuote['author'] ?? ''}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Close button
              InkWell(
                onTap: _dismissCard,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                      color: theme.colorScheme.onSurface.withAlpha((0.4 * 255).round()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
