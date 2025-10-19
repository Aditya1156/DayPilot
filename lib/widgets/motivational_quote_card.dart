import 'package:flutter/material.dart';
import 'dart:math';

/// Card displaying motivational quotes and productivity tips
class MotivationalQuoteCard extends StatefulWidget {
  const MotivationalQuoteCard({super.key});

  @override
  State<MotivationalQuoteCard> createState() => _MotivationalQuoteCardState();
}

class _MotivationalQuoteCardState extends State<MotivationalQuoteCard> {
  late Map<String, String> currentQuote;

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
  }

  void _selectRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote = quotes[random.nextInt(quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectRandomQuote,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Inspiration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: theme.colorScheme.onPrimaryContainer,
                      onPressed: _selectRandomQuote,
                      tooltip: 'New quote',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentQuote['quote'] ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— ${currentQuote['author'] ?? ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
