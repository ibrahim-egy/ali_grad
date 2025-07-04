import 'package:ali_grad/constants/theme.dart';
import 'package:ali_grad/services/offer_service.dart';
import 'package:ali_grad/widgets/TaskCard.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';

class MyTasksScreenRunner extends StatefulWidget {
  const MyTasksScreenRunner({super.key});

  @override
  State<MyTasksScreenRunner> createState() => _MyTasksScreenRunnerState();
}

class _MyTasksScreenRunnerState extends State<MyTasksScreenRunner> {
  OfferService offerService = OfferService();
  List<TaskResponse> assignedTasks = [];

  Future<void> getAssignedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;
    final tasks = await offerService.getAcceptedOffersTasks(int.parse(userId));
    setState(() {
      assignedTasks = tasks;
    });
  }

  @override
  void initState() {
    super.initState();
    getAssignedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "My Tasks"),
      body: RefreshIndicator(
        onRefresh: () async {
          await getAssignedTasks();
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingHuge),
              child: Column(
                children: [
                  Text(
                    "Assigned Tasks",
                    style: AppTheme.textStyle0,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  for (var i = 0; i < assignedTasks.length; i++) ...[
                    TaskCard(
                      task: assignedTasks[i],
                      showActions: false,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
