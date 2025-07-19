// services/storage_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _galleryKey = 'gallery_items';
  static const String _settingsKey = 'app_settings';

  // 画像を保存
  Future<String?> saveImage(Uint8List imageBytes, {String? customName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final galleryDir = Directory(
        '${directory.path}/${AppConstants.galleryDirectoryName}',
      );

      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          customName ?? '${AppConstants.originalImagePrefix}$timestamp.jpg';
      final file = File('${galleryDir.path}/$filename');

      await file.writeAsBytes(imageBytes);

      // ギャラリーアイテムを記録
      await _addToGallery(file.path, 'image');

      return file.path;
    } catch (e) {
      print('画像保存エラー: $e');
      return null;
    }
  }

  // GIFを保存
  Future<String?> saveGif(Uint8List gifBytes, {String? customName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final galleryDir = Directory(
        '${directory.path}/${AppConstants.galleryDirectoryName}',
      );

      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          customName ?? '${AppConstants.comparisonGifPrefix}$timestamp.gif';
      final file = File('${galleryDir.path}/$filename');

      await file.writeAsBytes(gifBytes);

      // ギャラリーアイテムを記録
      await _addToGallery(file.path, 'gif');

      return file.path;
    } catch (e) {
      print('GIF保存エラー: $e');
      return null;
    }
  }

  // 一時的な画像を保存（シェア用）
  Future<String?> saveTemporaryImage(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/temp_$timestamp.jpg');

      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      print('一時画像保存エラー: $e');
      return null;
    }
  }

  // 一時的なGIFを保存（シェア用）
  Future<String?> saveTemporaryGif(Uint8List gifBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/temp_$timestamp.gif');

      await file.writeAsBytes(gifBytes);
      return file.path;
    } catch (e) {
      print('一時GIF保存エラー: $e');
      return null;
    }
  }

  // ギャラリーアイテムをリスト
  Future<List<GalleryItem>> getGalleryItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_galleryKey) ?? [];

      final items = <GalleryItem>[];
      for (final itemJson in itemsJson) {
        final parts = itemJson.split('|');
        if (parts.length >= 3) {
          final filePath = parts[0];
          final type = parts[1];
          final timestamp = int.tryParse(parts[2]) ?? 0;

          // ファイルの存在確認
          if (await File(filePath).exists()) {
            items.add(
              GalleryItem(
                filePath: filePath,
                type: type,
                timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
              ),
            );
          }
        }
      }

      // 新しい順にソート
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return items;
    } catch (e) {
      print('ギャラリーアイテム取得エラー: $e');
      return [];
    }
  }

  // ギャラリーアイテムを追加
  Future<void> _addToGallery(String filePath, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_galleryKey) ?? [];

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newItem = '$filePath|$type|$timestamp';

      itemsJson.add(newItem);

      // 最大アイテム数制限
      if (itemsJson.length > AppConstants.maxGalleryItems) {
        final oldestItem = itemsJson.removeAt(0);
        final oldestPath = oldestItem.split('|')[0];

        // 古いファイルを削除
        try {
          await File(oldestPath).delete();
        } catch (e) {
          print('古いファイル削除エラー: $e');
        }
      }

      await prefs.setStringList(_galleryKey, itemsJson);
    } catch (e) {
      print('ギャラリーアイテム追加エラー: $e');
    }
  }

  // ギャラリーアイテムを削除
  Future<bool> deleteGalleryItem(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_galleryKey) ?? [];

      // アイテムをリストから削除
      itemsJson.removeWhere((item) => item.startsWith(filePath));
      await prefs.setStringList(_galleryKey, itemsJson);

      // ファイルを削除
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (e) {
      print('ギャラリーアイテム削除エラー: $e');
      return false;
    }
  }

  // キャッシュをクリア
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = tempDir.listSync();

      for (final file in tempFiles) {
        if (file is File && file.path.contains('temp_')) {
          await file.delete();
        }
      }
    } catch (e) {
      print('キャッシュクリアエラー: $e');
    }
  }

  // 設定を保存
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in settings.entries) {
        final key = '${_settingsKey}_${entry.key}';
        final value = entry.value;

        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        }
      }
    } catch (e) {
      print('設定保存エラー: $e');
    }
  }

  // 設定を読み込み
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = <String, dynamic>{};

      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_settingsKey)) {
          final settingKey = key.substring(_settingsKey.length + 1);
          final value = prefs.get(key);
          settings[settingKey] = value;
        }
      }

      return settings;
    } catch (e) {
      print('設定読み込みエラー: $e');
      return {};
    }
  }

  // ストレージ使用量を取得
  Future<int> getStorageUsage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final galleryDir = Directory(
        '${directory.path}/${AppConstants.galleryDirectoryName}',
      );

      if (!await galleryDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      final files = galleryDir.listSync(recursive: true);

      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('ストレージ使用量取得エラー: $e');
      return 0;
    }
  }
}

// ギャラリーアイテムクラス
class GalleryItem {
  final String filePath;
  final String type;
  final DateTime timestamp;

  GalleryItem({
    required this.filePath,
    required this.type,
    required this.timestamp,
  });

  bool get isImage => type == 'image';
  bool get isGif => type == 'gif';

  String get fileName => filePath.split('/').last;

  Future<Uint8List> getBytes() async {
    final file = File(filePath);
    return await file.readAsBytes();
  }
}
