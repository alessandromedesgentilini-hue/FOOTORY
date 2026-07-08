import 'package:flutter/material.dart';

import 'package:footory26/pages/match_live/widgets/club_crest.dart';

class ClubSide extends StatelessWidget {
  final String name;
  final bool alignRight;

  const ClubSide({
    super.key,
    required this.name,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      ClubCrest(name: name),
      const SizedBox(height: 7),
      Text(
        name,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          height: 1.08,
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 8 : 0,
        right: alignRight ? 0 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
