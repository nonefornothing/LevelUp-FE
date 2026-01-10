import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../routing/app_routes.dart';
import '../../Social/bloc/social_bloc.dart';
import '../../Social/bloc/social_event.dart';
import '../../Social/bloc/social_state.dart';

/// Friends summary card widget for home screen
class FriendsSummaryCard extends StatelessWidget {
  const FriendsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SocialBloc>()..add(const LoadFriends()),
      child: BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state is FriendsLoaded) {
            final friends = state.friends;
            final friendRequests = state.friendRequests.where((r) => r.status.index == 0).length;
            final sharedQuests = state.sharedQuests.where((q) => !q.isAccepted).length;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => context.go(AppRoutes.friends),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.lightBlueAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Friends',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (friendRequests > 0 || sharedQuests > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${friendRequests + sharedQuests}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (friends.isEmpty)
                        const Text(
                          'No friends yet. Add friends to compare progress!',
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${friends.length} ${friends.length == 1 ? 'friend' : 'friends'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (friends.isNotEmpty)
                              Row(
                                children: [
                                  ...friends.take(3).map((friend) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blue[300],
                                        child: Text(
                                          friend.username[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  if (friends.length > 3)
                                    Text(
                                      '+${friends.length - 3}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            if (friendRequests > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_add,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$friendRequests pending request${friendRequests == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (sharedQuests > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.share,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$sharedQuests shared quest${sharedQuests == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.friends),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Colors.lightBlueAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is SocialError) {
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading friends: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}

