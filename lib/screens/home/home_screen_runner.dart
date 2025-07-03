import 'package:ali_grad/models/event_application_model.dart';
import 'package:ali_grad/models/offer_model.dart';
import 'package:ali_grad/services/event_application_service.dart';
import 'package:ali_grad/services/offer_service.dart';
import 'package:ali_grad/utils/location.dart';
import 'package:ali_grad/widgets/TaskCard.dart';
import 'package:ali_grad/widgets/MyBadge.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:ali_grad/widgets/current_task_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ali_grad/widgets/greeting_banner.dart';
import 'package:ali_grad/widgets/search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../offers_screen.dart';

class HomeScreenRunner extends StatefulWidget {
  const HomeScreenRunner({super.key});

  @override
  State<HomeScreenRunner> createState() => _HomeScreenRunnerState();
}

class _HomeScreenRunnerState extends State<HomeScreenRunner> {
  List<TaskResponse> nearTasks = [];

  Position? currentUserPosition;
  OfferService offerService = OfferService();

  EventApplicationService eventApplicationService = EventApplicationService();

  double _radius = 10; // Default radius in km
  final List<double> _radiusOptions = [2, 5, 10, 20, 50];

  Future<void> onApplicationSubmit(
      {required int taskId, String? comment, String? resumeLink}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      EventApplication eventReq = EventApplication(
        taskId: taskId,
        applicantId: int.parse(userId),
        comment: comment!,
        resumeLink: resumeLink!,
      );

      print(eventReq.toJson());

      final success = await eventApplicationService.applyToEvent(eventReq);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You Have Applied 🎯")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Apply 😢")),
        );
      }
      ;
    }
  }

  void onOfferSubmit({
    required int taskId,
    required double amount,
    String? comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      Offer offerReq = Offer(
        taskId: taskId,
        runnerId: int.parse(userId),
        amount: amount,
        comment: comment ?? "",
      );

      final success = await offerService.placeOffer(offerReq);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("You Have Placed an Offer ${amount.toString()} EGP")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place offer 😢")),
        );
      }
      ;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    fetchNearbyTasks();
  }

  Future<void> fetchNearbyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("❌ No userId found");
      return;
    }

    final service = TaskService();

    currentUserPosition = await getCurrentLocation();
    if (currentUserPosition == null) {
      print("Failed to get location");
      return;
    }

    print(userId);

    final tasks = await service.getNearbyTasks(
      radius: _radius,
      latitude: currentUserPosition!.latitude,
      longitude: currentUserPosition!.longitude,
      userId: userId,
    );

    if (!mounted) return;

    setState(() {
      nearTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Home Runner"),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchNearbyTasks();
        },
        child: ListView(
          padding: EdgeInsets.all(AppTheme.paddingMedium),
          children: [
            GreetingBanner(name: "Ali", location: "Giza"),
            SizedBox(height: AppTheme.paddingMedium),
            CurrentTaskCard(
              title: "Move Furniture to new apartment",
              subtitle: "Moving large furniture to 5th floor",
              poster: "Sarah M.",
              date: DateTime(2025, 1, 1),
            ),
            SizedBox(height: AppTheme.paddingLarge),
            // Tasks Near You header and Radius selector
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Tasks Near You",
                  style: AppTheme.textStyle0,
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: _radius,
                      icon:
                          Icon(Icons.expand_more, color: AppTheme.primaryColor),
                      items: _radiusOptions
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text('${r.toInt()} km',
                                    style: AppTheme.textStyle1.copyWith(
                                        color: AppTheme.primaryColor)),
                              ))
                          .toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() => _radius = value);
                          await fetchNearbyTasks();
                        }
                      },
                      style: AppTheme.textStyle1
                          .copyWith(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.paddingLarge),
            if (nearTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text("No nearby tasks found.")),
              )
            else
              Column(
                children: nearTasks.map((task) {
                  final distance = calculateDistance(
                    lat1: currentUserPosition!.latitude,
                    lon1: currentUserPosition!.longitude,
                    lat2: task.latitude,
                    lon2: task.longitude,
                  );

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                    child: TaskCard(
                      distance: distance,
                      task: task,
                      button2OnPress: task.category.name != "EVENT_STAFFING"
                          ? () async {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28)),
                                ),
                                builder: (context) => RaiseOfferBottomSheet(
                                    category: task.category.name,
                                    onSubmit: (
                                        {double? amount,
                                        String? comment,
                                        String? resumeLink}) {
                                      onOfferSubmit(
                                          taskId: task.taskId,
                                          amount: amount!,
                                          comment: comment);
                                    }),
                              );
                            }
                          : () async {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28)),
                                ),
                                builder: (context) => RaiseOfferBottomSheet(
                                  category: task.category.name,
                                  onSubmit: (
                                      {double? amount,
                                      String? comment,
                                      String? resumeLink}) {
                                    onApplicationSubmit(
                                      taskId: task.taskId,
                                      comment: comment,
                                      resumeLink: resumeLink,
                                    );
                                  },
                                ),
                              );
                            },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
