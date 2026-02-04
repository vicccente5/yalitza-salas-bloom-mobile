import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/models/supabase_diagnostic.dart';

class DiagnosticApp extends StatefulWidget {
  const DiagnosticApp({super.key});

  @override
  State<DiagnosticApp> createState() => _DiagnosticAppState();
}

class _DiagnosticAppState extends State<DiagnosticApp> {
  final SupabaseDiagnostic _diagnostic = SupabaseDiagnostic();
  bool _isRunning = false;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunning = true;
      _logs = ['🔍 Starting Supabase diagnostic...'];
    });

    try {
      await _diagnostic.initializeSupabase();
      _addLog('✅ Supabase initialized');
      
      await _diagnostic.runDiagnostic();
      _addLog('🏁 Diagnostic completed');
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yalitza Salas - Diagnostic',
      theme: AppTheme.lightTheme,
      home: DiagnosticScreen(
        isRunning: _isRunning,
        logs: _logs,
        onRetry: _runDiagnostic,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiagnosticScreen extends StatelessWidget {
  const DiagnosticScreen({
    super.key,
    required this.isRunning,
    required this.logs,
    required this.onRetry,
  });

  final bool isRunning;
  final List<String> logs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Diagnostic'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isRunning ? Icons.sync : Icons.check_circle,
                    color: isRunning ? AppTheme.primaryColor : AppTheme.successColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRunning ? 'Running Diagnostic...' : 'Diagnostic Complete',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Checking Supabase connection and tables',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRunning)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnostic Logs',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: logs.isEmpty
                          ? const Center(
                              child: Text('No logs yet...'),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: logs.map((log) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    log,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'What this diagnostic checks:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...const [
                    '• Supabase connection status',
                    '• Available tables in database',
                    '• Table structure and fields',
                    '• Sample data from each table',
                  ].map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.primaryColor)),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
