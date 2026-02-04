import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../../data/models/supabase_diagnostic_improved.dart';

class DiagnosticImprovedApp extends StatefulWidget {
  const DiagnosticImprovedApp({super.key});

  @override
  State<DiagnosticImprovedApp> createState() => _DiagnosticImprovedAppState();
}

class _DiagnosticImprovedAppState extends State<DiagnosticImprovedApp> {
  final SupabaseDiagnosticImproved _diagnostic = SupabaseDiagnosticImproved();
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
      
      final results = await _diagnostic.runDiagnostic();
      setState(() {
        _logs = results;
      });
      
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

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yalitza Salas - Diagnostic',
      theme: AppTheme.lightTheme,
      home: DiagnosticImprovedScreen(
        isRunning: _isRunning,
        logs: _logs,
        onRetry: _runDiagnostic,
        onCopy: _copyLogs,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiagnosticImprovedScreen extends StatelessWidget {
  const DiagnosticImprovedScreen({
    super.key,
    required this.isRunning,
    required this.logs,
    required this.onRetry,
    required this.onCopy,
  });

  final bool isRunning;
  final List<String> logs;
  final VoidCallback onRetry;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Diagnostic'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (logs.isNotEmpty)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Logs',
            ),
        ],
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
                          'Found ${logs.where((log) => log.startsWith('✅')).length} working tables',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diagnostic Logs',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        if (logs.isNotEmpty)
                          Text(
                            '${logs.length} lines',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: logs.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Running diagnostic...'),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: logs.map((log) => Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                  child: Text(
                                    log,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      color: log.startsWith('✅') 
                                          ? AppTheme.successColor
                                          : log.startsWith('❌')
                                              ? AppTheme.errorColor
                                              : log.startsWith('🔍') || log.startsWith('📡') || log.startsWith('📋') || log.startsWith('📊') || log.startsWith('🏁')
                                                  ? AppTheme.primaryColor
                                                  : Colors.black87,
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
            
            // Quick Actions
            if (logs.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Share these logs with the developer to fix the connection',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
