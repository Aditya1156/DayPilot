import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/utils/modern_theme.dart';
import 'dart:math' as math;

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? category;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.category,
  });
}

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  late AnimationController _typingController;
  bool _isTyping = false;

  final List<Map<String, dynamic>> _quickPrompts = [
    {
      'icon': Icons.computer,
      'title': 'Software Engineer',
      'prompt': 'I want to become a software engineer. What hours should I dedicate to learning and what should my daily routine look like?',
      'gradient': ModernTheme.primaryGradient,
    },
    {
      'icon': Icons.fitness_center,
      'title': 'Fitness Goal',
      'prompt': 'Help me create a balanced routine for fitness and work. I want to exercise daily but maintain productivity.',
      'gradient': ModernTheme.successGradient,
    },
    {
      'icon': Icons.school,
      'title': 'Study Plan',
      'prompt': 'I\'m preparing for exams. Create an optimal study schedule with breaks and revision sessions.',
      'gradient': ModernTheme.accentGradient,
    },
    {
      'icon': Icons.work,
      'title': 'Work-Life Balance',
      'prompt': 'How can I better balance my work and personal life? Suggest a daily routine.',
      'gradient': ModernTheme.warningGradient,
    },
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
    
    // Welcome message
    _messages.add(Message(
      text: '👋 Hi! I\'m your AI productivity assistant. I can help you with:\n\n• Career planning and skill development\n• Creating optimized daily routines\n• Productivity analysis and tips\n• Habit formation strategies\n\nHow can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
      category: 'welcome',
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(
          text: _generateAIResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('software engineer') || lowerMessage.contains('developer')) {
      return '''🎯 **Software Engineer Career Path**

Here's a structured daily routine to become a software engineer:

**Morning (2-3 hours):**
• 6:00 AM - Wake up, exercise (30 min)
• 7:00 AM - Coding practice (DSA) - 1 hour
• 8:00 AM - Breakfast & review yesterday's learning
• 9:00 AM - Deep learning session (new concepts)

**Afternoon (3-4 hours):**
• 1:00 PM - Project building (real applications)
• 3:00 PM - Short break
• 3:30 PM - System design/theory
• 5:00 PM - Code review/open source

**Evening:**
• 7:00 PM - Relax, hobbies, networking
• 8:30 PM - Read tech articles/documentation
• 10:00 PM - Wind down

**Weekly Goals:**
✅ Complete 5 LeetCode problems
✅ Build 1 feature in personal project
✅ Read 3 technical articles
✅ Contribute to 1 open source PR

Would you like me to create this as tasks in your app?''';
    }
    
    if (lowerMessage.contains('fitness') || lowerMessage.contains('exercise')) {
      return '''💪 **Balanced Fitness & Work Routine**

Here's how to maintain both fitness and productivity:

**Early Morning (6:00 AM - 8:00 AM):**
• 6:00 AM - Wake up, hydrate
• 6:15 AM - Workout (strength/cardio alternating)
• 7:15 AM - Protein breakfast
• 7:45 AM - Plan your day

**Work Blocks:**
• 8:00 AM - 12:00 PM - Deep work (4 hours)
• 12:00 PM - Healthy lunch + 20 min walk
• 1:00 PM - 5:00 PM - Focused work with breaks

**Evening:**
• 5:00 PM - Active recovery (yoga/stretching)
• 6:00 PM - Personal time
• 7:00 PM - Light dinner
• 8:00 PM - Leisure/learning
• 10:00 PM - Sleep prep

**Key Principles:**
🔹 Morning workouts boost energy all day
🔹 Protein-rich meals support recovery
🔹 Walking breaks prevent burnout
🔹 Sleep 7-8 hours for muscle recovery

Shall I add these as routines in your calendar?''';
    }
    
    if (lowerMessage.contains('study') || lowerMessage.contains('exam')) {
      return '''📚 **Optimal Study Schedule for Exams**

Science-backed study routine for maximum retention:

**Pomodoro Study Blocks:**
• Study: 50 minutes focused
• Break: 10 minutes active rest
• Repeat 3x, then 30-minute break

**Daily Schedule:**
**Morning (Peak Learning):**
• 7:00 AM - Hardest subject (2 hours)
• 9:30 AM - Practice problems (1 hour)

**Afternoon:**
• 2:00 PM - Medium difficulty topics (2 hours)
• 4:30 PM - Active recall & flashcards

**Evening:**
• 7:00 PM - Review & summarize day's learning
• 8:00 PM - Light reading/notes review

**Weekly Pattern:**
• Mon-Fri: New content + practice
• Saturday: Full revision + mock tests
• Sunday: Light review + rest

**Study Techniques:**
✨ Active recall (test yourself)
✨ Spaced repetition (review old topics)
✨ Teach concepts to solidify understanding
✨ Practice past papers weekly

Ready to turn this into a routine?''';
    }
    
    if (lowerMessage.contains('balance') || lowerMessage.contains('work-life')) {
      return '''⚖️ **Work-Life Balance Strategy**

Creating boundaries for sustainable success:

**Time Blocking System:**

**Work Hours (8 hours):**
• 9:00 AM - 1:00 PM - Deep work
• 1:00 PM - 2:00 PM - Lunch break
• 2:00 PM - 6:00 PM - Meetings & tasks

**Personal Time (Non-negotiable):**
• Morning: 1 hour for yourself
• Evening: 3+ hours for family/hobbies
• Weekend: 1 full day off

**Boundaries:**
🚫 No work emails after 6 PM
🚫 No work on Sundays
✅ Dedicated family dinner time
✅ 30-min daily exercise
✅ Weekly hobby time

**Energy Management:**
• High energy AM → Complex tasks
• Post-lunch dip → Lighter work
• Evening → Creative/low-stress tasks

**Weekly Review:**
Every Sunday, assess:
- Work achievements
- Personal goals met
- Energy levels
- Adjustments needed

Want me to set up boundary reminders?''';
    }
    
    // Generic productivity response
    return '''💡 **Productivity Insights**

Based on your question, here are some personalized tips:

**Time Management:**
• Use the 2-minute rule: If it takes < 2 min, do it now
• Batch similar tasks together
• Schedule breaks (you can't sprint a marathon!)

**Focus Techniques:**
• Deep work blocks: 90-120 minutes
• Eliminate distractions (phone on silent)
• One task at a time (no multitasking)

**Energy Optimization:**
• Track your peak hours and schedule important work then
• Take regular breaks to maintain performance
• Get 7-9 hours of quality sleep

**Habit Building:**
• Start small (2-minute habits)
• Stack habits (link to existing routines)
• Track streaks for motivation

Would you like me to help you create a specific routine or analyze your current productivity patterns?''';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ModernTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(theme),
              
              // Quick Prompts (show only when no user messages)
              if (_messages.where((m) => m.isUser).isEmpty)
                _buildQuickPrompts(),
              
              // Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessage(_messages[index], theme);
                  },
                ),
              ),
              
              // Input Field
              _buildInputField(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ModernTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: ModernTheme.successGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.successGreen.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _quickPrompts.length,
          itemBuilder: (context, index) {
            final prompt = _quickPrompts[index];
            return GestureDetector(
              onTap: () => _sendMessage(prompt['prompt']),
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: prompt['gradient'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (prompt['gradient'] as LinearGradient).colors[0].withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      prompt['icon'],
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      prompt['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
      ),
    );
  }

  Widget _buildMessage(Message message, ThemeData theme) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: message.isUser 
                ? ModernTheme.primaryGradient 
                : null,
            color: message.isUser ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : ModernTheme.textDark,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
        ),
        child: AnimatedBuilder(
          animation: _typingController,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final value = (_typingController.value + delay) % 1.0;
                final scale = math.sin(value * math.pi) * 0.5 + 0.5;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryPurple.withOpacity(0.3 + scale * 0.7),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ModernTheme.surfaceGray,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
