import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

import '../utils/constants.dart';

class DotArtService {
  // ドット絵変換のメインメソッド
  Future<Uint8List> convertToDotArt(
    Uint8List imageBytes, {
    int dotSize = AppConstants.defaultDotSize,
    int colorPalette = AppConstants.defaultColorPalette,
    DotStyle dotStyle = DotStyle.square,
    double contrast = 1.0,
    double brightness = 1.0,
    double saturation = 1.0,
  }) async {
    try {
      // 画像をデコード
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('画像のデコードに失敗しました');
      }

      // 画像を正方形にクロップ
      final croppedImage = _cropToSquare(originalImage);

      // ドットアート用にリサイズ
      final dotWidth = (croppedImage.width / dotSize).round();
      final dotHeight = (croppedImage.height / dotSize).round();
      final resizedImage = img.copyResize(
        croppedImage,
        width: dotWidth,
        height: dotHeight,
      );

      // 色調調整
      final adjustedImage = _adjustImageColors(
        resizedImage,
        contrast,
        brightness,
        saturation,
      );

      // カラーパレット削減
      final palettizedImage = _reduceColorPalette(adjustedImage, colorPalette);

      // ドット絵スタイル適用
      final dotArtImage = _applyDotStyle(palettizedImage, dotSize, dotStyle);

      // アニメ風効果を追加
      final animeStyleImage = _applyAnimeStyle(dotArtImage);

      // PNG形式でエンコード
      final pngBytes = img.encodePng(animeStyleImage);

      return Uint8List.fromList(pngBytes);
    } catch (e) {
      throw Exception('ドット絵変換に失敗しました: $e');
    }
  }

  // 画像を正方形にクロップ
  img.Image _cropToSquare(img.Image image) {
    final minSize = math.min(image.width, image.height);
    final offsetX = (image.width - minSize) ~/ 2;
    final offsetY = (image.height - minSize) ~/ 2;

    return img.copyCrop(
      image,
      x: offsetX,
      y: offsetY,
      width: minSize,
      height: minSize,
    );
  }

  // 色調調整
  img.Image _adjustImageColors(
    img.Image image,
    double contrast,
    double brightness,
    double saturation,
  ) {
    var adjustedImage = image;

    // コントラスト調整
    if (contrast != 1.0) {
      adjustedImage = img.adjustColor(adjustedImage, contrast: contrast);
    }

    // 明度調整
    if (brightness != 1.0) {
      adjustedImage = img.adjustColor(adjustedImage, brightness: brightness);
    }

    // 彩度調整
    if (saturation != 1.0) {
      adjustedImage = img.adjustColor(adjustedImage, saturation: saturation);
    }

    return adjustedImage;
  }

  // カラーパレット削減
  img.Image _reduceColorPalette(img.Image image, int colorCount) {
    // K-meansクラスタリングを使用してカラーパレットを削減
    final pixelData = <Color>[];

    // 全ピクセルの色を取得
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final color = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );
        pixelData.add(color);
      }
    }

    // K-meansクラスタリング（簡易版）
    final palette = _generateColorPalette(pixelData, colorCount);

    // 各ピクセルを最も近いパレット色に置き換え
    final newImage = img.Image(width: image.width, height: image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final originalColor = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );
        final nearestColor = _findNearestColor(originalColor, palette);
        newImage.setPixel(
          x,
          y,
          img.ColorRgb8(
            nearestColor.red,
            nearestColor.green,
            nearestColor.blue,
          ),
        );
      }
    }

    return newImage;
  }

  // カラーパレット生成（K-meansクラスタリング簡易版）
  List<Color> _generateColorPalette(List<Color> pixelData, int colorCount) {
    if (pixelData.length <= colorCount) {
      return pixelData.toSet().toList();
    }

    final palette = <Color>[];
    final random = math.Random();

    // 初期クラスタ中心をランダムに選択
    for (int i = 0; i < colorCount; i++) {
      palette.add(pixelData[random.nextInt(pixelData.length)]);
    }

    // K-meansイテレーション（簡易版）
    for (int iter = 0; iter < 5; iter++) {
      final clusters = List.generate(colorCount, (index) => <Color>[]);

      // 各ピクセルを最も近いクラスタに割り当て
      for (final color in pixelData) {
        int nearestIndex = 0;
        double minDistance = double.infinity;

        for (int i = 0; i < palette.length; i++) {
          final distance = _colorDistance(color, palette[i]);
          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }

        clusters[nearestIndex].add(color);
      }

      // クラスタ中心を更新
      for (int i = 0; i < palette.length; i++) {
        if (clusters[i].isNotEmpty) {
          palette[i] = _averageColor(clusters[i]);
        }
      }
    }

    return palette;
  }

  // 色の距離を計算
  double _colorDistance(Color color1, Color color2) {
    final dr = color1.red - color2.red;
    final dg = color1.green - color2.green;
    final db = color1.blue - color2.blue;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  // 色の平均を計算
  Color _averageColor(List<Color> colors) {
    if (colors.isEmpty) return Colors.black;

    int totalR = 0, totalG = 0, totalB = 0;
    for (final color in colors) {
      totalR += color.red;
      totalG += color.green;
      totalB += color.blue;
    }

    return Color.fromRGBO(
      totalR ~/ colors.length,
      totalG ~/ colors.length,
      totalB ~/ colors.length,
      1.0,
    );
  }

  // 最も近い色を見つける
  Color _findNearestColor(Color color, List<Color> palette) {
    Color nearestColor = palette[0];
    double minDistance = _colorDistance(color, nearestColor);

    for (final paletteColor in palette) {
      final distance = _colorDistance(color, paletteColor);
      if (distance < minDistance) {
        minDistance = distance;
        nearestColor = paletteColor;
      }
    }

    return nearestColor;
  }

  // ドットスタイルを適用
  img.Image _applyDotStyle(img.Image image, int dotSize, DotStyle dotStyle) {
    final newImage = img.Image(
      width: image.width * dotSize,
      height: image.height * dotSize,
    );

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final color = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );

        // ドット形状を描画
        _drawDot(newImage, x * dotSize, y * dotSize, dotSize, color, dotStyle);
      }
    }

    return newImage;
  }

  // ドットを描画
  void _drawDot(
    img.Image image,
    int startX,
    int startY,
    int size,
    Color color,
    DotStyle style,
  ) {
    final center = size / 2.0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final dx = x - center;
        final dy = y - center;
        final distance = math.sqrt(dx * dx + dy * dy);

        bool shouldDraw = false;

        switch (style) {
          case DotStyle.square:
            shouldDraw = true;
            break;
          case DotStyle.circle:
            shouldDraw = distance <= center * 0.9;
            break;
          case DotStyle.diamond:
            shouldDraw = (dx.abs() + dy.abs()) <= center;
            break;
          case DotStyle.pixel:
            shouldDraw = x < size - 1 && y < size - 1;
            break;
        }

        if (shouldDraw) {
          final pixelX = startX + x;
          final pixelY = startY + y;

          if (pixelX >= 0 &&
              pixelX < image.width &&
              pixelY >= 0 &&
              pixelY < image.height) {
            image.setPixel(
              pixelX,
              pixelY,
              img.ColorRgb8(color.red, color.green, color.blue),
            );
          }
        }
      }
    }
  }

  // アニメ風効果を適用
  img.Image _applyAnimeStyle(img.Image image) {
    // シャープネスを強化
    final sharpened = img.convolution(
      image,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );

    // 軽微なガウシアンブラーでアンチエイリアス
    final blurred = img.gaussianBlur(sharpened, radius: 0.5);

    // コントラストを強化
    final contrasted = img.adjustColor(blurred, contrast: 1.2);

    // 彩度を強化
    final saturated = img.adjustColor(contrasted, saturation: 1.3);

    return saturated;
  }

  // プレビュー用の小さなドット絵を生成
  Future<Uint8List> generatePreview(
    Uint8List imageBytes, {
    int previewSize = 64,
    int dotSize = 4,
    int colorPalette = 16,
  }) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('画像のデコードに失敗しました');
      }

      final croppedImage = _cropToSquare(originalImage);
      final resizedImage = img.copyResize(
        croppedImage,
        width: previewSize,
        height: previewSize,
      );
      final palettizedImage = _reduceColorPalette(resizedImage, colorPalette);

      final pngBytes = img.encodePng(palettizedImage);
      return Uint8List.fromList(pngBytes);
    } catch (e) {
      throw Exception('プレビュー生成に失敗しました: $e');
    }
  }

  // 設定に基づいてドット絵の品質を調整
  Map<String, dynamic> getOptimalSettings(int imageSize) {
    if (imageSize > 1000) {
      return {'dotSize': 12, 'colorPalette': 32, 'quality': 'high'};
    } else if (imageSize > 500) {
      return {'dotSize': 8, 'colorPalette': 24, 'quality': 'medium'};
    } else {
      return {'dotSize': 6, 'colorPalette': 16, 'quality': 'low'};
    }
  }

  // カスタムカラーパレットを適用
  img.Image applyCustomPalette(img.Image image, List<Color> customPalette) {
    final newImage = img.Image(width: image.width, height: image.height);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final originalColor = Color.fromARGB(
          255,
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        );
        final nearestColor = _findNearestColor(originalColor, customPalette);
        newImage.setPixel(
          x,
          y,
          img.ColorRgb8(
            nearestColor.red,
            nearestColor.green,
            nearestColor.blue,
          ),
        );
      }
    }

    return newImage;
  }

  // アニメ風カラーパレットを生成
  List<Color> generateAnimePalette() {
    return [
      // 肌色系
      Color(0xFFFFDDC7),
      Color(0xFFFFCBB3),
      Color(0xFFE8A789),
      Color(0xFFD4956B),

      // 髪色系
      Color(0xFF4A3728),
      Color(0xFF8B4513),
      Color(0xFFDAA520),
      Color(0xFFFFD700),

      // 目色系
      Color(0xFF4169E1),
      Color(0xFF228B22),
      Color(0xFF8B4513),
      Color(0xFF4B0082),

      // 服装系
      Color(0xFFFFFFFF),
      Color(0xFF000000),
      Color(0xFFFF69B4),
      Color(0xFF87CEEB),

      // 背景系
      Color(0xFFF0F8FF),
      Color(0xFFFFE4E1),
      Color(0xFFE6E6FA),
      Color(0xFFF5F5DC),

      // アクセント
      Color(0xFFFF1493),
      Color(0xFF00CED1),
      Color(0xFF32CD32),
      Color(0xFFFF8C00),
    ];
  }
}
