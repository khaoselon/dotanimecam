// services/camera_service.dart
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraService {
  static CameraService? _instance;
  CameraService._internal();

  factory CameraService() {
    _instance ??= CameraService._internal();
    return _instance!;
  }

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;
  int _selectedCameraIndex = 0;

  // 初期化
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();

      if (_cameras != null && _cameras!.isNotEmpty) {
        await _initializeCameraController(_selectedCameraIndex);
      } else {
        throw Exception('利用可能なカメラが見つかりません');
      }
    } catch (e) {
      print('カメラ初期化エラー: $e');
      throw Exception('カメラの初期化に失敗しました: $e');
    }
  }

  // カメラコントローラーを初期化
  Future<void> _initializeCameraController(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('利用可能なカメラがありません');
    }

    final camera = _cameras![cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;

      // デフォルトでフラッシュを自動に設定
      await _controller!.setFlashMode(FlashMode.auto);

      // フォーカスモードを自動に設定
      await _controller!.setFocusMode(FocusMode.auto);

      // 露出モードを自動に設定
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (e) {
      print('カメラコントローラー初期化エラー: $e');
      throw Exception('カメラコントローラーの初期化に失敗しました: $e');
    }
  }

  // 権限チェック
  Future<bool> checkPermissions() async {
    final cameraPermission = await Permission.camera.status;
    final storagePermission = await Permission.storage.status;

    return cameraPermission.isGranted && storagePermission.isGranted;
  }

  // 権限リクエスト
  Future<bool> requestPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final storagePermission = await Permission.storage.request();

    return cameraPermission.isGranted && storagePermission.isGranted;
  }

  // カメラ切り替え
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      throw Exception('切り替え可能なカメラがありません');
    }

    await _controller?.dispose();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

    await _initializeCameraController(_selectedCameraIndex);
  }

  // 写真撮影
  Future<XFile> takePicture() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('カメラが初期化されていません');
    }

    try {
      // 撮影前の処理
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setExposureMode(ExposureMode.locked);

      // 写真撮影
      final image = await _controller!.takePicture();

      // 撮影後の処理
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);

      // 撮影音（iOSでは自動、Androidでは手動）
      if (Platform.isAndroid) {
        SystemSound.play(SystemSoundType.click);
      }

      return image;
    } catch (e) {
      print('写真撮影エラー: $e');
      throw Exception('写真撮影に失敗しました: $e');
    }
  }

  // フラッシュモード設定
  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('カメラが初期化されていません');
    }

    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      print('フラッシュモード設定エラー: $e');
      throw Exception('フラッシュモードの設定に失敗しました: $e');
    }
  }

  // フォーカス設定
  Future<void> setFocusPoint(Offset point) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('カメラが初期化されていません');
    }

    try {
      await _controller!.setFocusPoint(point);
      await _controller!.setExposurePoint(point);
    } catch (e) {
      print('フォーカス設定エラー: $e');
      throw Exception('フォーカスの設定に失敗しました: $e');
    }
  }

  // 露出補正
  Future<void> setExposureOffset(double offset) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('カメラが初期化されていません');
    }

    try {
      await _controller!.setExposureOffset(offset);
    } catch (e) {
      print('露出補正エラー: $e');
      throw Exception('露出補正の設定に失敗しました: $e');
    }
  }

  // ズーム設定
  Future<void> setZoomLevel(double zoom) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('カメラが初期化されていません');
    }

    try {
      final maxZoom = await _controller!.getMaxZoomLevel();
      final minZoom = await _controller!.getMinZoomLevel();

      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
    } catch (e) {
      print('ズーム設定エラー: $e');
      throw Exception('ズームの設定に失敗しました: $e');
    }
  }

  // 解像度設定
  Future<void> setResolution(ResolutionPreset preset) async {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('利用可能なカメラがありません');
    }

    await _controller?.dispose();

    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      preset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  // カメラ情報取得
  CameraInfo getCameraInfo() {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('利用可能なカメラがありません');
    }

    final currentCamera = _cameras![_selectedCameraIndex];
    return CameraInfo(
      name: currentCamera.name,
      lensDirection: currentCamera.lensDirection,
      sensorOrientation: currentCamera.sensorOrientation,
      isInitialized: _isInitialized,
      hasFlash: true, // 実際の実装では機能確認が必要
      supportedResolutions: ResolutionPreset.values,
    );
  }

  // リソース解放
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  // ゲッター
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  List<CameraDescription>? get cameras => _cameras;
  int get selectedCameraIndex => _selectedCameraIndex;
}

// カメラ情報クラス
class CameraInfo {
  final String name;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;
  final bool isInitialized;
  final bool hasFlash;
  final List<ResolutionPreset> supportedResolutions;

  CameraInfo({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
    required this.isInitialized,
    required this.hasFlash,
    required this.supportedResolutions,
  });

  bool get isFront => lensDirection == CameraLensDirection.front;
  bool get isBack => lensDirection == CameraLensDirection.back;

  String get directionName {
    switch (lensDirection) {
      case CameraLensDirection.front:
        return 'フロント';
      case CameraLensDirection.back:
        return 'バック';
      case CameraLensDirection.external:
        return '外部';
      default:
        return '不明';
    }
  }
}
