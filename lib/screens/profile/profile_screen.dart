import 'package:ali_grad/constants/theme.dart';
import 'package:ali_grad/services/user_service.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/my_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserService userService = UserService();
  String firstName = "";
  String lastName = "";
  String role = "";
  String userInitials = "";

  bool isLoading = true;

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userData = await userService.getUserById(userId!);

    if (userData != null) {
      setState(() {
        firstName = userData.firstName;
        lastName = userData.lastName;
        userInitials = "${firstName[0]} ${lastName[0]}";
        role = prefs.getString('role')!;
        isLoading = false;
      });
    } else {
      isLoading = false;
      Navigator.pop(context);
    }
  }

  void changeRole() async {
    String selectedRole = role == "runner" ? "poster" : "runner";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', selectedRole);
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/$selectedRole-home", // route name
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void logout() async {
    await userService.logoutUser();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // route name
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
        showBackButton: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(AppTheme.paddingHuge),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: MyBox(
                      backgroundColor: AppTheme.primaryColor,
                      boxPadding: 0,
                      boxChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Text(
                              userInitials,
                              style: AppTheme.textStyle0.copyWith(fontSize: 32),
                            ),
                          ),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                          Text(
                            "$firstName $lastName",
                            style: AppTheme.textStyle0.copyWith(
                                color: AppTheme.textColor2, fontSize: 26),
                          ),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                          Text(role,
                              style: AppTheme.textStyle2.copyWith(
                                color: AppTheme.disabledColor,
                              )),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "0",
                                    style: AppTheme.textStyle0
                                        .copyWith(color: AppTheme.textColor2),
                                  ),
                                  SizedBox(
                                    height: AppTheme.paddingSmall,
                                  ),
                                  Text(
                                    "Task Done",
                                    style: AppTheme.textStyle2.copyWith(
                                        color: AppTheme.disabledColor),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Container(
                                width: 1,
                                height: 48,
                                color: AppTheme.dividerColor,
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "0",
                                    style: AppTheme.textStyle0
                                        .copyWith(color: AppTheme.textColor2),
                                  ),
                                  SizedBox(
                                    height: AppTheme.paddingSmall,
                                  ),
                                  Text(
                                    "Earnings",
                                    style: AppTheme.textStyle2.copyWith(
                                        color: AppTheme.disabledColor),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppTheme.paddingLarge,
                  ),
                  Expanded(
                    flex: 4,
                    child: MyBox(
                      boxPadding: AppTheme.paddingHuge,
                      boxChild: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: changeRole,
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: .3),
                                  ),
                                  child:
                                      Icon(HugeIcons.strokeRoundedWorkoutRun),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Become a ${role == "runner" ? "poster" : "runner"}",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(HugeIcons.strokeRoundedArrowRight01)
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                {Navigator.pushNamed(context, "/edit-profile")},
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: .3),
                                  ),
                                  child: Icon(HugeIcons.strokeRoundedEdit03),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Edit profile",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(HugeIcons.strokeRoundedArrowRight01)
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: AppTheme.borderRadius,
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: .3),
                                ),
                                child: Icon(HugeIcons.strokeRoundedWorkoutRun),
                              ),
                              SizedBox(
                                width: AppTheme.paddingSmall,
                              ),
                              Text(
                                "Payment History",
                                style:
                                    AppTheme.textStyle0.copyWith(fontSize: 16),
                              ),
                              Spacer(),
                              Icon(HugeIcons.strokeRoundedArrowRight01)
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: AppTheme.borderRadius,
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: .3),
                                ),
                                child: Icon(HugeIcons.strokeRoundedWorkoutRun),
                              ),
                              SizedBox(
                                width: AppTheme.paddingSmall,
                              ),
                              Text(
                                "Become a runner",
                                style:
                                    AppTheme.textStyle0.copyWith(fontSize: 16),
                              ),
                              Spacer(),
                              Icon(HugeIcons.strokeRoundedArrowRight01)
                            ],
                          ),
                          GestureDetector(
                            onTap: logout,
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: Colors.red.withValues(alpha: .2),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Logout",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(
                                  HugeIcons.strokeRoundedArrowRight01,
                                  color: AppTheme.primaryColor,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
