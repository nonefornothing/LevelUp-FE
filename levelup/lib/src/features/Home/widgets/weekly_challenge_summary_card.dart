import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/weekly_challenge_service.dart';
import '../../../../domain/entities/weekly_challenge.dart';
import '../../../routing/app_routes.dart';

class WeeklyChallengeSummaryCard extends StatelessWidget {
  const WeeklyChallengeSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeeklyChallenge>>(
      future: sl<WeeklyChallengeService>().getActiveWeeklyChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final challenges = snapshot.data!;
        final activeChallenges = challenges
            .where((c) => c.status == WeeklyChallengeStatus.active)
            .toList();
        final completedCount = challenges
            .where((c) => c.status == WeeklyChallengeStatus.completed)
            .length;

        if (activeChallenges.isEmpty && completedCount == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          color: Colors.grey[900],
          child: InkWell(
            onTap: () => context.go(AppRoutes.weeklyChallenges),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.lightBlueAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Weekly Challenges',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$completedCount of ${challenges.length} completed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  if (activeChallenges.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...activeChallenges.take(2).map((challenge) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      challenge.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${challenge.progressPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: challenge.progressPercentage / 100,
                                backgroundColor: Colors.grey[800],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.lightBlueAccent,
                                ),
                                minHeight: 4,
                              ),
                            ],
                          ),
                        )),
                  ],
                  if (activeChallenges.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+${activeChallenges.length - 2} more challenge${activeChallenges.length - 2 > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}




