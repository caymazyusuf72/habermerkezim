import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haber_merkezi/core/services/logger_service.dart';

/// Uygulama başlatma aşaması
enum StartupPhase {
  initial,
  coreServices,
  dataServices,
  uiServices,
  completed,
}

/// Başlatma görevi tanımı
class StartupTask {
  final String name;
  final Future<void> Function() execute;
  final StartupPhase phase;
  final bool isRequired;
  final Duration timeout;

  const StartupTask({
    required this.name,
    required this.execute,
    required this.phase,
    this.isRequired = true,
    this.timeout = const Duration(seconds: 10),
  });
}

/// Başlatma metrikleri
class StartupMetrics {
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, Duration> taskDurations = {};
  final Map<String, String> taskErrors = {};

  StartupMetrics() : startTime = DateTime.now();

  Duration get totalDuration =>
      (endTime ?? DateTime.now()).difference(startTime);

  bool get isCompleted => endTime != null;

  int get successCount =>
      taskDurations.length - taskErrors.length;

  int get failureCount => taskErrors.length;

  void recordTask(String name, Duration duration) {
    taskDurations[name] = duration;
  }

  void recordError(String name, String error) {
    taskErrors[name] = error;
  }

  void complete() {
    endTime = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'totalDuration': totalDuration.inMilliseconds,
        'tasks': taskDurations.map(
          (k, v) => MapEntry(k, v.inMilliseconds),
        ),
        'errors': taskErrors,
        'successCount': successCount,
        'failureCount': failureCount,
      };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Startup Metrics ===');
    buffer.writeln('Total: ${totalDuration.inMilliseconds}ms');
    buffer.writeln('Tasks: ${taskDurations.length} ($successCount OK, $failureCount failed)');
    for (final entry in taskDurations.entries) {
      final status = taskErrors.containsKey(entry.key) ? '❌' : '✅';
      buffer.writeln('  $status ${entry.key}: ${entry.value.inMilliseconds}ms');
    }
    return buffer.toString();
  }
}

/// Uygulama başlatma state
class AppStartupState {
  final StartupPhase currentPhase;
  final double progress;
  final String currentTask;
  final bool isCompleted;
  final bool hasError;
  final String? errorMessage;
  final StartupMetrics? metrics;

  const AppStartupState({
    this.currentPhase = StartupPhase.initial,
    this.progress = 0.0,
    this.currentTask = '',
    this.isCompleted = false,
    this.hasError = false,
    this.errorMessage,
    this.metrics,
  });

  AppStartupState copyWith({
    StartupPhase? currentPhase,
    double? progress,
    String? currentTask,
    bool? isCompleted,
    bool? hasError,
    String? errorMessage,
    StartupMetrics? metrics,
  }) {
    return AppStartupState(
      currentPhase: currentPhase ?? this.currentPhase,
      progress: progress ?? this.progress,
      currentTask: currentTask ?? this.currentTask,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      metrics: metrics ?? this.metrics,
    );
  }
}

/// Uygulama başlatma servisi - Lazy initialization ve sıralı servis başlatma
class AppStartupService extends StateNotifier<AppStartupState> {
  final LoggerService _logger;
  final List<StartupTask> _tasks = [];
  StartupMetrics? _metrics;

  AppStartupService(this._logger) : super(const AppStartupState());

  /// Başlatma görevi ekle
  void registerTask(StartupTask task) {
    _tasks.add(task);
  }

  /// Birden fazla görev ekle
  void registerTasks(List<StartupTask> tasks) {
    _tasks.addAll(tasks);
  }

  /// Tüm görevleri sırayla çalıştır
  Future<StartupMetrics> initialize() async {
    _metrics = StartupMetrics();
    final totalTasks = _tasks.length;

    if (totalTasks == 0) {
      _metrics!.complete();
      state = state.copyWith(
        isCompleted: true,
        progress: 1.0,
        currentPhase: StartupPhase.completed,
        metrics: _metrics,
      );
      return _metrics!;
    }

    // Görevleri aşamaya göre sırala
    _tasks.sort((a, b) => a.phase.index.compareTo(b.phase.index));

    _logger.info('Başlatma başlıyor: $totalTasks görev', tag: 'AppStartup');

    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final progress = (i + 1) / totalTasks;

      state = state.copyWith(
        currentPhase: task.phase,
        currentTask: task.name,
        progress: progress,
      );

      final stopwatch = Stopwatch()..start();

      try {
        await task.execute().timeout(task.timeout);
        stopwatch.stop();
        _metrics!.recordTask(task.name, stopwatch.elapsed);

        _logger.debug(
          '✅ ${task.name}: ${stopwatch.elapsedMilliseconds}ms',
          tag: 'AppStartup',
        );
      } catch (e, stackTrace) {
        stopwatch.stop();
        _metrics!.recordTask(task.name, stopwatch.elapsed);
        _metrics!.recordError(task.name, e.toString());

        _logger.error(
          '❌ ${task.name} başarısız: $e',
          tag: 'AppStartup',
          error: e,
          stackTrace: stackTrace,
        );

        if (task.isRequired) {
          _metrics!.complete();
          state = state.copyWith(
            hasError: true,
            errorMessage: '${task.name} başarısız: $e',
            metrics: _metrics,
          );
          return _metrics!;
        }
      }
    }

    _metrics!.complete();

    _logger.info(_metrics.toString(), tag: 'AppStartup');

    state = state.copyWith(
      isCompleted: true,
      progress: 1.0,
      currentPhase: StartupPhase.completed,
      metrics: _metrics,
    );

    return _metrics!;
  }

  /// Metrikleri al
  StartupMetrics? get metrics => _metrics;

  /// Görevleri temizle
  void clearTasks() {
    _tasks.clear();
  }
}

/// Lazy initialization wrapper
class LazyInitializer<T> {
  final Future<T> Function() _factory;
  T? _instance;
  bool _isInitializing = false;
  Completer<T>? _completer;

  LazyInitializer(this._factory);

  bool get isInitialized => _instance != null;

  Future<T> get instance async {
    if (_instance != null) return _instance!;

    if (_isInitializing) {
      return _completer!.future;
    }

    _isInitializing = true;
    _completer = Completer<T>();

    try {
      _instance = await _factory();
      _completer!.complete(_instance);
      return _instance!;
    } catch (e) {
      _completer!.completeError(e);
      _isInitializing = false;
      _completer = null;
      rethrow;
    }
  }

  void reset() {
    _instance = null;
    _isInitializing = false;
    _completer = null;
  }
}

/// App startup provider
final appStartupServiceProvider =
    StateNotifierProvider<AppStartupService, AppStartupState>((ref) {
  final logger = LoggerService();
  return AppStartupService(logger);
});