import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class MediaGalleryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final int initialIndex;
  final String contactName;

  const MediaGalleryScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    required this.contactName,
  });

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _images => widget.mediaItems
      .where((m) => (m['type'] ?? '') == 'image' && (m['link'] ?? '').isNotEmpty)
      .toList();

  void _openFullscreen(int index) {
    setState(() {
      _isGridView = false;
      _currentIndex = index;
      _pageController = PageController(initialPage: index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: app_theme.backgroundColor,
        foregroundColor: app_theme.lavenderWhite,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contactName,
              style: const TextStyle(
                color: app_theme.lavenderWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_images.length} media',
              style: const TextStyle(
                color: app_theme.secondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            if (!_isGridView) {
              setState(() => _isGridView = true);
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back, color: app_theme.lavenderWhite),
        ),
        actions: [
          if (!_isGridView)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${_images.length}',
                  style: const TextStyle(color: app_theme.secondary, fontSize: 14),
                ),
              ),
            ),
          if (_isGridView)
            IconButton(
              icon: const Icon(CupertinoIcons.photo_on_rectangle,
                  color: app_theme.lavenderWhite),
              onPressed: null,
            ),
        ],
      ),
      body: _images.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.photo, color: app_theme.secondary, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No media shared yet',
                    style: TextStyle(color: app_theme.secondary, fontSize: 16),
                  ),
                ],
              ),
            )
          : _isGridView
              ? _buildGrid()
              : _buildFullscreen(),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final item = _images[index];
        return GestureDetector(
          onTap: () => _openFullscreen(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item['link'] as String,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: app_theme.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: app_theme.cyanGlow,
                        strokeWidth: 2,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: app_theme.surface,
                  child: const Icon(Icons.broken_image_outlined,
                      color: app_theme.secondary, size: 32),
                ),
              ),
              if ((item['caption'] as String? ?? '').isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: Text(
                      item['caption'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullscreen() {
    return PhotoViewGallery.builder(
      pageController: _pageController,
      itemCount: _images.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      builder: (context, index) {
        final item = _images[index];
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(item['link'] as String),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image_outlined,
                color: app_theme.error, size: 48),
          ),
        );
      },
      loadingBuilder: (_, __) => const Center(
        child: CircularProgressIndicator(color: app_theme.cyanGlow),
      ),
    );
  }
}
