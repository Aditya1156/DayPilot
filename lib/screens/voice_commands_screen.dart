import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/utils/modern_theme.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/providers/app_providers.dart';
import 'dart:math' as math;

class VoiceCommand {
  final String text;
  final String action;
  final DateTime timestamp;
  final bool success;

  VoiceCommand({
    required this.text,
    required this.action,
    required this.timestamp,
    required this.success,
  });
}

class VoiceCommandsScreen extends ConsumerStatefulWidget {
  const VoiceCommandsScreen({super.key});

  @override
  ConsumerState<VoiceCommandsScreen> createState() => _VoiceCommandsScreenState();
}

class _VoiceCommandsScreenState extends ConsumerState<VoiceCommandsScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseController;
  final List<VoiceCommand> _commandHistory = [];
  String _currentTranscript = '';

  final List<Map<String, dynamic>> _quickCommands = [
    {
      'icon': Icons.add_task,
      'title': 'Add Task',
      'example': '"Add buy groceries to my tasks"',
      'color': ModernTheme.primaryPurple,
    },
    {
      'icon': Icons.check_circle,
      'title': 'Complete Task',
      'example': '"Mark exercise as complete"',
      'color': ModernTheme.successGreen,
    },
    {
      'icon': Icons.schedule,
      'title': 'Set Reminder',
      'example': '"Remind me to call John at 3pm"',
      'color': ModernTheme.warningOrange,
    },
    {
      'icon': Icons.navigation,
      'title': 'Navigate',
      'example': '"Go to analytics"',
      'color': ModernTheme.accentCyan,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _currentTranscript = '';
        _simulateListening();
      }
    });
  }

  void _simulateListening() {
    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || !_isListening) return;
      
      setState(() {
        _currentTranscript = 'Add meeting with team to my tasks';
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _processVoiceCommand(_currentTranscript);
      });
    });
  }

  void _processVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    String action = 'Unknown command';
    bool success = false;

    if (lowerCommand.contains('add') && lowerCommand.contains('task')) {
      // Extract task name
      final taskName = command.replaceAll(RegExp(r'add|to my tasks?', caseSensitive: false), '').trim();
      
      final now = DateTime.now();
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: taskName,
        description: 'Added via voice command',
        category: TaskCategory.personal,
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        status: TaskStatus.pending,
      );
      
      ref.read(tasksProvider.notifier).addTask(newTask);
      action = 'Added task: $taskName';
      success = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $action'),
          backgroundColor: ModernTheme.successGreen,
        ),
      );
    } else if (lowerCommand.contains('complete') || lowerCommand.contains('mark')) {
      action = 'Completed task';
      success = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Task marked as complete'),
          backgroundColor: ModernTheme.successGreen,
        ),
      );
    } else if (lowerCommand.contains('remind')) {
      action = 'Reminder set';
      success = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Reminder created'),
          backgroundColor: ModernTheme.accentCyan,
        ),
      );
    } else if (lowerCommand.contains('go to') || lowerCommand.contains('show')) {
      if (lowerCommand.contains('analytics')) {
        action = 'Navigating to Analytics';
        success = true;
        Navigator.pushNamed(context, '/analytics');
      } else if (lowerCommand.contains('routine')) {
        action = 'Navigating to Routines';
        success = true;
        Navigator.pushNamed(context, '/routines');
      }
    }

    setState(() {
      _commandHistory.insert(
        0,
        VoiceCommand(
          text: command,
          action: action,
          timestamp: DateTime.now(),
          success: success,
        ),
      );
      _isListening = false;
      _currentTranscript = '';
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
              _buildHeader(theme),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Voice visualizer
                      _buildVoiceVisualizer(),
                      
                      const SizedBox(height: 32),
                      
                      // Current transcript
                      if (_isListening || _currentTranscript.isNotEmpty)
                        _buildTranscriptCard(),
                      
                      if (!_isListening && _currentTranscript.isEmpty)
                        _buildQuickCommands(),
                      
                      const SizedBox(height: 24),
                      
                      // Command history
                      if (_commandHistory.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recent Commands',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._commandHistory.take(5).map((cmd) => _buildHistoryItem(cmd)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _toggleListening,
        backgroundColor: _isListening ? ModernTheme.errorRed : null,
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Commands',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hands-free task management',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ModernTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceVisualizer() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _isListening ? 1.0 + math.sin(_pulseController.value * math.pi * 2) * 0.1 : 1.0;
        final opacity = _isListening ? 0.3 + math.sin(_pulseController.value * math.pi * 2) * 0.2 : 0.1;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            if (_isListening)
                Container(
                  width: 220 * scale,
                  height: 220 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ModernTheme.primaryPurple.withAlpha((opacity * 255).round()),
                        ModernTheme.primaryPurple.withAlpha((0 * 255).round()),
                      ],
                    ),
                  ),
                ),
            
            // Middle ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [
                      ModernTheme.primaryPurple.withAlpha((0.2 * 255).round()),
                      ModernTheme.primaryBlue.withAlpha((0.2 * 255).round()),
                    ],
                ),
              ),
            ),
            
            // Main button
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: _isListening ? ModernTheme.primaryGradient : LinearGradient(
                  colors: [
                    ModernTheme.textLight,
                    ModernTheme.textLight.withAlpha((0.8 * 255).round()),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? ModernTheme.primaryPurple : ModernTheme.textLight).withAlpha((0.4 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 48,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTranscriptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isListening)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hearing, color: ModernTheme.primaryPurple),
                SizedBox(width: 8),
                Text(
                  'Listening...',
                  style: TextStyle(
                    color: ModernTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              _currentTranscript,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickCommands() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Commands',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _quickCommands.length,
          itemBuilder: (context, index) {
            final cmd = _quickCommands[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cmd['color'].withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(cmd['icon'], color: cmd['color'], size: 32),
                  const Spacer(),
                  Text(
                    cmd['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cmd['example'],
                    style: TextStyle(
                      color: ModernTheme.textLight,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryItem(VoiceCommand cmd) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (cmd.success ? ModernTheme.successGreen : ModernTheme.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
              child: Icon(
                cmd.success ? Icons.check : Icons.close,
                color: cmd.success ? ModernTheme.successGreen : ModernTheme.errorRed.withAlpha((0.1 * 255).round()),
              ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cmd.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cmd.action,
                  style: TextStyle(
                    color: ModernTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
