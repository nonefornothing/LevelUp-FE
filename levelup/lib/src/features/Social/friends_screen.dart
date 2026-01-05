import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import 'bloc/social_bloc.dart';
import 'bloc/social_event.dart';
import 'bloc/social_state.dart';

/// Friends screen displaying friend list, requests, and shared quests
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SocialBloc>()..add(const LoadFriends()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SocialBloc>().add(const RefreshFriends());
              },
            ),
          ],
        ),
        body: BlocBuilder<SocialBloc, SocialState>(
          builder: (context, state) {
            if (state is SocialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SocialError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.red[300]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SocialBloc>().add(const LoadFriends());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is FriendsLoaded) {
              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Friends', icon: Icon(Icons.people)),
                        Tab(text: 'Requests', icon: Icon(Icons.person_add)),
                        Tab(text: 'Shared', icon: Icon(Icons.share)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _FriendsListTab(
                            friends: state.friends,
                            onCompareProgress: _showProgressComparison,
                          ),
                          _FriendRequestsTab(requests: state.friendRequests),
                          _SharedQuestsTab(sharedQuests: state.sharedQuests),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No data'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddFriendDialog(context),
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Enter username',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              if (username.isNotEmpty) {
                context.read<SocialBloc>().add(AddFriend(username));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showProgressComparison(BuildContext context, dynamic friend) {
    context.read<SocialBloc>().add(CompareProgressWithFriend(friend.id));
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state is ProgressComparisonLoaded) {
            final comparison = state.comparison;
            final friendData = comparison['friend'] as Map<String, dynamic>;
            final playerData = comparison['player'] as Map<String, dynamic>?;

            return AlertDialog(
              title: Text('Compare with ${friend.username}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComparisonRow(
                      'Level',
                      playerData?['level']?.toString() ?? 'N/A',
                      friendData['level'].toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonRow(
                      'Quests Completed',
                      playerData?['totalQuestsCompleted']?.toString() ?? 'N/A',
                      friendData['totalQuestsCompleted'].toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonRow(
                      'Current Streak',
                      playerData?['currentStreak']?.toString() ?? 'N/A',
                      friendData['currentStreak'].toString(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonRow(String label, String playerValue, String friendValue) {
    final playerInt = int.tryParse(playerValue) ?? 0;
    final friendInt = int.tryParse(friendValue) ?? 0;
    final isPlayerHigher = playerInt > friendInt;
    final isEqual = playerInt == friendInt;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'You: $playerValue',
                style: TextStyle(
                  color: isPlayerHigher && !isEqual ? Colors.green : Colors.black,
                  fontWeight: isPlayerHigher && !isEqual ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                'Friend: $friendValue',
                style: TextStyle(
                  color: !isPlayerHigher && !isEqual ? Colors.green : Colors.black,
                  fontWeight: !isPlayerHigher && !isEqual ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (isEqual)
          const Icon(Icons.remove, color: Colors.grey)
        else if (isPlayerHigher)
          const Icon(Icons.arrow_upward, color: Colors.green)
        else
          const Icon(Icons.arrow_downward, color: Colors.orange),
      ],
    );
  }
}

/// Friends list tab
class _FriendsListTab extends StatelessWidget {
  final List<dynamic> friends;
  final Function(BuildContext, dynamic) onCompareProgress;

  const _FriendsListTab({
    required this.friends,
    required this.onCompareProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to compare progress and share quests',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[300],
              child: Text(
                friend.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(friend.username),
            subtitle: Text('Level ${friend.level} • ${friend.totalQuestsCompleted} quests'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.compare_arrows),
                  onPressed: () => onCompareProgress(context, friend),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    context.read<SocialBloc>().add(RemoveFriend(friend.id));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Friend requests tab
class _FriendRequestsTab extends StatelessWidget {
  final List<dynamic> requests;

  const _FriendRequestsTab({required this.requests});

  @override
  Widget build(BuildContext context) {
    final pendingRequests = requests.where((r) => r.status.index == 0).toList();

    if (pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[300],
              child: Text(
                request.fromUsername[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(request.fromUsername),
            subtitle: Text('Sent ${_formatDate(request.sentAt)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    context.read<SocialBloc>().add(AcceptFriendRequest(request.id));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    context.read<SocialBloc>().add(RejectFriendRequest(request.id));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

/// Shared quests tab
class _SharedQuestsTab extends StatelessWidget {
  final List<dynamic> sharedQuests;

  const _SharedQuestsTab({required this.sharedQuests});

  @override
  Widget build(BuildContext context) {
    final unacceptedQuests = sharedQuests.where((q) => !q.isAccepted).toList();

    if (unacceptedQuests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No shared quests',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: unacceptedQuests.length,
      itemBuilder: (context, index) {
        final sharedQuest = unacceptedQuests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.assignment, color: Colors.blue),
            title: Text(sharedQuest.questTitle),
            subtitle: Text('From ${sharedQuest.fromUsername}'),
            trailing: ElevatedButton(
              onPressed: () {
                context.read<SocialBloc>().add(AcceptSharedQuest(sharedQuest.id));
              },
              child: const Text('Accept'),
            ),
          ),
        );
      },
    );
  }
}

