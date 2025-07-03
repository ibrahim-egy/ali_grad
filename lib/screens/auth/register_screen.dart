import 'package:ali_grad/widgets/inputBox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/theme.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  UserService userService = UserService();
  String selectedRole = 'poster';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void onSubmit() async {
    final response = await userService.registerUser(
      firstname: firstnameController.text.trim(),
      lastname: lastnameController.text.trim(),
      email: emailController.text.trim(),
      username: usernameController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (response) {
      Navigator.pushNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Container(
        color: AppTheme.primaryColor.withValues(alpha: .7),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: SvgPicture.asset(
                "assets/svg/register.svg",
                height: 100,
                width: 100,
                color: Colors.white,
              ),
            ),
            Expanded(
              flex: 14,
              child: Container(
                padding: EdgeInsets.all(AppTheme.paddingHuge),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(90),
                  ),
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
                              Text(
                                "Signup",
                                style: AppTheme.textStyle0.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// First & Last Name
                              Row(
                                children: [
                                  Expanded(
                                    child: InputBox(
                                      obscure: false,
                                      label: "First name",
                                      hintText: "Mohamed",
                                      controller: firstnameController,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.paddingMedium),
                                  Expanded(
                                    child: InputBox(
                                      obscure: false,
                                      label: "Last name",
                                      hintText: "Amr",
                                      controller: lastnameController,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Email
                              InputBox(
                                obscure: false,
                                label: "Email",
                                hintText: "Hello@example.com",
                                controller: emailController,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Username & Phone
                              Row(
                                children: [
                                  Expanded(
                                    child: InputBox(
                                      obscure: false,
                                      label: "Username",
                                      hintText: "Mohamed",
                                      controller: usernameController,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.paddingMedium),
                                  Expanded(
                                    child: InputBox(
                                      obscure: false,
                                      label: "Phone",
                                      hintText: "0123456789",
                                      controller: phoneController,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Password
                              InputBox(
                                obscure: true,
                                label: "Password",
                                hintText: "Enter your password",
                                controller: passwordController,
                              ),
                              Spacer(),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Join Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  onSubmit();
                                },
                                child: const Text(
                                  "Join Gigs",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppTheme.paddingMedium),

                              /// Login Link
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Already have an account? ",
                                      style: AppTheme.textStyle1.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Login",
                                          style: AppTheme.textStyle1.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppTheme.paddingLarge),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
