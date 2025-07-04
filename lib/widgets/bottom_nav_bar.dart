import 'package:flutter/material.dart';
import '../constants/theme.dart';

class PosterBottomNavBar extends StatelessWidget {
  static const double iconSize = 25.0;
  static const double labelFontSize = 15.0;

  final int currentIndex;
  final int offersCount;
  final int messagesCount;
  final ValueChanged<int>? onTap;

  const PosterBottomNavBar({
    Key? key,
    required this.currentIndex,
    this.offersCount = 0,
    this.messagesCount = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColor1,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: labelFontSize,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: labelFontSize,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: iconSize),
            activeIcon: Icon(Icons.home, size: iconSize),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined, size: iconSize),
            activeIcon: Icon(Icons.list_alt, size: iconSize),
            label: 'My Tasks',
          ),

          BottomNavigationBarItem(
            icon: _buildBadgeIcon(
              Icons.chat_bubble_outline,
              messagesCount,
              active: false,
            ),
            activeIcon: _buildBadgeIcon(
              Icons.chat,
              messagesCount,
              active: true,
            ),
            label: 'Messages',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person_outline, size: iconSize),
          //   activeIcon: Icon(Icons.person, size: iconSize),
          //   label: 'Profile',
          // ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(IconData iconData, int count, {required bool active}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          iconData,
          size: iconSize,
          color: active ? AppTheme.primaryColor : AppTheme.textColor1,
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -3,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.urgentColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class RunnerBottomNavBar extends StatelessWidget {
  final int currentIndex;

  /// Optional badge counts
  final int earningsCount;
  final int messagesCount;

  const RunnerBottomNavBar({
    Key? key,
    required this.currentIndex,
    this.earningsCount = 0,
    this.messagesCount = 0,
  }) : super(key: key);

  static const double _iconSize = 24.0;
  static const double _labelFontSize = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.backgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColor1,
        selectedLabelStyle: const TextStyle(
          fontSize: _labelFontSize,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: _labelFontSize,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: _iconSize),
            activeIcon: Icon(Icons.home, size: _iconSize),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, size: _iconSize),
            activeIcon: Icon(Icons.explore, size: _iconSize),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: _iconSize),
                if (earningsCount > 0)
                  Positioned(
                    right: -6,
                    top: -3,
                    child: _Badge(count: earningsCount),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.account_balance_wallet,
                    size: _iconSize, color: AppTheme.primaryColor),
                if (earningsCount > 0)
                  Positioned(
                    right: -6,
                    top: -3,
                    child: _Badge(count: earningsCount),
                  ),
              ],
            ),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.chat_bubble_outline, size: _iconSize),
                if (messagesCount > 0)
                  Positioned(
                    right: -6,
                    top: -3,
                    child: _Badge(count: messagesCount),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.chat_bubble,
                    size: _iconSize, color: AppTheme.primaryColor),
                if (messagesCount > 0)
                  Positioned(
                    right: -6,
                    top: -3,
                    child: _Badge(count: messagesCount),
                  ),
              ],
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: _iconSize),
            activeIcon: Icon(Icons.person, size: _iconSize),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Small badge for count display over icons.
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: AppTheme.urgentColor,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
