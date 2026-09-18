import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/ads_provider.dart';
import '../services/ad_service.dart';
import '../services/ads_config.dart';
import 'remove_ads_screen.dart';

/// A banner slot at the bottom of a screen (ADS-1).
///
/// It goes in the `bottomNavigationBar` of its [Scaffold], not in the body:
/// there it sits outside the scrolling content and above the system
/// navigation bar, the add button lifts above it instead of over it, and it
/// can never cover a list row or the keypad (ADS-3).
///
/// The slot reserves the banner's height before it asks for one, so nothing
/// moves under a finger when the ad arrives, and an empty slot shows nothing
/// at all — no frame, no placeholder (ADS-2). When the ads have been bought
/// away it takes no room whatsoever (ADS-8).
class AdSlot extends StatefulWidget {
  const AdSlot({super.key, required this.placement});

  final AdPlacement placement;

  @override
  State<AdSlot> createState() => _AdSlotState();
}

class _AdSlotState extends State<AdSlot> {
  LoadedBanner? _banner;
  double? _height;
  double? _askedForWidth;

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  /// Reserves the height, then asks for an ad. Called again when the width
  /// changes — a rotation, or a desktop window being dragged.
  Future<void> _fill(double width) async {
    if (_askedForWidth == width) return;
    _askedForWidth = width;
    final ads = context.read<AdsProvider>();

    final height = await ads.bannerHeight(width);
    if (!mounted || height == null) return;
    setState(() => _height = height);

    final banner = await ads.loadBanner(widget.placement, width);
    if (!mounted) {
      // The screen went away while the ad was in flight.
      await banner?.dispose();
      return;
    }
    // A rotation mid-flight makes this one the wrong width.
    if (_askedForWidth != width) {
      await banner?.dispose();
      return;
    }
    final old = _banner;
    setState(() => _banner = banner);
    await old?.dispose();
  }

  void _forget() {
    _banner?.dispose();
    _banner = null;
    _height = null;
    _askedForWidth = null;
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdsProvider>();
    if (!ads.showAds) {
      // Bought away, locked, or not yet allowed: no slot, no space (ADS-8).
      if (_banner != null || _height != null) _forget();
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // After this frame, so a load never calls setState during a build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fill(width);
        });

        // A height this run has already looked up is right for the first
        // frame, so only the very first slot of a run grows from nothing.
        final height = _height ?? ads.knownBannerHeight(width);
        if (height == null) return const SizedBox.shrink();

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PAY-7: selling is quiet — one small target here, and one row
              // in Settings. It is above the ad and padded away from it, so
              // nobody reaches for it and taps an ad instead.
              const _RemoveAdsLink(),
              SizedBox(
                height: height,
                width: width,
                // An empty slot is blank: no frame, no "advertisement"
                // label, nothing to look at (ADS-2).
                child: _banner?.view,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RemoveAdsLink extends StatelessWidget {
  const _RemoveAdsLink();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
        child: InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const RemoveAdsScreen())),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              l10n.removeAdsTitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
