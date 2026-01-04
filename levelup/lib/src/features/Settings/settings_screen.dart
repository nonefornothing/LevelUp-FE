import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../routing/app_routes.dart';
import '../Authentication/bloc/auth_bloc.dart';
import '../Authentication/bloc/auth_event.dart';
import '../Player/bloc/player_bloc.dart';
import '../Player/bloc/player_event.dart';
import '../Player/bloc/player_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerBloc(
        playerRepository: sl<PlayerRepository>(),
      )..add(const PlayerLoadRequested()),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.lightBlueAccent),
          ),
        ),
        body: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final player = state is PlayerLoaded ? state.player : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Settings Section
                  Card(
                    color: Colors.grey[900],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Profile Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (player != null) ...[
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.lightBlueAccent,
                            ),
                            title: const Text(
                              'View Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              player.username,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                            onTap: () => context.go(AppRoutes.profile),
                          ),
                          const Divider(color: Colors.grey),
                        ],
                        ListTile(
                          leading: const Icon(
                            Icons.edit,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Coming soon',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            // TODO: Implement edit profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit profile coming soon!'),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Preferences Section
                  Card(
                    color: Colors.grey[900],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'App Preferences',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.dark_mode,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Theme',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Dark mode (coming soon)',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Theme settings coming soon!'),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                        const Divider(color: Colors.grey),
                        ListTile(
                          leading: const Icon(
                            Icons.notifications,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Notifications',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            'Manage notifications (coming soon)',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification settings coming soon!'),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About Section
                  Card(
                    color: Colors.grey[900],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'About',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.info,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'App Version',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            _appVersion ?? 'Loading...',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        ListTile(
                          leading: const Icon(
                            Icons.description,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Terms of Service',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Terms of Service coming soon!'),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                        const Divider(color: Colors.grey),
                        ListTile(
                          leading: const Icon(
                            Icons.privacy_tip,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Privacy Policy',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Privacy Policy coming soon!'),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                        const Divider(color: Colors.grey),
                        ListTile(
                          leading: const Icon(
                            Icons.help,
                            color: Colors.lightBlueAccent,
                          ),
                          title: const Text(
                            'Help & Support',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & Support coming soon!'),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Section
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthLogout());
                context.go(AppRoutes.login);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

