import 'package:footory26/services/club_status/club_status_runtime.dart';
import 'package:footory26/services/narrative/season_narrative_context.dart';

enum SeasonEmotion {
  legendary,
  historic,
  excellent,
  positive,
  acceptable,
  survival,
  painful,
  frustrating,
  critical,
}

enum SupporterMood {
  euphoric,
  proud,
  satisfied,
  relieved,
  hopeful,
  demanding,
  angry,
}

enum BoardMood {
  thrilled,
  satisfied,
  acceptable,
  alert,
  disappointed,
  crisis,
}

enum PressMood {
  amazed,
  impressed,
  positive,
  neutral,
  questioning,
  critical,
  crisis,
}

class SeasonNarrativeAnalysis {
  final SeasonEmotion seasonEmotion;

  final SupporterMood supporterMood;
  final BoardMood boardMood;
  final PressMood pressMood;

  final String checkpointTag;

  final bool stronglyAboveExpectation;
  final bool aboveExpectation;
  final bool onExpectation;
  final bool belowExpectation;
  final bool stronglyBelowExpectation;

  final bool improvedDuringSeason;

  const SeasonNarrativeAnalysis({
    required this.seasonEmotion,
    required this.supporterMood,
    required this.boardMood,
    required this.pressMood,
    required this.checkpointTag,
    required this.stronglyAboveExpectation,
    required this.aboveExpectation,
    required this.onExpectation,
    required this.belowExpectation,
    required this.stronglyBelowExpectation,
    required this.improvedDuringSeason,
  });
}

class SeasonNarrativeAnalyzer {
  const SeasonNarrativeAnalyzer();

  SeasonNarrativeAnalysis analyze(
    SeasonNarrativeContext context,
  ) {
    final delta = context.expectation.delta;

    final stronglyAbove = delta >= 2;
    final above = delta > 0;
    final onTrack = delta == 0;
    final below = delta < 0;
    final stronglyBelow = delta <= -2;

    final improved = context.currentPower10 > context.initialPower10 + 0.25;

    final emotion = _seasonEmotion(
      context: context,
      stronglyAbove: stronglyAbove,
      above: above,
      onTrack: onTrack,
      below: below,
      stronglyBelow: stronglyBelow,
      improved: improved,
    );

    return SeasonNarrativeAnalysis(
      seasonEmotion: emotion,
      supporterMood: _supporterMood(
        context: context,
        emotion: emotion,
      ),
      boardMood: _boardMood(
        context: context,
        emotion: emotion,
      ),
      pressMood: _pressMood(
        context: context,
        emotion: emotion,
      ),
      checkpointTag: _checkpointTag(
        context: context,
        emotion: emotion,
      ),
      stronglyAboveExpectation: stronglyAbove,
      aboveExpectation: above,
      onExpectation: onTrack,
      belowExpectation: below,
      stronglyBelowExpectation: stronglyBelow,
      improvedDuringSeason: improved,
    );
  }

  SeasonEmotion _seasonEmotion({
    required SeasonNarrativeContext context,
    required bool stronglyAbove,
    required bool above,
    required bool onTrack,
    required bool below,
    required bool stronglyBelow,
    required bool improved,
  }) {
    final position = context.finalPosition;
    final tier = context.clubStatus.currentTier;

    final smallClub =
        tier == ClubStatusTier.tiny || tier == ClubStatusTier.small;

    final giantClub =
        tier == ClubStatusTier.big || tier == ClubStatusTier.giant;

    final topQuarter = context.finishedTopQuarter;
    final bottomQuarter = context.finishedBottomQuarter;

    if (position == 1) {
      if (smallClub || stronglyAbove) {
        return SeasonEmotion.legendary;
      }

      return SeasonEmotion.historic;
    }

    if (context.promoted) {
      if (smallClub && stronglyAbove) {
        return SeasonEmotion.historic;
      }

      if (stronglyAbove) {
        return SeasonEmotion.excellent;
      }

      if (onTrack && improved) {
        return SeasonEmotion.positive;
      }

      if (onTrack) {
        return SeasonEmotion.acceptable;
      }

      return SeasonEmotion.positive;
    }

    if (context.relegated) {
      if (giantClub) {
        return SeasonEmotion.critical;
      }

      if (stronglyBelow) {
        return SeasonEmotion.frustrating;
      }

      if (smallClub) {
        return SeasonEmotion.painful;
      }

      return SeasonEmotion.frustrating;
    }

    if (stronglyAbove) {
      if (topQuarter) {
        return SeasonEmotion.excellent;
      }

      return SeasonEmotion.positive;
    }

    if (above) {
      return SeasonEmotion.positive;
    }

    if (onTrack) {
      if (bottomQuarter) {
        return SeasonEmotion.survival;
      }

      if (improved) {
        return SeasonEmotion.positive;
      }

      return SeasonEmotion.acceptable;
    }

    if (stronglyBelow) {
      if (giantClub) {
        return SeasonEmotion.critical;
      }

      return SeasonEmotion.frustrating;
    }

    if (below) {
      if (smallClub && bottomQuarter) {
        return SeasonEmotion.painful;
      }

      return SeasonEmotion.frustrating;
    }

    if (bottomQuarter) {
      return SeasonEmotion.survival;
    }

    return SeasonEmotion.acceptable;
  }

  SupporterMood _supporterMood({
    required SeasonNarrativeContext context,
    required SeasonEmotion emotion,
  }) {
    final tier = context.clubStatus.currentTier;

    switch (emotion) {
      case SeasonEmotion.legendary:
      case SeasonEmotion.historic:
        return SupporterMood.euphoric;

      case SeasonEmotion.excellent:
        return SupporterMood.proud;

      case SeasonEmotion.positive:
        return SupporterMood.satisfied;

      case SeasonEmotion.acceptable:
        if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
          return SupporterMood.demanding;
        }

        return SupporterMood.satisfied;

      case SeasonEmotion.survival:
        return SupporterMood.relieved;

      case SeasonEmotion.painful:
        return SupporterMood.hopeful;

      case SeasonEmotion.frustrating:
        return SupporterMood.demanding;

      case SeasonEmotion.critical:
        return SupporterMood.angry;
    }
  }

  BoardMood _boardMood({
    required SeasonNarrativeContext context,
    required SeasonEmotion emotion,
  }) {
    switch (emotion) {
      case SeasonEmotion.legendary:
      case SeasonEmotion.historic:
        return BoardMood.thrilled;

      case SeasonEmotion.excellent:
      case SeasonEmotion.positive:
        return BoardMood.satisfied;

      case SeasonEmotion.acceptable:
      case SeasonEmotion.survival:
        return BoardMood.acceptable;

      case SeasonEmotion.painful:
        return BoardMood.alert;

      case SeasonEmotion.frustrating:
        return BoardMood.disappointed;

      case SeasonEmotion.critical:
        return BoardMood.crisis;
    }
  }

  PressMood _pressMood({
    required SeasonNarrativeContext context,
    required SeasonEmotion emotion,
  }) {
    switch (emotion) {
      case SeasonEmotion.legendary:
      case SeasonEmotion.historic:
        return PressMood.amazed;

      case SeasonEmotion.excellent:
        return PressMood.impressed;

      case SeasonEmotion.positive:
        return PressMood.positive;

      case SeasonEmotion.acceptable:
      case SeasonEmotion.survival:
        return PressMood.neutral;

      case SeasonEmotion.painful:
        return PressMood.questioning;

      case SeasonEmotion.frustrating:
        return PressMood.critical;

      case SeasonEmotion.critical:
        return PressMood.crisis;
    }
  }

  String _checkpointTag({
    required SeasonNarrativeContext context,
    required SeasonEmotion emotion,
  }) {
    switch (emotion) {
      case SeasonEmotion.legendary:
      case SeasonEmotion.historic:
      case SeasonEmotion.excellent:
        return 'success';

      case SeasonEmotion.positive:
        return 'positive';

      case SeasonEmotion.acceptable:
      case SeasonEmotion.survival:
        return 'neutral';

      case SeasonEmotion.painful:
      case SeasonEmotion.frustrating:
        return 'warning';

      case SeasonEmotion.critical:
        return 'danger';
    }
  }
}
