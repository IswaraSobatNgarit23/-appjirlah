import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/volcano_status.dart';
import '../theme/app_theme.dart';

class VisualCctvCard extends StatefulWidget {
  final VolcanoStatus status;

  const VisualCctvCard({
    super.key, 
    required this.status,
  });

  @override
  State<VisualCctvCard> createState() => _VisualCctvCardState();
}

class _VisualCctvCardState extends State<VisualCctvCard> {
  late YoutubePlayerController _ytController;
  bool _showCctv = false;
  int _selectedCameraIndex = 0;

  final List<Map<String, String>> _cameras = [
    {'name': 'Kamera 1 (Utama)', 'id': 'WyVEvfReElw'},
    {'name': 'Kamera 2 (Pantauan)', 'id': '1rbBmhRQ5Gs'},
    {'name': 'Kamera 3 (Alternatif)', 'id': 'Hr1Sv6B-kfM'},
  ];

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: _cameras[0]['id']!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: true,
        showFullscreenButton: true,
        loop: true,
      ),
    );
  }

  void _switchCamera(int index) {
    if (_selectedCameraIndex == index) return;
    setState(() {
      _selectedCameraIndex = index;
    });
    _ytController.loadVideoById(videoId: _cameras[index]['id']!);
  }

  @override
  void dispose() {
    _ytController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.status.imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.ewsColors.glassBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: context.ewsColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    title: 'Foto Visual',
                    icon: Icons.image_rounded,
                    isActive: !_showCctv,
                    onTap: () => setState(() => _showCctv = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    title: 'Live CCTV',
                    icon: Icons.videocam_rounded,
                    isActive: _showCctv,
                    onTap: () => setState(() => _showCctv = true),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          if (_showCctv)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: context.ewsColors.bgCard,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_cameras.length, (index) {
                    final isSelected = _selectedCameraIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _switchCamera(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? context.ewsColors.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? context.ewsColors.accent : context.ewsColors.glassBorder,
                            ),
                          ),
                          child: Text(
                            _cameras[index]['name']!,
                            style: context.caption.copyWith(
                              color: isSelected ? Colors.white : context.ewsColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusM - 1),
              bottomRight: Radius.circular(AppTheme.radiusM - 1),
            ),
            child: _showCctv
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: _ytController,
                    ),
                  )
                : hasImage
                    ? CachedNetworkImage(
                        imageUrl: widget.status.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: context.ewsColors.bgCard,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: context.ewsColors.bgCard,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded, color: context.ewsColors.textMuted, size: 40),
                              const SizedBox(height: 8),
                              Text('Gagal memuat gambar', style: context.bodyMedium),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: context.ewsColors.bgCard,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility_off_rounded, color: context.ewsColors.textMuted, size: 40),
                            const SizedBox(height: 8),
                            Text('Tidak ada foto pengamatan', style: context.bodyMedium),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? context.ewsColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? context.ewsColors.accent : context.ewsColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? context.ewsColors.accent : context.ewsColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: context.bodyMedium.copyWith(
                color: isActive ? context.ewsColors.accent : context.ewsColors.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
