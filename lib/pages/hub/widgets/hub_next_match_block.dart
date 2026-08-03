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
    final opponentId = isUserHome ? fx.awayClubId : fx.homeClubId;

    final homeName = gs.clubName(fx.homeClubId);
    final awayName = gs.clubName(fx.awayClubId);

    final homeClub = BrazilClubCatalog.byId(fx.homeClubId);
    final awayClub = BrazilClubCatalog.byId(fx.awayClubId);

    final homeBadge = homeClub?.badgeAsset ?? 'assets/faces/_placeholder.png';
    final awayBadge = awayClub?.badgeAsset ?? 'assets/faces/_placeholder.png';

    final userPower = snapFromPower10(
      gs.clubPower10(gs.userClubId),
    );

    final opponentPower = snapFromPower10(
      gs.clubPower10(opponentId),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MatchHeader(
            round: fx.round,
            sideLabel: isUserHome ? 'Mandante' : 'Visitante',
          ),
          const SizedBox(height: 13),
          _MatchVersus(
            homeName: homeName,
            awayName: awayName,
            homeBadge: homeBadge,
            awayBadge: awayBadge,
            userClubId: gs.userClubId,
            homeClubId: fx.homeClubId,
            awayClubId: fx.awayClubId,
          ),
          const SizedBox(height: 13),
          _PowerComparison(
            userPower: userPower,
            opponentPower: opponentPower,
          ),
        ],
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  final int round;
  final String sideLabel;

  const _MatchHeader({
    required this.round,
    required this.sideLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.sports_soccer_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Próximo jogo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Rodada $round',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.accentDark.withOpacity(0.10),
            ),
          ),
          child: Text(
            sideLabel,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.accentDark,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchVersus extends StatelessWidget {
  final String homeName;
  final String awayName;
  final String homeBadge;
  final String awayBadge;
  final String userClubId;
  final String homeClubId;
  final String awayClubId;

  const _MatchVersus({
    required this.homeName,
    required this.awayName,
    required this.homeBadge,
    required this.awayBadge,
    required this.userClubId,
    required this.homeClubId,
    required this.awayClubId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ClubSide(
            clubName: homeName,
            badgePath: homeBadge,
            isUserClub: homeClubId == userClubId,
          ),
        ),
        const SizedBox(width: 8),
        const _VersusMark(),
        const SizedBox(width: 8),
        Expanded(
          child: _ClubSide(
            clubName: awayName,
            badgePath: awayBadge,
            isUserClub: awayClubId == userClubId,
          ),
        ),
      ],
    );
  }
}

class _ClubSide extends StatelessWidget {
  final String clubName;
  final String badgePath;
  final bool isUserClub;

  const _ClubSide({
    required this.clubName,
    required this.badgePath,
    required this.isUserClub,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(7, 9, 7, 8),
      decoration: BoxDecoration(
        color: isUserClub
            ? AppColors.primarySoft.withOpacity(0.52)
            : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUserClub
              ? AppColors.primary.withOpacity(0.18)
              : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ClubCrest(
            assetPath: badgePath,
            highlighted: isUserClub,
          ),
          const SizedBox(height: 7),
          Text(
            clubName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUserClub ? 'Seu clube' : 'Adversário',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color:
                  isUserClub ? AppColors.primaryDark : AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubCrest extends StatelessWidget {
  final String assetPath;
  final bool highlighted;

  const _ClubCrest({
    required this.assetPath,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withOpacity(0.22)
              : AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Center(
              child: Icon(
                Icons.shield_rounded,
                color: AppColors.textMuted,
                size: 29,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VersusMark extends StatelessWidget {
  const _VersusMark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 29),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.14),
          ),
        ),
        child: Text(
          'VS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primaryDark,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _PowerComparison extends StatelessWidget {
  final dynamic userPower;
  final dynamic opponentPower;

  const _PowerComparison({
    required this.userPower,
    required this.opponentPower,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PowerSide(
              label: 'Sua força',
              stars: userPower.stars5,
              value: userPower.label10,
              alignment: CrossAxisAlignment.start,
            ),
          ),
          Container(
            width: 1,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 9),
            color: AppColors.border,
          ),
          Expanded(
            child: _PowerSide(
              label: 'Adversário',
              stars: opponentPower.stars5,
              value: opponentPower.label10,
              alignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerSide extends StatelessWidget {
  final String label;
  final int stars;
  final String value;
  final CrossAxisAlignment alignment;

  const _PowerSide({
    required this.label,
    required this.stars,
    required this.value,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final alignRight = alignment == CrossAxisAlignment.end;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!alignRight) ...[
              HubStars5(
                filled: stars,
                size: 13,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              value,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (alignRight) ...[
              const SizedBox(width: 6),
              HubStars5(
                filled: stars,
                size: 13,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
