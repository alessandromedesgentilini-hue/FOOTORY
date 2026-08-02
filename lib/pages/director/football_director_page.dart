import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/director_career.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';
import 'package:footory26/services/world/catalog/football_director_portrait_catalog.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/world/catalog/south_america/south_america_club_catalog.dart';

class FootballDirectorPage extends ConsumerWidget {
  const FootballDirectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final director = gameState.footballDirector;
    final career = gameState.directorCareer;

    if (director == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Diretor de Futebol'),
        ),
        body: const Center(
          child: Text('Diretor de Futebol não encontrado.'),
        ),
      );
    }

    final portrait = FootballDirectorPortraitCatalog.byId(
      director.portraitId,
    );

    final brazilFavoriteClub = BrazilClubCatalog.byId(
      director.favoriteClubId,
    );

    final southAmericaFavoriteClub = SouthAmericaClubCatalog.byId(
      director.favoriteClubId,
    );

    final favoriteClubName = brazilFavoriteClub?.name ??
        southAmericaFavoriteClub?.name ??
        'Não definido';

    final tacticalIdentity = CoachTacticalCatalog.fromId(
      director.favoriteTacticalIdentityId,
    );

    final portraitAsset = portrait?.assetPath ?? '';
    final countryName = _countryName(director.countryCode);
    final divisionLabel = _divisionLabel(gameState.divisionId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diretor de Futebol'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            _DirectorProfileCard(
              portraitAsset: portraitAsset,
              directorName: director.name,
              directorAge: director.age,
              countryName: countryName,
              currentClubName: gameState.userClubName,
              currentDivisionLabel: divisionLabel,
              currentSeasonYear: gameState.seasonYear,
            ),
            const SizedBox(height: 16),
            _DirectorIdentityCard(
              favoriteClubName: favoriteClubName,
              tacticalIdentityName: tacticalIdentity.name,
              preferredFormation: _formatFormation(
                tacticalIdentity.mainFormation,
              ),
            ),
            const SizedBox(height: 16),
            if (career != null) ...[
              _CareerSummaryCard(career: career),
              const SizedBox(height: 16),
              _SeasonHistoryCard(career: career),
              const SizedBox(height: 16),
              _ClubSpellsCard(career: career),
              const SizedBox(height: 16),
              _TrophiesCard(trophies: career.trophies),
            ] else
              const _EmptyCareerCard(),
          ],
        ),
      ),
    );
  }
}

class _DirectorProfileCard extends StatelessWidget {
  final String portraitAsset;
  final String directorName;
  final int directorAge;
  final String countryName;
  final String currentClubName;
  final String currentDivisionLabel;
  final int currentSeasonYear;

  const _DirectorProfileCard({
    required this.portraitAsset,
    required this.directorName,
    required this.directorAge,
    required this.countryName,
    required this.currentClubName,
    required this.currentDivisionLabel,
    required this.currentSeasonYear,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DirectorPortrait(
                assetPath: portraitAsset,
                size: 104,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      directorName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Diretor de Futebol',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileTextLine(
                      icon: Icons.cake_outlined,
                      text: '$directorAge anos',
                    ),
                    const SizedBox(height: 7),
                    _ProfileTextLine(
                      icon: Icons.public_rounded,
                      text: countryName,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.white.withOpacity(0.14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _CurrentJobInfo(
                    icon: Icons.shield_rounded,
                    label: 'Clube atual',
                    value: currentClubName.trim().isEmpty
                        ? 'Não definido'
                        : currentClubName,
                  ),
                ),
                _VerticalDivider(
                  color: AppColors.white.withOpacity(0.22),
                ),
                Expanded(
                  child: _CurrentJobInfo(
                    icon: Icons.emoji_events_outlined,
                    label: 'Divisão',
                    value: currentDivisionLabel,
                  ),
                ),
                _VerticalDivider(
                  color: AppColors.white.withOpacity(0.22),
                ),
                Expanded(
                  child: _CurrentJobInfo(
                    icon: Icons.calendar_month_rounded,
                    label: 'Temporada',
                    value: '$currentSeasonYear',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileTextLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.white,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.94),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _CurrentJobInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CurrentJobInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.white,
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.white.withOpacity(0.72),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: color,
    );
  }
}

class _DirectorIdentityCard extends StatelessWidget {
  final String favoriteClubName;
  final String tacticalIdentityName;
  final String preferredFormation;

  const _DirectorIdentityCard({
    required this.favoriteClubName,
    required this.tacticalIdentityName,
    required this.preferredFormation,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Identidade profissional',
      icon: Icons.badge_rounded,
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.favorite_rounded,
            label: 'Clube do coração',
            value: favoriteClubName,
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.account_tree_rounded,
            label: 'Escola tática preferida',
            value: tacticalIdentityName,
          ),
          const SizedBox(height: 14),
          _InformationRow(
            icon: Icons.sports_soccer_rounded,
            label: 'Formação de referência',
            value: preferredFormation,
          ),
        ],
      ),
    );
  }
}

class _CareerSummaryCard extends StatelessWidget {
  final DirectorCareer career;

  const _CareerSummaryCard({
    required this.career,
  });

  @override
  Widget build(BuildContext context) {
    final performance = career.overallPerformancePercentage.clamp(
      0.0,
      100.0,
    );

    return _SectionSurface(
      title: 'Resumo da carreira',
      icon: Icons.query_stats_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;

              final itemWidth = ((constraints.maxWidth - spacing) / 2).clamp(
                120.0,
                260.0,
              );

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _CareerStatBox(
                    width: itemWidth,
                    label: 'Jogos',
                    value: '${career.totalMatches}',
                    icon: Icons.sports_soccer_rounded,
                  ),
                  _CareerStatBox(
                    width: itemWidth,
                    label: 'Vitórias',
                    value: '${career.totalWins}',
                    icon: Icons.trending_up_rounded,
                  ),
                  _CareerStatBox(
                    width: itemWidth,
                    label: 'Empates',
                    value: '${career.totalDraws}',
                    icon: Icons.remove_rounded,
                  ),
                  _CareerStatBox(
                    width: itemWidth,
                    label: 'Derrotas',
                    value: '${career.totalLosses}',
                    icon: Icons.trending_down_rounded,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _PerformanceIndicator(
            label: 'Aproveitamento geral',
            percentage: performance,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CompactCareerInfo(
                  label: 'Temporadas',
                  value: '${career.totalCareerSeasons}',
                  icon: Icons.history_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactCareerInfo(
                  label: 'Títulos',
                  value: '${career.trophies.length}',
                  icon: Icons.emoji_events_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareerStatBox extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;

  const _CareerStatBox({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.17),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceIndicator extends StatelessWidget {
  final String label;
  final double percentage;

  const _PerformanceIndicator({
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final safePercentage = percentage.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${safePercentage.toStringAsFixed(1)}%',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safePercentage / 100,
            minHeight: 9,
            backgroundColor: AppColors.border.withOpacity(0.35),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactCareerInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _CompactCareerInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonHistoryCard extends StatelessWidget {
  final DirectorCareer career;

  const _SeasonHistoryCard({
    required this.career,
  });

  @override
  Widget build(BuildContext context) {
    final seasons = <DirectorSeasonStats>[
      ...career.seasonHistory,
      career.activeSeason,
    ]..sort(
        (a, b) => b.seasonYear.compareTo(a.seasonYear),
      );

    return _SectionSurface(
      title: 'Histórico por temporada',
      icon: Icons.calendar_view_day_rounded,
      child: Column(
        children: [
          for (int index = 0; index < seasons.length; index++) ...[
            _SeasonHistoryItem(
              season: seasons[index],
              isActive:
                  seasons[index].seasonYear == career.activeSeason.seasonYear &&
                      seasons[index].clubId == career.activeSeason.clubId,
            ),
            if (index < seasons.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SeasonHistoryItem extends StatelessWidget {
  final DirectorSeasonStats season;
  final bool isActive;

  const _SeasonHistoryItem({
    required this.season,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    final performance = season.performancePercentage.clamp(
      0.0,
      100.0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isActive ? AppColors.primary.withOpacity(0.24) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${season.seasonYear}',
                style: textTheme.titleMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Atual',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${performance.toStringAsFixed(1)}%',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            season.clubName.trim().isEmpty
                ? 'Clube não informado'
                : season.clubName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallStatistic(
                label: 'J',
                value: season.matches,
              ),
              _SmallStatistic(
                label: 'V',
                value: season.wins,
              ),
              _SmallStatistic(
                label: 'E',
                value: season.draws,
              ),
              _SmallStatistic(
                label: 'D',
                value: season.losses,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStatistic extends StatelessWidget {
  final String label;
  final int value;

  const _SmallStatistic({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 54,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        '$label  $value',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _ClubSpellsCard extends StatelessWidget {
  final DirectorCareer career;

  const _ClubSpellsCard({
    required this.career,
  });

  @override
  Widget build(BuildContext context) {
    if (career.clubSpells.isEmpty) {
      return _SectionSurface(
        title: 'Passagens por clubes',
        icon: Icons.business_rounded,
        child: Text(
          'A passagem atual ainda está começando.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    final spells = List<DirectorClubSpell>.from(
      career.clubSpells,
    )..sort(
        (a, b) => b.startYear.compareTo(a.startYear),
      );

    return _SectionSurface(
      title: 'Passagens por clubes',
      icon: Icons.business_rounded,
      child: Column(
        children: [
          for (int index = 0; index < spells.length; index++) ...[
            _ClubSpellItem(
              spell: spells[index],
              stats: career.statsForClubSpell(
                spells[index],
              ),
            ),
            if (index < spells.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ClubSpellItem extends StatelessWidget {
  final DirectorClubSpell spell;
  final DirectorCareerStats stats;

  const _ClubSpellItem({
    required this.spell,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  spell.clubName.trim().isEmpty ? spell.clubId : spell.clubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (spell.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Atual',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            spell.periodLabel,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${stats.matches} J • '
            '${stats.wins} V • '
            '${stats.draws} E • '
            '${stats.losses} D • '
            '${stats.performancePercentage.toStringAsFixed(1)}%',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophiesCard extends StatelessWidget {
  final List<DirectorTrophy> trophies;

  const _TrophiesCard({
    required this.trophies,
  });

  @override
  Widget build(BuildContext context) {
    if (trophies.isEmpty) {
      return _SectionSurface(
        title: 'Títulos conquistados',
        icon: Icons.emoji_events_rounded,
        child: Text(
          'Nenhum título conquistado até o momento.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    final orderedTrophies = List<DirectorTrophy>.from(
      trophies,
    )..sort(
        (a, b) => b.seasonYear.compareTo(a.seasonYear),
      );

    return _SectionSurface(
      title: 'Títulos conquistados',
      icon: Icons.emoji_events_rounded,
      child: Column(
        children: [
          for (int index = 0; index < orderedTrophies.length; index++) ...[
            _TrophyItem(
              trophy: orderedTrophies[index],
            ),
            if (index < orderedTrophies.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _TrophyItem extends StatelessWidget {
  final DirectorTrophy trophy;

  const _TrophyItem({
    required this.trophy,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trophy.competitionName.trim().isEmpty
                      ? trophy.competitionId
                      : trophy.competitionName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trophy.clubName} • ${trophy.seasonYear}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionSurface extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionSurface({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DirectorPortrait extends StatelessWidget {
  final String assetPath;
  final double size;

  const _DirectorPortrait({
    required this.assetPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.white.withOpacity(0.28),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: assetPath.trim().isEmpty
            ? const _DirectorPortraitFallback()
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const _DirectorPortraitFallback();
                },
              ),
      ),
    );
  }
}

class _DirectorPortraitFallback extends StatelessWidget {
  const _DirectorPortraitFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark.withOpacity(0.45),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.white,
        size: 52,
      ),
    );
  }
}

class _EmptyCareerCard extends StatelessWidget {
  const _EmptyCareerCard();

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Carreira',
      icon: Icons.query_stats_rounded,
      child: Text(
        'As estatísticas serão registradas conforme as partidas oficiais forem disputadas.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
      ),
    );
  }
}

String _countryName(String countryCode) {
  switch (countryCode.trim().toUpperCase()) {
    case 'AR':
      return 'Argentina';
    case 'DE':
      return 'Alemanha';
    case 'SA':
      return 'Arábia Saudita';
    case 'BO':
      return 'Bolívia';
    case 'BR':
      return 'Brasil';
    case 'CM':
      return 'Camarões';
    case 'CL':
      return 'Chile';
    case 'CN':
      return 'China';
    case 'CO':
      return 'Colômbia';
    case 'KR':
      return 'Coreia do Sul';
    case 'CI':
      return 'Costa do Marfim';
    case 'CR':
      return 'Costa Rica';
    case 'EC':
      return 'Equador';
    case 'EG':
      return 'Egito';
    case 'ES':
      return 'Espanha';
    case 'US':
      return 'Estados Unidos';
    case 'FR':
      return 'França';
    case 'GH':
      return 'Gana';
    case 'NL':
      return 'Holanda';
    case 'ENG':
    case 'GB':
      return 'Inglaterra';
    case 'IT':
      return 'Itália';
    case 'JP':
      return 'Japão';
    case 'MX':
      return 'México';
    case 'NG':
      return 'Nigéria';
    case 'NZ':
      return 'Nova Zelândia';
    case 'PY':
      return 'Paraguai';
    case 'PE':
      return 'Peru';
    case 'PT':
      return 'Portugal';
    case 'SN':
      return 'Senegal';
    case 'TR':
      return 'Turquia';
    case 'UY':
      return 'Uruguai';
    case 'VE':
      return 'Venezuela';
    default:
      final normalized = countryCode.trim().toUpperCase();

      return normalized.isEmpty ? 'Não definida' : normalized;
  }
}

String _divisionLabel(String divisionId) {
  switch (divisionId.trim().toLowerCase()) {
    case 'bra':
      return 'Liga BR A';
    case 'brb':
      return 'Liga BR B';
    case 'brc':
      return 'Liga BR C';
    case 'brd':
      return 'Liga BR D';
    default:
      return 'Liga Nacional';
  }
}

String _formatFormation(String formation) {
  switch (formation.trim().toLowerCase()) {
    case '343':
      return '3-4-3';
    case '352':
      return '3-5-2';
    case '433':
      return '4-3-3';
    case '442':
    case '442_flat':
      return '4-4-2';
    case '4141':
      return '4-1-4-1';
    case '4231':
    case '4231_wide':
      return '4-2-3-1';
    case '4312':
      return '4-3-1-2';
    default:
      return formation.trim().isEmpty ? 'Não definida' : formation;
  }
}
