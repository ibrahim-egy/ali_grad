import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../profile/profile_screen.dart';
import '../runner_offers_screen.dart';
import '../task/my_tasks_screen_runner.dart';
import 'home_screen_poster.dart';
import 'home_screen_runner.dart';
import '../messages_tab.dart';

class MyOffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('My Offers'));
}

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Chats'));
}

class RunnerShell extends StatefulWidget {
  const RunnerShell({Key? key}) : super(key: key);

  @override
  State<RunnerShell> createState() => _RunnerShellState();
}

class _RunnerShellState extends State<RunnerShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreenRunner(),
    RunnerOffersScreen(),
    MessagesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) => setState(() => _currentIndex = newIndex),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColor1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in),
            label: 'My Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}
