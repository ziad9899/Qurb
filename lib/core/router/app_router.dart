import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/explore/explore_screen.dart';
import '../../features/feed/comments_screen.dart';
import '../../features/feed/composer_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/legal/community_guidelines_screen.dart';
import '../../features/legal/privacy_policy_screen.dart';
import '../../features/legal/report_issue_screen.dart';
import '../../features/legal/terms_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/blocks_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/showcase/design_showcase_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/trend/trend_screen.dart';
import '../../features/welcome/welcome_generated_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/whispers/whisper_thread_screen.dart';
import '../../features/whispers/whispers_list_screen.dart';

/// go_router configuration.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (_, __) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'generated',
            name: 'welcome-generated',
            builder: (_, __) => const WelcomeGeneratedScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const FeedScreen(),
      ),
      GoRoute(
        path: '/compose',
        name: 'compose',
        builder: (_, __) => const ComposerScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        name: 'post-comments',
        builder: (_, state) => CommentsScreen(
          postId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/whispers',
        name: 'whispers',
        builder: (_, __) => const WhispersListScreen(),
        routes: [
          GoRoute(
            path: ':chatId',
            name: 'whisper-thread',
            builder: (_, state) => WhisperThreadScreen(
              chatId: int.parse(state.pathParameters['chatId']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (_, __) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/trend',
        name: 'trend',
        builder: (_, __) => const TrendScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'blocks',
            name: 'settings-blocks',
            builder: (_, __) => const BlocksScreen(),
          ),
          GoRoute(
            path: 'terms',
            name: 'settings-terms',
            builder: (_, __) => const TermsScreen(),
          ),
          GoRoute(
            path: 'privacy',
            name: 'settings-privacy',
            builder: (_, __) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'community',
            name: 'settings-community',
            builder: (_, __) => const CommunityGuidelinesScreen(),
          ),
          GoRoute(
            path: 'report',
            name: 'settings-report',
            builder: (_, __) => const ReportIssueScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/showcase',
        name: 'showcase',
        builder: (_, __) => const DesignShowcaseScreen(),
      ),
    ],
  );
});
