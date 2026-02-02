import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/partner_link/partner_link_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/talk_heal/screens/conflict_cooling_screen.dart';
import '../features/talk_heal/screens/conflict_dashboard_screen.dart';
import '../features/talk_heal/screens/conflict_joint_session_screen.dart';
import '../features/talk_heal/screens/conflict_private_input_screen.dart';
import '../features/talk_heal/screens/conflict_resolution_hub_screen.dart';
import '../features/talk_heal/screens/guided_conversation_screen.dart';
import '../features/grow/screens/date_planner_screen.dart';
import '../features/grow/screens/grow_screen.dart';
import '../features/grow/screens/habit_challenges_screen.dart';
import '../features/grow/screens/ritual_scheduler_screen.dart';
import '../features/journal/screens/journal_calendar_screen.dart';
import '../features/journal/screens/journal_entry_detail_screen.dart';
import '../features/journal/screens/journal_new_entry_screen.dart';
import '../features/journal/screens/journal_screen.dart';
import '../features/community/screens/community_screen.dart';
import '../features/community/screens/forum_room_screen.dart';
import '../features/community/screens/saved_threads_screen.dart';
import '../features/community/screens/thread_detail_screen.dart';
import '../features/experts/screens/ask_expert_screen.dart';
import '../features/experts/screens/experts_screen.dart';
import '../features/experts/screens/live_room_screen.dart';
import '../features/experts/screens/my_questions_screen.dart';
import '../features/premium/screens/paywall_screen.dart';
import '../features/insights/screens/insights_screen.dart';
import '../features/task_bank/screens/things_to_do_screen.dart';
import '../features/more/screens/more_screen.dart';
import '../features/profile/screens/about_screen.dart';
import '../features/profile/screens/account_settings_screen.dart';
import '../features/profile/screens/notifications_settings_screen.dart';
import '../features/profile/screens/privacy_settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../shared/widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/partner-link',
        name: 'partner-link',
        builder: (context, state) => const PartnerLinkScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/talk',
                name: 'talk',
                builder: (context, state) => const GuidedConversationScreen(),
              ),
              GoRoute(
                path: '/talk/session/:id',
                name: 'talk-session',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return GuidedConversationSessionScreen(sessionId: id);
                },
              ),
              GoRoute(
                path: '/talk/repair',
                name: 'talk-repair',
                builder: (context, state) => const ConflictResolutionHubScreen(),
              ),
              GoRoute(
                path: '/talk/repair/input',
                name: 'talk-repair-input',
                builder: (context, state) => const ConflictPrivateInputScreen(),
              ),
              GoRoute(
                path: '/talk/repair/cooling',
                name: 'talk-repair-cooling',
                builder: (context, state) => const ConflictCoolingScreen(),
              ),
              GoRoute(
                path: '/talk/repair/session',
                name: 'talk-repair-session',
                builder: (context, state) => const ConflictJointSessionScreen(),
              ),
              GoRoute(
                path: '/talk/conflict-dashboard',
                name: 'talk-conflict-dashboard',
                builder: (context, state) => const ConflictDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/grow',
                name: 'grow',
                builder: (context, state) => const GrowScreen(),
              ),
              GoRoute(
                path: '/grow/challenges',
                name: 'grow-challenges',
                builder: (context, state) => const HabitChallengesScreen(),
              ),
              GoRoute(
                path: '/grow/rituals',
                name: 'grow-rituals',
                builder: (context, state) => const RitualSchedulerScreen(),
              ),
              GoRoute(
                path: '/grow/dates',
                name: 'grow-dates',
                builder: (context, state) => const DatePlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                name: 'journal',
                builder: (context, state) => const JournalScreen(),
              ),
              GoRoute(
                path: '/journal/entry/:id',
                name: 'journal-entry',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return JournalEntryDetailScreen(entryId: id);
                },
              ),
              GoRoute(
                path: '/journal/calendar',
                name: 'journal-calendar',
                builder: (context, state) => const JournalCalendarScreen(),
              ),
              GoRoute(
                path: '/journal/new',
                name: 'journal-new',
                builder: (context, state) => const JournalNewEntryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                name: 'more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        name: 'profile-notifications',
        builder: (context, state) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        name: 'profile-privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/profile/account',
        name: 'profile-account',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        name: 'profile-about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/community/room/:id',
        name: 'community-room',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final title = state.uri.queryParameters['title'];
          return ForumRoomScreen(roomId: id, roomTitle: title);
        },
      ),
      GoRoute(
        path: '/community/thread/:id',
        name: 'community-thread',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ThreadDetailScreen(threadId: id);
        },
      ),
      GoRoute(
        path: '/community/saved',
        name: 'community-saved',
        builder: (context, state) => const SavedThreadsScreen(),
      ),
      GoRoute(
        path: '/experts',
        name: 'experts',
        builder: (context, state) => const ExpertsScreen(),
      ),
      GoRoute(
        path: '/experts/ask',
        name: 'experts-ask',
        builder: (context, state) {
          final expertId = state.uri.queryParameters['expert'];
          return AskExpertScreen(expertId: expertId);
        },
      ),
      GoRoute(
        path: '/experts/questions',
        name: 'experts-questions',
        builder: (context, state) => const MyQuestionsScreen(),
      ),
      GoRoute(
        path: '/experts/live/:id',
        name: 'experts-live',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return LiveRoomScreen(roomId: id);
        },
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/insights',
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/things-to-do',
        name: 'things-to-do',
        builder: (context, state) => const ThingsToDoScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
    ],
  );
});
