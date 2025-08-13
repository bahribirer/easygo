import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String location;
  final ImageProvider photo;
  final VoidCallback onTapSettings;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.location,
    required this.photo,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final screenH = mq.size.height;

    final expandedH = (screenH * 0.28).clamp(220.0, 300.0);
    const minAvatar = 36.0;
    const maxAvatar = 64.0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedH,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (ctx, c) {
          final currentH = c.constrainHeight();
          final t = ((currentH - kToolbarHeight) / (expandedH - kToolbarHeight))
              .clamp(0.0, 1.0);

          final avatarSize = minAvatar + (maxAvatar - minAvatar) * t;
          final bottomPadding = 16.0 * t;
          final titleSize = 18.0 + 6.0 * t;

          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFEB692), Color(0xFFEA5455)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Opacity(opacity: 0.08, child: Container(color: Colors.white)),
              Positioned(
                top: topPad + 6,
                right: 6,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: onTapSettings,
                  tooltip: 'Ayarlar',
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: bottomPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(radius: avatarSize / 2, backgroundImage: photo),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: titleSize,
                              shadows: const [
                                Shadow(color: Colors.black26, blurRadius: 8)
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$location, Türkiye',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
