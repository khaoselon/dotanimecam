// services/gif_service.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../utils/constants.dart';

class GifService {
  // 比較GIFを作成
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

      // GIFアニメーション作成
      final gifEncoder = img.GifEncoder();
      final gifData = <int>[];

      // レイアウトに応じてフレームを生成
      switch (layout) {
        case ComparisonLayout.sideBySide:
          _addSideBySideFrames(
            animation,
            resizedOriginal,
            resizedDotArt,
            frameDelay,
            cycles,
          );
          break;
        case ComparisonLayout.topBottom:
          _addTopBottomFrames(
            animation,
            resizedOriginal,
            resizedDotArt,
            frameDelay,
            cycles,
          );
          break;
        case ComparisonLayout.overlay:
          _addOverlayFrames(
            animation,
            resizedOriginal,
            resizedDotArt,
            frameDelay,
            cycles,
          );
          break;
      }

      // GIFエンコード
      final gifBytes = img.encodeGifAnimation(animation);
      return Uint8List.fromList(gifBytes);
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
      return Size((maxWidth * ratio).toInt(), (maxHeight * ratio).toInt());
    }

    return Size(maxWidth, maxHeight);
  }

  // 左右比較フレーム追加
  void _addSideBySideFrames(
    img.Animation animation,
    img.Image originalImg,
    img.Image dotArtImg,
    int frameDelay,
    int cycles,
  ) {
    final combinedWidth = originalImg.width + dotArtImg.width;
    final combinedHeight = originalImg.height > dotArtImg.height
        ? originalImg.height
        : dotArtImg.height;

    for (int cycle = 0; cycle < cycles; cycle++) {
      // フレーム1: オリジナル画像のみ
      final frame1 = img.Image(combinedWidth, combinedHeight);
      img.fill(frame1, img.getColor(255, 255, 255));
      img.drawImage(frame1, originalImg, dstX: 0, dstY: 0);
      animation.addFrame(frame1);

      // フレーム2: 両方の画像
      final frame2 = img.Image(combinedWidth, combinedHeight);
      img.fill(frame2, img.getColor(255, 255, 255));
      img.drawImage(frame2, originalImg, dstX: 0, dstY: 0);
      img.drawImage(frame2, dotArtImg, dstX: originalImg.width, dstY: 0);
      animation.addFrame(frame2);

      // フレーム3: ドット絵のみ
      final frame3 = img.Image(combinedWidth, combinedHeight);
      img.fill(frame3, img.getColor(255, 255, 255));
      img.drawImage(frame3, dotArtImg, dstX: originalImg.width, dstY: 0);
      animation.addFrame(frame3);
    }
  }

  // 上下比較フレーム追加
  void _addTopBottomFrames(
    img.Animation animation,
    img.Image originalImg,
    img.Image dotArtImg,
    int frameDelay,
    int cycles,
  ) {
    final combinedWidth = originalImg.width > dotArtImg.width
        ? originalImg.width
        : dotArtImg.width;
    final combinedHeight = originalImg.height + dotArtImg.height;

    for (int cycle = 0; cycle < cycles; cycle++) {
      // フレーム1: オリジナル画像のみ
      final frame1 = img.Image(combinedWidth, combinedHeight);
      img.fill(frame1, img.getColor(255, 255, 255));
      img.drawImage(frame1, originalImg, dstX: 0, dstY: 0);
      animation.addFrame(frame1);

      // フレーム2: 両方の画像
      final frame2 = img.Image(combinedWidth, combinedHeight);
      img.fill(frame2, img.getColor(255, 255, 255));
      img.drawImage(frame2, originalImg, dstX: 0, dstY: 0);
      img.drawImage(frame2, dotArtImg, dstX: 0, dstY: originalImg.height);
      animation.addFrame(frame2);

      // フレーム3: ドット絵のみ
      final frame3 = img.Image(combinedWidth, combinedHeight);
      img.fill(frame3, img.getColor(255, 255, 255));
      img.drawImage(frame3, dotArtImg, dstX: 0, dstY: originalImg.height);
      animation.addFrame(frame3);
    }
  }

  // オーバーレイフレーム追加
  void _addOverlayFrames(
    img.Animation animation,
    img.Image originalImg,
    img.Image dotArtImg,
    int frameDelay,
    int cycles,
  ) {
    final targetWidth = originalImg.width;
    final targetHeight = originalImg.height;

    for (int cycle = 0; cycle < cycles; cycle++) {
      // フレーム1: オリジナル画像
      animation.addFrame(
        img.copyResize(originalImg, width: targetWidth, height: targetHeight),
      );

      // フレーム2: フェードイン効果
      for (int i = 0; i < 5; i++) {
        final alpha = (i + 1) / 5.0;
        final blendedFrame = _blendImages(originalImg, dotArtImg, alpha);
        animation.addFrame(blendedFrame);
      }

      // フレーム3: ドット絵
      animation.addFrame(
        img.copyResize(dotArtImg, width: targetWidth, height: targetHeight),
      );

      // フレーム4: フェードアウト効果
      for (int i = 4; i >= 0; i--) {
        final alpha = (i + 1) / 5.0;
        final blendedFrame = _blendImages(originalImg, dotArtImg, alpha);
        animation.addFrame(blendedFrame);
      }
    }
  }

  // 画像をブレンド
  img.Image _blendImages(img.Image img1, img.Image img2, double alpha) {
    final blended = img.Image(img1.width, img1.height);

    for (int y = 0; y < img1.height; y++) {
      for (int x = 0; x < img1.width; x++) {
        final pixel1 = img1.getPixel(x, y);
        final pixel2 = img2.getPixel(x, y);

        final r1 = img.getRed(pixel1);
        final g1 = img.getGreen(pixel1);
        final b1 = img.getBlue(pixel1);

        final r2 = img.getRed(pixel2);
        final g2 = img.getGreen(pixel2);
        final b2 = img.getBlue(pixel2);

        final r = ((r1 * (1 - alpha)) + (r2 * alpha)).round();
        final g = ((g1 * (1 - alpha)) + (g2 * alpha)).round();
        final b = ((b1 * (1 - alpha)) + (b2 * alpha)).round();

        blended.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return blended;
  }

  // スライドショーGIFを作成
  Future<Uint8List> createSlideshow(
    List<Uint8List> images, {
    int frameDelay = 1000,
    Size? targetSize,
  }) async {
    try {
      final animation = img.Animation();

      for (final imageBytes in images) {
        final image = img.decodeImage(imageBytes);
        if (image != null) {
          final resizedImage = targetSize != null
              ? img.copyResize(
                  image,
                  width: targetSize.width.toInt(),
                  height: targetSize.height.toInt(),
                )
              : image;
          animation.addFrame(resizedImage);
        }
      }

      final gifBytes = img.encodeGifAnimation(animation);
      return Uint8List.fromList(gifBytes);
    } catch (e) {
      throw Exception('スライドショー作成に失敗しました: $e');
    }
  }
}
