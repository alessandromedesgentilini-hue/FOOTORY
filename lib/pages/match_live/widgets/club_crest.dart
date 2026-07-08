import 'package:flutter/material.dart';

import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class ClubCrest extends StatelessWidget {
  final String name;

  const ClubCrest({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final club = _findClubByName(name);
    final badgeAsset = club?.badgeAsset;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF173723),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB7F7CE).withOpacity(0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: badgeAsset == null
          ? _FallbackCrest(name: name)
          : Image.asset(
              badgeAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) {
                return _FallbackCrest(name: name);
              },
            ),
    );
  }

  ClubEntry? _findClubByName(String value) {
    final clean = value.trim();

    if (clean.isEmpty) return null;

    for (final club in BrazilClubCatalog.all()) {
      if (club.name == clean) return club;
    }

    final cleanSlug = BrazilClubCatalog.slug(clean);

    for (final club in BrazilClubCatalog.all()) {
      if (BrazilClubCatalog.slug(club.name) == cleanSlug) {
        return club;
      }
    }

    return null;
  }
}

class _FallbackCrest extends StatelessWidget {
  final String name;

  const _FallbackCrest({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);

    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1810),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2ECC71).withOpacity(0.7),
        ),
      ),
      child: Text(
        initials,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF2ECC71),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _initials(String value) {
    final clean = value.trim();

    if (clean.isEmpty) return 'FC';

    final parts = clean
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim())
        .toList();

    if (parts.length == 1) {
      final word = parts.first;

      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
