import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';

import 'constants.dart';
import 'localization.dart';

// カスタム例外クラス
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

// カメラ関連例外
class CameraException extends AppException {
  CameraException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

// 画像処理関連例外
class ImageProcessingException extends AppException {
  ImageProcessingException(
    String message, {
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}

// ストレージ関連例外
class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

// 権限関連例外
class PermissionException extends AppException {
  PermissionException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

// ネットワーク関連例外
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

// エラーハンドリングユーティリティ
class ErrorHandler {
  static final Map<String, int> _errorCounts = {};
  static final List<ErrorReport> _errorReports = [];

  // エラーを処理
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace,
    BuildContext? context,
  ) async {
    try {
      // エラーをログに記録
      await _logError(error, stackTrace);

      // エラーレポートを作成
      final report = await _createErrorReport(error, stackTrace);
      _errorReports.add(report);

      // エラーカウントを更新
      _updateErrorCount(error);

      // ユーザーに通知
      if (context != null) {
        _showErrorToUser(error, context);
      }

      // 必要に応じて自動回復を試行
      await _attemptRecovery(error, context);
    } catch (e) {
      // エラーハンドリング自体でエラーが発生した場合
      debugPrint('Error in error handler: $e');
    }
  }

  // エラーをログに記録
  static Future<void> _logError(dynamic error, StackTrace? stackTrace) async {
    final timestamp = DateTime.now().toIso8601String();
    final errorMessage = error.toString();
    final stackTraceString = stackTrace?.toString() ?? 'No stack trace';

    debugPrint('=== ERROR LOG ===');
    debugPrint('Timestamp: $timestamp');
    debugPrint('Error: $errorMessage');
    debugPrint('Stack Trace: $stackTraceString');
    debugPrint('=================');

    // 本番環境では外部ログサービスに送信
    // await _sendToLogService(timestamp, errorMessage, stackTraceString);
  }

  // エラーレポートを作成
  static Future<ErrorReport> _createErrorReport(
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    return ErrorReport(
      timestamp: DateTime.now(),
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      deviceInfo: await _getDeviceInfo(),
      appVersion: await _getAppVersion(),
      errorType: _getErrorType(error),
    );
  }

  // デバイス情報を取得
  static Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final info = <String, String>{};
      info['platform'] = Platform.operatingSystem;
      info['version'] = Platform.operatingSystemVersion;

      if (Platform.isAndroid) {
        // Android固有の情報
        info['sdk'] = Platform.version;
      } else if (Platform.isIOS) {
        // iOS固有の情報
        info['ios_version'] = Platform.operatingSystemVersion;
      }

      return info;
    } catch (e) {
      return {'error': 'Failed to get device info'};
    }
  }

  // アプリバージョンを取得
  static Future<String> _getAppVersion() async {
    try {
      // package_info_plus を使用してバージョンを取得
      return '1.0.0'; // 実際の実装では package_info_plus を使用
    } catch (e) {
      return 'Unknown';
    }
  }

  // エラータイプを判定
  static String _getErrorType(dynamic error) {
    if (error is CameraException) return 'Camera';
    if (error is ImageProcessingException) return 'ImageProcessing';
    if (error is StorageException) return 'Storage';
    if (error is PermissionException) return 'Permission';
    if (error is NetworkException) return 'Network';
    if (error is PlatformException) return 'Platform';
    if (error is FormatException) return 'Format';
    if (error is TypeError) return 'Type';
    if (error is StateError) return 'State';
    if (error is ArgumentError) return 'Argument';
    if (error is RangeError) return 'Range';
    if (error is UnsupportedError) return 'Unsupported';
    if (error is UnimplementedError) return 'Unimplemented';
    if (error is ConcurrentModificationError) return 'ConcurrentModification';
    if (error is OutOfMemoryError) return 'OutOfMemory';
    if (error is StackOverflowError) return 'StackOverflow';
    if (error is TimeoutException) return 'Timeout';
    if (error is FileSystemException) return 'FileSystem';
    if (error is SocketException) return 'Socket';
    if (error is HttpException) return 'Http';
    return 'Unknown';
  }

  // エラーカウントを更新
  static void _updateErrorCount(dynamic error) {
    final errorType = _getErrorType(error);
    _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;
  }

  // ユーザーにエラーを通知
  static void _showErrorToUser(dynamic error, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    String userMessage;

    // エラータイプに応じてユーザーフレンドリーなメッセージを表示
    if (error is CameraException) {
      userMessage = localizations?.cameraError ?? 'カメラエラーが発生しました';
    } else if (error is ImageProcessingException) {
      userMessage = localizations?.imageProcessingFailed ?? '画像処理に失敗しました';
    } else if (error is StorageException) {
      userMessage = localizations?.saveFailed ?? '保存に失敗しました';
    } else if (error is PermissionException) {
      userMessage = localizations?.permissionDenied ?? '権限が拒否されました';
    } else if (error is NetworkException) {
      userMessage = 'ネットワークエラーが発生しました';
    } else {
      userMessage = localizations?.errorOccurred ?? 'エラーが発生しました';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: localizations?.retry ?? 'リトライ',
          textColor: AppColors.surface,
          onPressed: () {
            // リトライロジックを実装
            _attemptRecovery(error, context);
          },
        ),
      ),
    );
  }

  // 自動回復を試行
  static Future<void> _attemptRecovery(
    dynamic error,
    BuildContext? context,
  ) async {
    if (error is CameraException) {
      await _recoverFromCameraError(context);
    } else if (error is StorageException) {
      await _recoverFromStorageError(context);
    } else if (error is PermissionException) {
      await _recoverFromPermissionError(context);
    }
  }

  // カメラエラーからの回復
  static Future<void> _recoverFromCameraError(BuildContext? context) async {
    try {
      // カメラの再初期化を試行
      await Future.delayed(Duration(milliseconds: 1000));
      // 実際の実装では CameraService.reinitialize() を呼び出し
    } catch (e) {
      debugPrint('Camera recovery failed: $e');
    }
  }

  // ストレージエラーからの回復
  static Future<void> _recoverFromStorageError(BuildContext? context) async {
    try {
      // ストレージの再初期化を試行
      await Future.delayed(Duration(milliseconds: 500));
      // 実際の実装では StorageService.reinitialize() を呼び出し
    } catch (e) {
      debugPrint('Storage recovery failed: $e');
    }
  }

  // 権限エラーからの回復
  static Future<void> _recoverFromPermissionError(BuildContext? context) async {
    try {
      // 権限の再リクエストを試行
      if (context != null) {
        // 権限リクエストダイアログを表示
        // 実際の実装では permission_handler を使用
      }
    } catch (e) {
      debugPrint('Permission recovery failed: $e');
    }
  }

  // エラー統計を取得
  static Map<String, int> getErrorStatistics() {
    return Map.from(_errorCounts);
  }

  // エラーレポートを取得
  static List<ErrorReport> getErrorReports() {
    return List.from(_errorReports);
  }

  // エラー履歴をクリア
  static void clearErrorHistory() {
    _errorCounts.clear();
    _errorReports.clear();
  }

  // 特定のエラータイプの頻度をチェック
  static bool isErrorFrequent(String errorType, {int threshold = 5}) {
    return (_errorCounts[errorType] ?? 0) >= threshold;
  }

  // エラーレポートを外部サービスに送信
  static Future<void> sendErrorReports() async {
    try {
      // 実際の実装では外部サービス（Firebase Crashlytics など）に送信
      for (final report in _errorReports) {
        await _sendReportToService(report);
      }
      _errorReports.clear();
    } catch (e) {
      debugPrint('Failed to send error reports: $e');
    }
  }

  // エラーレポートを外部サービスに送信（実装例）
  static Future<void> _sendReportToService(ErrorReport report) async {
    // 実際の実装では HTTP リクエストを使用
    await Future.delayed(Duration(milliseconds: 100));
  }

  // アプリ全体のエラーハンドリングを設定
  static void setupGlobalErrorHandling() {
    // Flutter エラーハンドリング
    FlutterError.onError = (FlutterErrorDetails details) {
      handleError(details.exception, details.stack, null);
    };

    // 非同期エラーハンドリング
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(error, stack, null);
      return true;
    };
  }
}

// エラーレポートクラス
class ErrorReport {
  final DateTime timestamp;
  final String error;
  final String? stackTrace;
  final Map<String, String> deviceInfo;
  final String appVersion;
  final String errorType;

  ErrorReport({
    required this.timestamp,
    required this.error,
    this.stackTrace,
    required this.deviceInfo,
    required this.appVersion,
    required this.errorType,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'error': error,
      'stackTrace': stackTrace,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'errorType': errorType,
    };
  }
}

// エラー境界ウィジェット
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final Function(dynamic error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
    this.onError,
  }) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();

    // エラーが発生した場合の処理
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _hasError = true;
        _error = details.exception;
        _stackTrace = details.stack;
      });

      widget.onError?.call(details.exception, details.stack);
      ErrorHandler.handleError(details.exception, details.stack, context);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback ?? _buildDefaultErrorWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'エラーが発生しました',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'アプリを再起動してお試しください',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.paddingLarge),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _error = null;
                  _stackTrace = null;
                });
              },
              child: Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

// リトライ機能付きの関数実行
class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic)? retryIf,
  }) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow;
        }

        if (retryIf != null && !retryIf(e)) {
          rethrow;
        }

        await Future.delayed(delay * attempt);
      }
    }

    throw StateError('This should never be reached');
  }
}

// エラー関連のヘルパー関数
class ErrorUtils {
  // プラットフォームエラーを AppException に変換
  static AppException convertPlatformException(PlatformException e) {
    switch (e.code) {
      case 'camera_access_denied':
        return CameraException('カメラへのアクセスが拒否されました', code: e.code);
      case 'camera_not_available':
        return CameraException('カメラが利用できません', code: e.code);
      case 'permission_denied':
        return PermissionException('権限が拒否されました', code: e.code);
      case 'storage_full':
        return StorageException('ストレージが満杯です', code: e.code);
      case 'network_error':
        return NetworkException('ネットワークエラーが発生しました', code: e.code);
      default:
        return AppException('プラットフォームエラー: ${e.message}', code: e.code);
    }
  }

  // ユーザーフレンドリーなエラーメッセージを生成
  static String getUserFriendlyMessage(dynamic error, BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (error is CameraException) {
      return localizations?.cameraError ?? 'カメラエラーが発生しました';
    } else if (error is ImageProcessingException) {
      return localizations?.imageProcessingFailed ?? '画像処理に失敗しました';
    } else if (error is StorageException) {
      return localizations?.saveFailed ?? '保存に失敗しました';
    } else if (error is PermissionException) {
      return localizations?.permissionDenied ?? '権限が拒否されました';
    } else if (error is NetworkException) {
      return 'ネットワークエラーが発生しました';
    } else {
      return localizations?.errorOccurred ?? 'エラーが発生しました';
    }
  }
}
