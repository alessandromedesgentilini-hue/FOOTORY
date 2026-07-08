import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/providers.dart';
import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/pages/match_live/models/live_stats.dart';
import 'package:footory26/pages/match_live/widgets/animated_match_event_card.dart';
import 'package:footory26/pages/match_live/widgets/broadcast_header.dart';
import 'package:footory26/pages/match_live/widgets/goal_hero_card.dart';
import 'package:footory26/pages/match_live/widgets/match_control_panel.dart';
import 'package:footory26/pages/match_live/widgets/waiting_match.dart';

class MatchLivePage extends ConsumerStatefulWidget {
  const MatchLivePage({super.key});

  @override
  ConsumerState<MatchLivePage> createState() => _MatchLivePageState();
}

class _MatchLivePageState extends ConsumerState<MatchLivePage> {
  final List<MatchLiveEvent> _visibleEvents = <MatchLiveEvent>[];

  Timer? _timer;
  Timer? _goalHeroTimer;

  int _currentIndex = 0;
  int _minute = 0;

  int _homeGoals = 0;
  int _awayGoals = 0;

  bool _finished = false;
  bool _started = false;
  bool _scorePulse = false;
  bool _goalHeroVisible = false;

  MatchLiveEvent? _activeGoalHero;

  String _homeClubName = '';
  String _awayClubName = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSimulation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _goalHeroTimer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    if (_started) return;
    _started = true;

    final gs = ref.read(gameStateProvider);

    gs.simulateRound();

    final events = gs.lastUserMatchLiveEvents;

    _homeClubName = _safeClubName(
      gs.lastUserMatchHomeClubName,
      fallback: 'Casa',
    );
    _awayClubName = _safeClubName(
      gs.lastUserMatchAwayClubName,
      fallback: 'Visitante',
    );

    if (events.isEmpty) {
      setState(() {
        _finished = true;
        _minute = 90;
      });
      return;
    }

    _timer = Timer.periodic(
      const Duration(milliseconds: 1900),
      (timer) {
        if (!mounted) return;

        if (_currentIndex >= events.length) {
          timer.cancel();

          setState(() {
            _finished = true;
            _minute = 90;
            _goalHeroVisible = false;
            _activeGoalHero = null;
          });

          return;
        }

        final event = events[_currentIndex];

        final isScoreEvent = event.type == MatchLiveEventType.goal ||
            event.type == MatchLiveEventType.halfTime ||
            event.type == MatchLiveEventType.finalWhistle;

        if (event.type == MatchLiveEventType.goal) {
          HapticFeedback.mediumImpact();
          _triggerScorePulse();
          _showGoalHero(event);
        } else if (event.type == MatchLiveEventType.bigChance) {
          HapticFeedback.lightImpact();
        }

        setState(() {
          _visibleEvents.insert(0, event);
          _minute = event.minute;

          if (isScoreEvent) {
            _homeGoals = event.homeGoals;
            _awayGoals = event.awayGoals;
          }

          _currentIndex++;
        });
      },
    );
  }

  String _safeClubName(String? value, {required String fallback}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return fallback;
    return text;
  }

  void _triggerScorePulse() {
    setState(() {
      _scorePulse = true;
    });

    Future.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;

      setState(() {
        _scorePulse = false;
      });
    });
  }

  void _showGoalHero(MatchLiveEvent event) {
    _goalHeroTimer?.cancel();

    setState(() {
      _activeGoalHero = event;
      _goalHeroVisible = true;
    });

    _goalHeroTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;

      setState(() {
        _goalHeroVisible = false;
      });
    });
  }

  void _skipMatch() {
    final gs = ref.read(gameStateProvider);
    final events = gs.lastUserMatchLiveEvents;

    _timer?.cancel();
    _goalHeroTimer?.cancel();

    int finalHomeGoals = 0;
    int finalAwayGoals = 0;

    if (events.isNotEmpty) {
      final last = events.last;
      finalHomeGoals = last.homeGoals;
      finalAwayGoals = last.awayGoals;
    }

    setState(() {
      _visibleEvents
        ..clear()
        ..addAll(events.reversed);

      _currentIndex = events.length;
      _minute = 90;
      _homeGoals = finalHomeGoals;
      _awayGoals = finalAwayGoals;
      _finished = true;
      _goalHeroVisible = false;
      _activeGoalHero = null;
    });
  }

  LiveStats get _stats => LiveStats.fromEvents(
        events: _visibleEvents,
        homeGoals: _homeGoals,
        awayGoals: _awayGoals,
      );

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return Scaffold(
      backgroundColor: const Color(0xFF06100B),
      appBar: AppBar(
        title: const Text('Transmissão Footory'),
        centerTitle: true,
        backgroundColor: const Color(0xFF06100B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          BroadcastHeader(
            minute: _minute,
            finished: _finished,
            homeClubName: _homeClubName,
            awayClubName: _awayClubName,
            homeGoals: _homeGoals,
            awayGoals: _awayGoals,
            pulse: _scorePulse,
          ),
          MatchControlPanel(
            minute: _minute,
            stats: stats,
            homeClubName: _homeClubName,
            awayClubName: _awayClubName,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: !_goalHeroVisible || _activeGoalHero == null
                ? const SizedBox.shrink()
                : Padding(
                    key: ValueKey(
                      '${_activeGoalHero!.minute}-${_activeGoalHero!.homeGoals}-${_activeGoalHero!.awayGoals}-${_activeGoalHero!.text}',
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                    child: GoalHeroCard(
                      event: _activeGoalHero!,
                    ),
                  ),
          ),
          Expanded(
            child: _visibleEvents.isEmpty
                ? const WaitingMatch()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    itemCount: _visibleEvents.length,
                    itemBuilder: (_, index) {
                      final event = _visibleEvents[index];

                      return AnimatedMatchEventCard(
                        key: ValueKey(
                          '${event.minute}-${event.homeGoals}-${event.awayGoals}-${event.text}-$index',
                        ),
                        event: event,
                        index: index,
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: const Color(0xFF06110B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_finished) {
                      Navigator.pop(context);
                    } else {
                      _skipMatch();
                    }
                  },
                  icon: Icon(
                    _finished
                        ? Icons.arrow_forward_rounded
                        : Icons.fast_forward_rounded,
                  ),
                  label: Text(
                    _finished ? 'Avançar' : 'Pular para o final',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
