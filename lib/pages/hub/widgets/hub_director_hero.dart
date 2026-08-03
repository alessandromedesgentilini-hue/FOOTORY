import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/director_career.dart';
import 'package:footory26/models/football_director.dart';
import 'package:footory26/services/world/catalog/football_director_portrait_catalog.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class HubDirectorHero extends StatelessWidget {
  final FootballDirector director;
  final DirectorCareer? career;
  final String clubId;
  final String clubName;
  final String divisionId;
  final String dateStr;
  final int seasonYear;

  const HubDirectorHero({
    super.key,
    required this.director,
    required this.career,
    required this.clubId,
    required this.clubName,
    required this.divisionId,
    required this.dateStr,
    required this.seasonYear,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final portrait = FootballDirectorPortraitCatalog.byId(
      director.portraitId,
    );

    final portraitAsset =
        portrait?.assetPath ?? 'assets/faces/_placeholder.png';

    final club = BrazilClubCatalog.byId(clubId);
    final badgeAsset = club?.badgeAsset ?? 'assets/faces/_placeholder.png';

    final safeDirectorName = director.name.trim().isEmpty
        ? 'Diretor de Futebol'
        : director.name.trim();

    final safeClubName =
        clubName.trim().isEmpty ? 'Clube atual' : clubName.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DirectorPortrait(
                assetPath: portraitAsset,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DirectorIdentity(
                  name: safeDirectorName,
                  age: director.age,
                  careerLabel: _careerStatsLabel(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 82,
                color: AppColors.white.withOpacity(0.18),
              ),
              const SizedBox(width: 10),
              _ClubIdentity(
                badgeAsset: badgeAsset,
                clubName: safeClubName,
                divisionLabel: _divisionLabel(divisionId),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.white.withOpacity(0.12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BottomInfo(
                    icon: Icons.emoji_events_rounded,
                    label: _divisionLabel(divisionId),
                  ),
                ),
                _BottomDivider(),
                Expanded(
                  child: _BottomInfo(
                    icon: Icons.calendar_month_rounded,
                    label: dateStr.trim().isEmpty
                        ? 'Temporada $seasonYear'
                        : dateStr.trim(),
                  ),
                ),
                _BottomDivider(),
                Expanded(
                  child: _BottomInfo(
                    icon: Icons.flag_rounded,
                    label: 'Temporada $seasonYear',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _careerStatsLabel() {
    final currentCareer = career;

    if (currentCareer == null || currentCareer.totalMatches <= 0) {
      return 'Início da trajetória';
    }

    return '${currentCareer.totalMatches} jogos • '
        '${currentCareer.totalWins}V '
        '${currentCareer.totalDraws}E '
        '${currentCareer.totalLosses}D';
  }

  String _divisionLabel(String divisionId) {
    switch (divisionId.trim().toLowerCase()) {
      case 'bra':
      case 'br-a':
        return 'Série A';

      case 'brb':
      case 'br-b':
        return 'Série B';

      case 'brc':
      case 'br-c':
        return 'Série C';

      case 'brd':
      case 'br-d':
        return 'Série D';

      default:
        final value = divisionId.trim();
        return value.isEmpty ? 'Liga nacional' : value;
    }
  }
}

class _DirectorPortrait extends StatelessWidget {
  final String assetPath;

  const _DirectorPortrait({
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 88,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withOpacity(0.22),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) {
            return Container(
              color: AppColors.white.withOpacity(0.10),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DirectorIdentity extends StatelessWidget {
  final String name;
  final int age;
  final String careerLabel;

  const _DirectorIdentity({
    required this.name,
    required this.age,
    required this.careerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Diretor de Futebol',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.white.withOpacity(0.94),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$age anos',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.white.withOpacity(0.76),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.timeline_rounded,
              size: 14,
              color: AppColors.white.withOpacity(0.76),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                careerLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.white.withOpacity(0.82),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClubIdentity extends StatelessWidget {
  final String badgeAsset;
  final String clubName;
  final String divisionLabel;

  const _ClubIdentity({
    required this.badgeAsset,
    required this.clubName,
    required this.divisionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withOpacity(0.28),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                badgeAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.shield_rounded,
                    color: AppColors.primary,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            clubName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            divisionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.white.withOpacity(0.72),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.white.withOpacity(0.84),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white.withOpacity(0.92),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _BottomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: AppColors.white.withOpacity(0.16),
    );
  }
}
