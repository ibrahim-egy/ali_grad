import 'package:ali_grad/constants/theme.dart';
import 'package:ali_grad/services/task_service.dart';
import 'package:ali_grad/utils/location.dart';
import 'package:ali_grad/widgets/TaskCard.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/task_model.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  TaskService taskService = TaskService();
  Future<String> getCityName(lat, lon) async {
    var res = await fetchCity(
      latitude: lat,
      longitude: lon,
    );
    return res.toString();
  }

  List<TaskResponse> allTasks = [];

  Future<void> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await taskService.getTasksByTaskPosterId(userId!);

    setState(() {
      allTasks = response!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Tasks"),
      body: RefreshIndicator(
        onRefresh: () async {
          await getAllTasks();
        },
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingHuge),
            child: Column(
              children: [
                Text(
                  "All Tasks",
                  style: AppTheme.textStyle0,
                ),
                SizedBox(
                  height: AppTheme.paddingMedium,
                ),
                for (var i = 0; i < allTasks.length; i++) ...[
                  // PosterTaskCard(
                  //   task: allTasks[i],
                  // ),
                  FutureBuilder<String?>(
                    future: fetchCity(
                      latitude: allTasks[i].latitude,
                      longitude: allTasks[i].longitude,
                    ),
                    builder: (context, snapshot) {
                      return TaskCard(
                        task: allTasks[i],
                        city: snapshot.hasData ? snapshot.data : null,
                        showActions: false,
                      );
                    },
                  ),

                  SizedBox(
                    height: AppTheme.paddingMedium,
                  ),
                ]
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
