import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/fixture.dart';
import 'package:footory26/pages/hub/widgets/hub_shared.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class HubNextMatchBlock extends StatelessWidget {
  final GameState gs;
  final Fixture fx;

  const HubNextMatchBlock({
    super.key,
    required this.gs,
    required this.fx,
  });

  @override
  Widget build(BuildContext context) {
    final isUserHome = fx.homeClubId == gs.userClubId;
    final userSide = isUserHome ? 'Mandante' : 'Visitante';

    final homeName = gs.clubName(fx.homeClubId);
    final awayName = gs.clubName(fx.awayClubId);

    final homeClub = BrazilClubCatalog.byId(fx.homeClubId);
    final awayClub = BrazilClubCatalog.byId(fx.awayClubId);

    final homeBadge = homeClub?.badgeAsset ?? 'assets/faces/_placeholder.png';

    final awayBadge = awayClub?.badgeAsset ?? 'assets/faces/_placeholder.png';

    final userSnap = snapFromPower10(gs.clubPower10(gs.userClubId));
    final oppId = isUserHome ? fx.awayClubId : fx.homeClubId;
    final oppSnap = snapFromPower10(gs.clubBasePower(oppId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MatchVersusCard(
          homeName: homeName,
          awayName: awayName,
          homeBadge: homeBadge,
          awayBadge: awayBadge,
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _SidePill(text: userSide),
        ),
        const SizedBox(height: 14),
        _PowerInfoCard(
          label: 'Sua Força',
          stars5: userSnap.stars5,
          value: userSnap.label10,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 10),
        _PowerInfoCard(
          label: 'Adversário',
          stars5: oppSnap.stars5,
          value: oppSnap.label10,
          icon: Icons.sports_soccer_rounded,
        ),
      ],
    );
  }
}

class _MatchVersusCard extends StatelessWidget {
  final String homeName;
  final String awayName;
  final String homeBadge;
  final String awayBadge;

  const _MatchVersusCard({
    required this.homeName,
    required this.awayName,
    required this.homeBadge,
    required this.awayBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _ClubFace(
              badgePath: homeBadge,
              clubName: homeName,
              alignEnd: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'vs',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: _ClubFace(
              badgePath: awayBadge,
              clubName: awayName,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubFace extends StatelessWidget {
  final String badgePath;
  final String clubName;
  final bool alignEnd;

  const _ClubFace({
    required this.badgePath,
    required this.clubName,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!alignEnd) ...[
          _Crest(assetPath: badgePath),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            clubName,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              height: 1.1,
            ),
          ),
        ),
        if (alignEnd) ...[
          const SizedBox(width: 10),
          _Crest(assetPath: badgePath),
        ],
      ],
    );
  }
}

class _Crest extends StatelessWidget {
  final String assetPath;

  const _Crest({
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.shield_outlined,
            color: AppColors.textMuted,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _SidePill extends StatelessWidget {
  final String text;

  const _SidePill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.accentDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PowerInfoCard extends StatelessWidget {
  final String label;
  final int stars5;
  final String value;
  final IconData icon;

  const _PowerInfoCard({
    required this.label,
    required this.stars5,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          HubStars5(filled: stars5, size: 18),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
