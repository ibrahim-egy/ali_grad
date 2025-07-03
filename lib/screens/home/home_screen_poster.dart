import 'package:ali_grad/services/task_service.dart';
import 'package:ali_grad/services/user_service.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:ali_grad/widgets/greeting_banner.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/my_box.dart';
import '../../widgets/unassigned_task_card.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/task_model.dart';
import '../../widgets/TaskCard.dart';
import '../../utils/location.dart';

class HomeScreenPoster extends StatefulWidget {
  const HomeScreenPoster({Key? key}) : super(key: key);

  @override
  State<HomeScreenPoster> createState() => _HomeScreenPosterState();
}

class _HomeScreenPosterState extends State<HomeScreenPoster> {
  final TaskService taskService = TaskService();
  final UserService userService = UserService();
  final PageController _pageController = PageController();

  List<TaskResponse> unassignedTasks = [];
  List<TaskResponse> ongoingTasks = [];
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isLoadingOngoing = true;

  void deleteTask(int taskId, TaskResponse task) async {
    final fullJson = task.toJson();
    final nonNullJson = <String, dynamic>{};
    fullJson.forEach((key, value) {
      if (value != null) nonNullJson[key] = value;
    });
    // Ensure task_type is present for backend compatibility
    if (!nonNullJson.containsKey('task_type')) {
      if (task.category.name == 'EVENT_STAFFING') {
        nonNullJson['task_type'] = 'EVENT';
      } else {
        nonNullJson['task_type'] = 'REGULAR';
      }
    }
    print(nonNullJson);
    final success = await taskService.deleteTask(taskId, nonNullJson);

    if (success) {
      setState(() {
        unassignedTasks.removeWhere((t) => t.taskId == taskId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUnassignedTasks();
    getOngoingTasks();
  }

  Future<void> getUnassignedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("❌ No userId found");
      return;
    }

    final tasks = await taskService.getUnassignedTasks(userId);
    setState(() {
      unassignedTasks = tasks;
      _isLoading = false;
    });

    if (unassignedTasks.isNotEmpty) {
      print("✅ Found ${unassignedTasks.length} unassigned tasks");
    } else {
      print("❌ No unassigned tasks found");
    }
  }

  Future<void> getOngoingTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      print("❌ No userId found");
      return;
    }
    setState(() => _isLoadingOngoing = true);
    final tasks = await taskService.getOngoingTasks(userId);
    setState(() {
      ongoingTasks = tasks;
      _isLoadingOngoing = false;
    });
  }

  UnassignedTask mapToUnassignedCard(TaskResponse task) {
    return UnassignedTask(
      title: task.title,
      category: task.category.name, // assumes enum with .name
      offers: 1,
      date: DateTime.tryParse(task.additionalRequirements['deadline'] ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Home Poster"),
      body: RefreshIndicator(
        backgroundColor: AppTheme.backgroundColor,
        onRefresh: () async {
          getUnassignedTasks();
          getOngoingTasks();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          children: [
            const GreetingBanner(name: "Ali"),
            SizedBox(
              height: AppTheme.paddingMedium,
            ),
            // On Going Tasks Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("On Going Tasks", style: AppTheme.headerTextStyle),
                TextButton(
                  onPressed: () {}, // Navigate to all tasks if needed
                  child: Text(
                    "View all",
                    style: AppTheme.textStyle1.copyWith(
                      fontWeight: FontWeight.w100,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),

            // PageView for tasks overview
            SizedBox(
              height: 180,
              child: _isLoadingOngoing
                  ? const Center(child: CircularProgressIndicator())
                  : (ongoingTasks.isEmpty)
                      ? const Center(child: Text("No ongoing tasks found."))
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: ongoingTasks.length,
                          padEnds: false,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemBuilder: (context, i) {
                            final task = ongoingTasks[i];
                            return MyBox(
                              backgroundColor:
                                  i == 0 ? AppTheme.primaryColor : null,
                              boxPadding: AppTheme.paddingMedium,
                              boxChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('MMMM d, yyyy').format(
                                            task.createdDate != null
                                                ? DateTime.tryParse(
                                                        task.createdDate) ??
                                                    DateTime.now()
                                                : DateTime.now()),
                                        style: AppTheme.textStyle2.copyWith(
                                          fontSize: 12,
                                          color: i == 0
                                              ? Colors.white
                                              : AppTheme.primaryColor,
                                        ),
                                      ),
                                      Icon(
                                        FontAwesomeIcons.ellipsisVertical,
                                        size: AppTheme.paddingMedium,
                                        color: i == 0 ? Colors.white : null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.paddingSmall),
                                  Row(
                                    children: [
                                      Icon(
                                        HugeIcons.strokeRoundedClean,
                                        size: 32,
                                        color: i == 0
                                            ? Colors.white
                                            : AppTheme.primaryColor,
                                      ),
                                      const SizedBox(
                                          width: AppTheme.paddingTiny),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: AppTheme.textStyle0.copyWith(
                                              fontSize: 16,
                                              color:
                                                  i == 0 ? Colors.white : null,
                                            ),
                                          ),
                                          FutureBuilder<String?>(
                                            future: userService.getUsernameById(task.runnerId.toString()),
                                            builder: (context, snapshot) {
                                              return Text(
                                                snapshot.hasData 
                                                    ? snapshot.data! 
                                                    : 'Loading...',
                                                style: AppTheme.textStyle2.copyWith(
                                                  fontSize: 10,
                                                  color:
                                                      i == 0 ? Colors.white : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.paddingSmall),
                                  FloatingActionButton.small(
                                    heroTag: 'ongoing_$i',
                                    onPressed: () {}, // Add message handler
                                    elevation: 0,
                                    backgroundColor: i == 0
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppTheme.borderRadius,
                                    ),
                                    child: Text(
                                      "Message",
                                      style: AppTheme.textStyle2.copyWith(
                                        color: i == 0
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: AppTheme.paddingSmall),

            // PageView indicators
            if (!_isLoadingOngoing && ongoingTasks.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(ongoingTasks.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppTheme.primaryColor : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

            const SizedBox(height: AppTheme.paddingLarge),

            // Unassigned Tasks Section
            Text("Unassigned Tasks", style: AppTheme.headerTextStyle),
            const SizedBox(height: AppTheme.paddingMedium),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (unassignedTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text("No tasks found.")),
              )
            else
              Column(
                children: unassignedTasks.map((task) {
                  final taskId = task.taskId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: FutureBuilder<String?>(
                      future: fetchCity(
                        latitude: task.latitude,
                        longitude: task.longitude,
                      ),
                      builder: (context, snapshot) {
                        return TaskCard(
                          task: task,
                          city: snapshot.hasData ? snapshot.data : null,
                          button2OnPress: () {
                            deleteTask(taskId, task);
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, "/post-task");
        },
        icon: const Icon(Icons.add),
        label: const Text('Post a Task'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
