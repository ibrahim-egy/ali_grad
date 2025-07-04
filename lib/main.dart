import 'package:ali_grad/screens/get_started_screen.dart';
import 'package:ali_grad/screens/home/home_screen_runner.dart';
import 'package:ali_grad/screens/home/runner_shell.dart';
import 'package:ali_grad/screens/task/my_tasks_screen.dart';
import 'package:ali_grad/screens/task/post_task_screen.dart';
import 'package:ali_grad/screens/profile/edit_profile_screen.dart';
import 'package:ali_grad/screens/profile/profile_screen.dart';
import 'package:ali_grad/screens/task/task_details.dart';
import 'package:ali_grad/widgets/nabbar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home/home_screen_poster.dart';
import 'constants/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GigsApp());
}

class GigsApp extends StatelessWidget {
  const GigsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MaterialApp(
      title: 'Gigs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppTheme.primaryColor,
          secondary: AppTheme.accentColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          titleTextStyle: AppTheme.textStyle0,
          iconTheme: IconThemeData(
            color: AppTheme.textColor,
          ),
        ),
      ),
      home: const GetStartedScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/poster-home': (context) => const PosterShell(),
        '/runner-home': (context) => const RunnerShell(),
        '/post-task': (context) => const PostTaskScreen(),
        '/my-tasks': (context) => const MyTasksScreen(),
      },
    ));
  }
}
