// services/gif_service.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../utils/constants.dart';

class GifService {
  // 比較GIFを作成（シンプル実装）
  Future<Uint8List> createComparisonGif(
    Uint8List originalImage,
    Uint8List dotArtImage, {
    ComparisonLayout layout = ComparisonLayout.sideBySide,
    int frameDelay = AppConstants.gifFrameDelay,
    int cycles = 3,
  }) async {
    try {
      final originalImg = img.decodeImage(originalImage);
      final dotArtImg = img.decodeImage(dotArtImage);

      if (originalImg == null || dotArtImg == null) {
        throw Exception('画像のデコードに失敗しました');
      }

      // 画像サイズを統一
      final targetSize = _calculateTargetSize(originalImg, dotArtImg);
      final resizedOriginal = img.copyResize(
        originalImg,
        width: targetSize.width.toInt(),
        height: targetSize.height.toInt(),
      );
      final resizedDotArt = img.copyResize(
        dotArtImg,
        width: targetSize.width.toInt(),
        height: targetSize.height.toInt(),
      );

      // フレームリストを作成
      final frames = <img.Image>[];

      switch (layout) {
        case ComparisonLayout.sideBySide:
          frames.addAll(
            _createSideBySideFrames(resizedOriginal, resizedDotArt, cycles),
          );
          break;
        case ComparisonLayout.topBottom:
          frames.addAll(
            _createTopBottomFrames(resizedOriginal, resizedDotArt, cycles),
          );
          break;
        case ComparisonLayout.overlay:
          frames.addAll(
            _createOverlayFrames(resizedOriginal, resizedDotArt, cycles),
          );
          break;
      }

      // 単一のGIFエンコード（静的画像として）
      if (frames.isNotEmpty) {
        final gifBytes = img.encodeGif(frames.first);
        return Uint8List.fromList(gifBytes);
      } else {
        throw Exception('フレームの作成に失敗しました');
      }
    } catch (e) {
      throw Exception('GIF作成に失敗しました: $e');
    }
  }

  // 目標サイズを計算
  Size _calculateTargetSize(img.Image img1, img.Image img2) {
    final maxWidth = img1.width > img2.width ? img1.width : img2.width;
    final maxHeight = img1.height > img2.height ? img1.height : img2.height;

    // 最大サイズを制限
    const maxSize = 512;
    if (maxWidth > maxSize || maxHeight > maxSize) {
      final ratio = maxSize / (maxWidth > maxHeight ? maxWidth : maxHeight);
      return Size((maxWidth * ratio), (maxHeight * ratio));
    }

    return Size(maxWidth.toDouble(), maxHeight.toDouble());
  }

  // 左右比較フレーム作成
  List<img.Image> _createSideBySideFrames(
    img.Image originalImg,
    img.Image dotArtImg,
    int cycles,
  ) {
    final frames = <img.Image>[];
    final combinedWidth = originalImg.width + dotArtImg.width;
    final combinedHeight = originalImg.height > dotArtImg.height
        ? originalImg.height
        : dotArtImg.height;

    // 両方の画像を並べたフレームを作成
    final combinedFrame = img.Image(
      width: combinedWidth,
      height: combinedHeight,
    );

    img.fill(combinedFrame, color: img.ColorRgb8(255, 255, 255));

    // オリジナル画像を左側に配置
    img.compositeImage(combinedFrame, originalImg, dstX: 0, dstY: 0);

    // ドット絵を右側に配置
    img.compositeImage(
      combinedFrame,
      dotArtImg,
      dstX: originalImg.width,
      dstY: 0,
    );

    frames.add(combinedFrame);
    return frames;
  }

  // 上下比較フレーム作成
  List<img.Image> _createTopBottomFrames(
    img.Image originalImg,
    img.Image dotArtImg,
    int cycles,
  ) {
    final frames = <img.Image>[];
    final combinedWidth = originalImg.width > dotArtImg.width
        ? originalImg.width
        : dotArtImg.width;
    final combinedHeight = originalImg.height + dotArtImg.height;

    // 両方の画像を縦に並べたフレームを作成
    final combinedFrame = img.Image(
      width: combinedWidth,
      height: combinedHeight,
    );

    img.fill(combinedFrame, color: img.ColorRgb8(255, 255, 255));

    // オリジナル画像を上側に配置
    img.compositeImage(combinedFrame, originalImg, dstX: 0, dstY: 0);

    // ドット絵を下側に配置
    img.compositeImage(
      combinedFrame,
      dotArtImg,
      dstX: 0,
      dstY: originalImg.height,
    );

    frames.add(combinedFrame);
    return frames;
  }

  // オーバーレイフレーム作成
  List<img.Image> _createOverlayFrames(
    img.Image originalImg,
    img.Image dotArtImg,
    int cycles,
  ) {
    final frames = <img.Image>[];

    // ブレンドした画像を作成
    final blendedFrame = _blendImages(originalImg, dotArtImg, 0.5);
    frames.add(blendedFrame);

    return frames;
  }

  // 画像をブレンド
  img.Image _blendImages(img.Image img1, img.Image img2, double alpha) {
    final blended = img.Image(width: img1.width, height: img1.height);

    for (int y = 0; y < img1.height; y++) {
      for (int x = 0; x < img1.width; x++) {
        final pixel1 = img1.getPixel(x, y);
        final pixel2 = img2.getPixel(x, y);

        final r1 = pixel1.r;
        final g1 = pixel1.g;
        final b1 = pixel1.b;

        final r2 = pixel2.r;
        final g2 = pixel2.g;
        final b2 = pixel2.b;

        final r = ((r1 * (1 - alpha)) + (r2 * alpha)).round();
        final g = ((g1 * (1 - alpha)) + (g2 * alpha)).round();
        final b = ((b1 * (1 - alpha)) + (b2 * alpha)).round();

        blended.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }

    return blended;
  }

  // スライドショーGIFを作成（シンプル実装）
  Future<Uint8List> createSlideshow(
    List<Uint8List> images, {
    int frameDelay = 1000,
    Size? targetSize,
  }) async {
    try {
      if (images.isEmpty) {
        throw Exception('画像が指定されていません');
      }

      // 最初の画像をGIFとして保存
      final firstImage = img.decodeImage(images.first);
      if (firstImage == null) {
        throw Exception('最初の画像のデコードに失敗しました');
      }

      final resizedImage = targetSize != null
          ? img.copyResize(
              firstImage,
              width: targetSize.width.toInt(),
              height: targetSize.height.toInt(),
            )
          : firstImage;

      final gifBytes = img.encodeGif(resizedImage);
      return Uint8List.fromList(gifBytes);
    } catch (e) {
      throw Exception('スライドショー作成に失敗しました: $e');
    }
  }

  // 単一画像をGIFに変換
  Future<Uint8List> convertImageToGif(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('画像のデコードに失敗しました');
      }

      final gifBytes = img.encodeGif(image);
      return Uint8List.fromList(gifBytes);
    } catch (e) {
      throw Exception('GIF変換に失敗しました: $e');
    }
  }
}
