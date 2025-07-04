import 'dart:async';
import 'package:ali_grad/models/user_model.dart';
import 'package:ali_grad/widgets/inputBox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/theme.dart';
import '../../services/user_service.dart';
import '../admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  UserService userService = UserService();
  String selectedRole = 'poster';
  bool isLoading = false;

  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late AnimationController _formController;
  late Animation<Offset> _formOffsetAnimation;
  late AnimationController _bgController;
  late Animation<Color?> _bgColor1;
  late Animation<Color?> _bgColor2;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _formOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _bgColor1 = ColorTween(
      begin: AppTheme.primaryColor.withOpacity(0.9),
      end: AppTheme.accentColor.withOpacity(0.9),
    ).animate(_bgController);
    _bgColor2 = ColorTween(
      begin: AppTheme.accentColor.withOpacity(0.7),
      end: AppTheme.primaryColor.withOpacity(0.7),
    ).animate(_bgController);
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void onSubmit() async {
    setState(() => isLoading = true);
    final response = await userService.loginUser(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      selectedRole: selectedRole,
    );
    setState(() => isLoading = false);
    if (response) {
      if (usernameController.text.trim() == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else {
        Navigator.pushNamed(context, "/$selectedRole-home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _bgColor1.value ?? AppTheme.primaryColor,
                  _bgColor2.value ?? AppTheme.accentColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _logoAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_logoAnimation),
                      child: SvgPicture.asset(
                        "assets/svg/login.svg",
                        height: 120,
                        width: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SlideTransition(
                      position: _formOffsetAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        padding: EdgeInsets.all(AppTheme.paddingHuge),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(90),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 24,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        "Login",
                                        style: AppTheme.textStyle0.copyWith(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),
                                      // Username
                                      Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(16),
                                        child: TextField(
                                          controller: usernameController,
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.person_outline_rounded),
                                            labelText: "Username",
                                            hintText: "Enter your username",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Password
                                      Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(16),
                                        child: TextField(
                                          controller: passwordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                                            labelText: "Password",
                                            hintText: "Enter your password",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Role selection
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AnimatedScale(
                                              scale: selectedRole == "poster" ? 1.08 : 1.0,
                                              duration: const Duration(milliseconds: 200),
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.campaign_outlined),
                                                label: const Text("Poster"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedRole == "poster"
                                                      ? AppTheme.primaryColor
                                                      : AppTheme.disabledColor,
                                                  foregroundColor: Colors.white,
                                                  elevation: selectedRole == "poster" ? 4 : 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    selectedRole = "poster";
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: AnimatedScale(
                                              scale: selectedRole == "runner" ? 1.08 : 1.0,
                                              duration: const Duration(milliseconds: 200),
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.directions_run_rounded),
                                                label: const Text("Runner"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: selectedRole == "runner"
                                                      ? AppTheme.primaryColor
                                                      : AppTheme.disabledColor,
                                                  foregroundColor: Colors.white,
                                                  elevation: selectedRole == "runner" ? 4 : 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    selectedRole = "runner";
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      // Login Button
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: isLoading
                                            ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: CircularProgressIndicator(
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                              )
                                            : ElevatedButton(
                                                key: const ValueKey("loginBtn"),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  backgroundColor: AppTheme.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                onPressed: onSubmit,
                                                child: const Text(
                                                  "Login",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Sign Up Link
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context, '/register');
                                          },
                                          child: AnimatedScale(
                                            scale: 1.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: RichText(
                                              text: TextSpan(
                                                text: "Don't have any account? ",
                                                style: AppTheme.textStyle1.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Sign Up",
                                                    style: AppTheme.textStyle1.copyWith(
                                                      color: AppTheme.primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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
