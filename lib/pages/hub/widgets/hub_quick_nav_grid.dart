import 'package:flutter/material.dart';
import 'package:footory26/core/app_colors.dart';

class HubQuickNavGrid extends StatelessWidget {
  final VoidCallback onMyClub;
  final VoidCallback onMarket;
  final VoidCallback onStandings;
  final VoidCallback onMessages;
  final VoidCallback onObservation;

  /// 🔴 NOVO
  final int unreadMessages;

  const HubQuickNavGrid({
    super.key,
    required this.onMyClub,
    required this.onMarket,
    required this.onStandings,
    required this.onMessages,
    required this.onObservation,
    required this.unreadMessages,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool highlight = false,
      bool hasBadge = false,
      int badgeCount = 0,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: highlight
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: highlight
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.border,
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: highlight
                              ? AppColors.primary
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color:
                              highlight ? AppColors.white : AppColors.primary,
                        ),
                      ),

                      /// 🔴 BADGE
                      if (hasBadge && badgeCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            btn(
              icon: Icons.shield_outlined,
              label: 'Meu Clube',
              onTap: onMyClub,
              highlight: true,
            ),
            const SizedBox(width: 10),
            btn(
              icon: Icons.swap_horiz,
              label: 'Mercado',
              onTap: onMarket,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            btn(
              icon: Icons.emoji_events_outlined,
              label: 'Classificação',
              onTap: onStandings,
            ),
            const SizedBox(width: 10),
            btn(
              icon: Icons.mark_email_unread_outlined,
              label: 'Mensagens',
              onTap: onMessages,
              hasBadge: unreadMessages > 0,
              badgeCount: unreadMessages,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            btn(
              icon: Icons.visibility_rounded,
              label: 'Observação',
              onTap: onObservation,
            ),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}
