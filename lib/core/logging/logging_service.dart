import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/cache_config.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance {
    _instance ??= LoggingService._internal();
    return _instance!;
  }

  LoggingService._internal();

  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  static const int _maxLogFiles = 5;
  static const String _logFileName = 'app_logs.txt';
  
  File? _logFile;
  bool _isInitialized = false;
  final List<LogEntry> _logBuffer = [];
  Timer? _flushTimer;

  /// Initialize logging service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLogFile();
      _startPeriodicFlush();
      _setupCrashlytics();
      _isInitialized = true;
      
      info('LoggingService', 'Logging service initialized');
    } catch (e) {
      debugPrint('Failed to initialize logging service: $e');
    }
  }

  /// Initialize log file
  Future<void> _initializeLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      _logFile = File('${logDir.path}/$_logFileName');
      
      // Rotate log file if it's too large
      if (await _logFile!.exists()) {
        final fileSize = await _logFile!.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFiles();
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize log file: $e');
    }
  }

  /// Rotate log files
  Future<void> _rotateLogFiles() async {
    try {
      final directory = _logFile!.parent;
      
      // Move existing log files
      for (int i = _maxLogFiles - 1; i >= 1; i--) {
        final oldFile = File('${directory.path}/${_logFileName}.$i');
        final newFile = File('${directory.path}/${_logFileName}.${i + 1}');
        
        if (await oldFile.exists()) {
          if (i == _maxLogFiles - 1) {
            await oldFile.delete(); // Delete oldest file
          } else {
            await oldFile.rename(newFile.path);
          }
        }
      }
      
      // Move current log file
      if (await _logFile!.exists()) {
        await _logFile!.rename('${directory.path}/${_logFileName}.1');
      }
      
      // Create new log file
      _logFile = File('${directory.path}/$_logFileName');
    } catch (e) {
      debugPrint('Failed to rotate log files: $e');
    }
  }

  /// Setup Firebase Crashlytics
  void _setupCrashlytics() {
    if (!kDebugMode) {
      // Set up custom crash reporting
      FlutterError.onError = (FlutterErrorDetails details) {
        fatal('FlutterError', details.exception.toString(), 
              stackTrace: details.stack);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      // Catch errors outside of Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        fatal('PlatformError', error.toString(), stackTrace: stack);
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  /// Start periodic flush of log buffer
  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushLogs();
    });
  }

  /// Log debug message
  void debug(String tag, String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.debug, tag, message, data: data);
  }

  /// Log info message
  void info(String tag, String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, tag, message, data: data);
  }

  /// Log warning message
  void warning(String tag, String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.warning, tag, message, data: data);
  }

  /// Log error message
  void error(String tag, String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.error, tag, message, 
         error: error, stackTrace: stackTrace, data: data);
    
    // Report to Crashlytics in production
    if (!kDebugMode && error != null) {
      FirebaseCrashlytics.instance.recordError(
        error, 
        stackTrace, 
        reason: message,
        information: data?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      );
    }
  }

  /// Log fatal error
  void fatal(String tag, String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.fatal, tag, message, 
         error: error, stackTrace: stackTrace, data: data);
    
    // Always report fatal errors to Crashlytics
    if (error != null) {
      FirebaseCrashlytics.instance.recordError(
        error, 
        stackTrace, 
        fatal: true,
        reason: message,
        information: data?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      );
    }
  }

  /// Internal logging method
  void _log(LogLevel level, String tag, String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    // Add to buffer
    _logBuffer.add(logEntry);

    // Print to console in debug mode
    if (kDebugMode) {
      _printToConsole(logEntry);
    }

    // Flush immediately for errors and fatal logs
    if (level == LogLevel.error || level == LogLevel.fatal) {
      _flushLogs();
    }
  }

  /// Print log entry to console
  void _printToConsole(LogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    final levelStr = entry.level.name.toUpperCase().padRight(7);
    final tag = entry.tag.padRight(15);
    
    String logLine = '[$timestamp] $levelStr [$tag] ${entry.message}';
    
    if (entry.data != null && entry.data!.isNotEmpty) {
      logLine += ' | Data: ${jsonEncode(entry.data)}';
    }
    
    if (entry.error != null) {
      logLine += ' | Error: ${entry.error}';
    }
    
    debugPrint(logLine);
    
    if (entry.stackTrace != null) {
      debugPrint('Stack trace:\n${entry.stackTrace}');
    }
  }

  /// Flush logs to file
  Future<void> _flushLogs() async {
    if (_logBuffer.isEmpty || _logFile == null) return;

    try {
      final logEntries = List<LogEntry>.from(_logBuffer);
      _logBuffer.clear();

      final logLines = logEntries.map((entry) => entry.toLogString()).join('\n');
      await _logFile!.writeAsString('$logLines\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to flush logs: $e');
    }
  }

  /// Get recent logs
  Future<List<String>> getRecentLogs({int maxLines = 100}) async {
    try {
      if (_logFile == null || !await _logFile!.exists()) {
        return [];
      }

      final content = await _logFile!.readAsString();
      final lines = content.split('\n').where((line) => line.isNotEmpty).toList();
      
      return lines.length > maxLines 
          ? lines.sublist(lines.length - maxLines)
          : lines;
    } catch (e) {
      debugPrint('Failed to get recent logs: $e');
      return [];
    }
  }

  /// Export logs for support
  Future<String?> exportLogs() async {
    try {
      await _flushLogs(); // Ensure all logs are written
      
      if (_logFile == null || !await _logFile!.exists()) {
        return null;
      }

      return await _logFile!.readAsString();
    } catch (e) {
      error('LoggingService', 'Failed to export logs', error: e);
      return null;
    }
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      _logBuffer.clear();
      
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
        await _initializeLogFile();
      }
      
      info('LoggingService', 'Logs cleared');
    } catch (e) {
      error('LoggingService', 'Failed to clear logs', error: e);
    }
  }

  /// Set user identifier for crash reporting
  Future<void> setUserIdentifier(String userId) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      info('LoggingService', 'User identifier set for crash reporting');
    } catch (e) {
      error('LoggingService', 'Failed to set user identifier', error: e);
    }
  }

  /// Set custom key for crash reporting
  Future<void> setCustomKey(String key, String value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      error('LoggingService', 'Failed to set custom key', error: e);
    }
  }

  /// Dispose resources
  void dispose() {
    _flushTimer?.cancel();
    _flushLogs();
  }

  /// Check if logging is initialized
  bool get isInitialized => _isInitialized;
}

/// Log entry model
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? data;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
    this.data,
  });

  String toLogString() {
    final timestampStr = timestamp.toIso8601String();
    final levelStr = level.name.toUpperCase();
    
    String logLine = '[$timestampStr] $levelStr [$tag] $message';
    
    if (data != null && data!.isNotEmpty) {
      logLine += ' | Data: ${jsonEncode(data)}';
    }
    
    if (error != null) {
      logLine += ' | Error: $error';
    }
    
    if (stackTrace != null) {
      logLine += ' | Stack: ${stackTrace.toString().replaceAll('\n', '\\n')}';
    }
    
    return logLine;
  }
}
