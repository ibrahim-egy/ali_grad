import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../screens/home/home_screen_poster.dart';
import '../screens/messages_screen.dart';
import '../screens/task/my_tasks_screen.dart';
import '../screens/offers_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'bottom_nav_bar.dart';

class PosterShell extends StatefulWidget {
  const PosterShell({Key? key}) : super(key: key);

  @override
  State<PosterShell> createState() => _PosterShellState();
}

class _PosterShellState extends State<PosterShell> {
  int _currentIndex = 0;

  // All the poster‐mode pages:
  static const _pages = [
    HomeScreenPoster(),
    MyTasksScreen(),
    OffersScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: PosterBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) => setState(() => _currentIndex = newIndex),
        // optionally wire in your badge counts here:
        // offersCount: someState.offers,
        // messagesCount: someState.messages,
      ),
    );
  }
}
