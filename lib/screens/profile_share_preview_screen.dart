import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/profile_share_card.dart';

/// Full-screen preview screen for sharing profile card.
class ProfileSharePreviewScreen extends StatefulWidget {
  ProfileSharePreviewScreen({super.key});

  @override
  State<ProfileSharePreviewScreen> createState() =>
      _ProfileSharePreviewScreenState();
}

class _ProfileSharePreviewScreenState extends State<ProfileSharePreviewScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isLoading = false;
  ProfileShareCard? _card;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final card = await ProfileShareCard.create(context);
    if (mounted) {
      setState(() {
        _card = card;
      });
    }
  }

  Future<Uint8List?> _captureCardAsImage() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing card: $e');
      return null;
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isLoading = true);

    try {
      final bytes = await _captureCardAsImage();
      if (bytes == null) {
        _showError('Failed to capture image');
        return;
      }

      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'poker_profile_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        _showSuccess('Saved to gallery');
      } else {
        _showError('Failed to save image');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareImage() async {
    setState(() => _isLoading = true);

    try {
      final bytes = await _captureCardAsImage();
      if (bytes == null) {
        _showError('Failed to capture image');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/poker_profile_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out my poker training progress!');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    return Scaffold(
      appBar: AppBar(
        title: Text(isRu ? 'Поделиться профилем' : 'Share Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _card == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      RepaintBoundary(key: _cardKey, child: _card),
                      const SizedBox(height: 32),
                      Text(
                        isRu
                            ? 'Поделитесь своим прогрессом'
                            : 'Share your progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _saveToGallery,
                          icon: const Icon(Icons.save_alt),
                          label: Text(
                            isRu ? 'Сохранить в галерею' : 'Save to Gallery',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: _isLoading ? null : _shareImage,
                          icon: const Icon(Icons.share),
                          label: Text(isRu ? 'Поделиться' : 'Share'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
