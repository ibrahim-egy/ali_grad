import 'package:ali_grad/models/task_model.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:ali_grad/widgets/my_box.dart';
import 'package:ali_grad/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../constants/theme.dart';
import 'package:ali_grad/services/user_service.dart';
import 'package:ali_grad/services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ali_grad/services/offer_service.dart';
import 'package:ali_grad/models/offer_model.dart';
import 'package:ali_grad/services/event_application_service.dart';
import 'package:ali_grad/models/event_application_model.dart';
import 'package:ali_grad/screens/offers_screen.dart';
import 'package:ali_grad/screens/chat_screen.dart';
import 'package:ali_grad/services/dispute_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskResponse task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  String? runnerUsername;
  String? posterUsername;
  bool isLoadingRunner = false;
  bool isLoadingPoster = false;
  bool isDeleting = false;
  String? selectedRole;
  List<OfferResponse>? offers;
  bool isLoadingOffers = false;
  bool showOffersSection = false;
  Map<int, String> offerRunnerUsernames = {};
  bool isProcessingOffer = false;
  List<EventApplication>? applicants;
  Map<int, String> applicantUsernames = {};
  bool isLoadingApplicants = false;
  bool showApplicantsSection = false;

  @override
  void initState() {
    super.initState();
    _fetchRunnerUsername();
    _fetchPosterUsername();
    _fetchSelectedRole();
  }

  Future<void> _fetchRunnerUsername() async {
    final task = widget.task;
    final isEvent = task.category.name == 'EVENT_STAFFING';
    if (!isEvent && task.runnerId != null && task.status != 'OPEN') {
      setState(() => isLoadingRunner = true);
      final username =
          await UserService().getUsernameById(task.runnerId.toString());
      print(username);
      setState(() {
        runnerUsername = username;
        isLoadingRunner = false;
      });
    }
  }

  Future<void> _fetchPosterUsername() async {
    final task = widget.task;
    setState(() => isLoadingPoster = true);
    final username =
        await UserService().getUsernameById(task.taskPoster.toString());
    setState(() {
      posterUsername = username;
      isLoadingPoster = false;
    });
  }

  Future<String?> _fetchUsernameFromOffer(int id) async {
    final username = await UserService().getUsernameById(id.toString());
    print(username);
    setState(() {
      runnerUsername = username;
      isLoadingRunner = false;
    });
  }

  Future<void> _fetchSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('role');
    });
  }

  // Toggle offers section
  void toggleOffersSection() {
    setState(() {
      showOffersSection = !showOffersSection;
    });
  }

  // Toggle applicants section
  void toggleApplicantsSection() {
    setState(() {
      showApplicantsSection = !showApplicantsSection;
    });
  }

  // Fetch applicants for event tasks
  Future<void> _fetchApplicants() async {
    setState(() {
      isLoadingApplicants = true;
      showApplicantsSection = true;
    });
    final fetchedApplicants = await EventApplicationService()
        .getApplicantsForTask(widget.task.taskId);
    final usernameMap = <int, String>{};
    for (final app in fetchedApplicants) {
      final username =
          await UserService().getUsernameById(app.applicantId.toString());
      if (username != null) {
        usernameMap[app.applicantId] = username;
      }
    }
    setState(() {
      applicants = fetchedApplicants;
      applicantUsernames = usernameMap;
      isLoadingApplicants = false;
    });
  }

  OfferService offerService = OfferService();
  void onOfferSubmit({
    required int taskId,
    required double amount,
    String? comment,
  }) async {
    // Validate authentication before proceeding
    final userService = UserService();
    final isTokenValid = await userService.isTokenValid();
    
    if (!isTokenValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication failed. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

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
        const SnackBar(
          content: Text("Failed to place offer. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  EventApplicationService eventApplicationService = EventApplicationService();

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

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isEvent = task.category.name == 'EVENT_STAFFING';
    final dateFormat = DateFormat('yyyy-MM-dd');
    String? startDate = task.startDate;
    String? endDate = task.endDate;
    String? location = isEvent
        ? task.location
        : (task.additionalAttributes?['location']?.toString());
    int? requiredPeople = task.requiredPeople;
    double? fixedPay = task.fixedPay;
    int? numberOfDays = task.numberOfDays;
    double? amount = task.amount;
    Map<String, dynamic>? additionalAttributes = task.additionalAttributes;
    Map<String, dynamic>? additionalRequirements = task.additionalRequirements;
    String status = task.status;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'OPEN':
        statusColor = AppTheme.successColor;
        statusLabel = 'Open';
        break;
      case 'IN_PROGRESS':
        statusColor = AppTheme.warningColor;
        statusLabel = 'In Progress';
        break;
      case 'DONE':
        statusColor = AppTheme.warningColor;
        statusLabel = 'Marked Done';
        break;
      case 'COMPLETED':
        statusColor = AppTheme.primaryColor;
        statusLabel = 'Completed';
        break;
      case 'CANCELLED':
        statusColor = AppTheme.urgentColor;
        statusLabel = 'Cancelled';
        break;
      default:
        statusColor = AppTheme.textColor1;
        statusLabel = status;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Task Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTheme.headerTextStyle.copyWith(fontSize: 28),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: AppTheme.borderRadius,
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTheme.textStyle2.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            // If the task is marked as DONE, show options to Raise Dispute or Mark as Completed
            if (status == 'DONE')
              Column(
                children: [
                  // --- Raise Dispute Button ---
                  // This button allows the user to raise a dispute if there is an issue with the completed task.
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.report_gmailerrorred, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.urgentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Show animated bottom sheet for dispute
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            builder: (context) => _DisputeBottomSheet(
                              taskId: task.taskId,
                              // Use current user as complainant, other party as defendant
                              getUserIds: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final currentUserId = prefs.getString('userId');
                                int complainantId = int.tryParse(currentUserId ?? '') ?? 0;
                                int defendantId = selectedRole == 'runner'
                                  ? (task.taskPoster is int ? task.taskPoster : int.tryParse(task.taskPoster.toString()) ?? 0)
                                  : (task.runnerId != null ? (task.runnerId is int ? task.runnerId as int : int.tryParse(task.runnerId.toString()) ?? 0) : 0);
                                return [complainantId, defendantId];
                              },
                            ),
                          );
                        },
                        label: const Text(
                          'Raise Dispute',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- Mark as Completed Button ---
                  // This button allows the user to confirm the task is fully completed and close it.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement mark as completed logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mark as completed feature coming soon!')),
                          );
                        },
                        label: const Text(
                          'Mark as Completed',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (selectedRole == 'runner')
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    isLoadingPoster
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primaryColor),
                          )
                        : Text(
                            posterUsername ?? 'Poster',
                            style: AppTheme.textStyle2.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ],
                ),
              ),
            const SizedBox(height: AppTheme.paddingLarge),
            // --- Info Card: Location, Dates, Duration ---
            if (location != null && location.isNotEmpty) ...[
              MyBox(
                boxPadding: AppTheme.paddingLarge,
                boxChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.locationDot,
                            color: AppTheme.primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          location,
                          style: AppTheme.textStyle0.copyWith(
                            color: AppTheme.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    // Event-specific fields
                    if (isEvent) ...[
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.calendar,
                              color: AppTheme.primaryColor, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            startDate != null && endDate != null
                                ? '$startDate → $endDate'
                                : 'No date',
                            style: AppTheme.textStyle2.copyWith(
                              color: AppTheme.textColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      if (numberOfDays != null) ...[
                        const SizedBox(height: AppTheme.paddingMedium),
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.clock,
                                color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Event Duration: $numberOfDays day${numberOfDays == 1 ? '' : 's'}',
                              style: AppTheme.textStyle2.copyWith(
                                color: AppTheme.textColor,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
            ],

            // --- Info Card: People, Pay, Runner ---
            MyBox(
              boxPadding: AppTheme.paddingLarge,
              boxChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEvent) ...[
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.users,
                            color: AppTheme.primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          requiredPeople != null
                              ? '$requiredPeople people needed'
                              : 'N/A',
                          style: AppTheme.textStyle2.copyWith(
                            color: AppTheme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.moneyBill,
                            color: AppTheme.primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          fixedPay != null ? '${fixedPay.toInt()} EGP' : 'N/A',
                          style: AppTheme.textStyle2.copyWith(
                            color: AppTheme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Regular-specific fields
                  if (!isEvent) ...[
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.moneyBill,
                            color: AppTheme.primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          amount != null ? '${amount.toInt()} EGP' : 'N/A',
                          style: AppTheme.textStyle2.copyWith(
                            color: AppTheme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    // Runner name if assigned and not open
                    if (widget.task.runnerId != null &&
                        widget.task.status != 'OPEN') ...[
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.user,
                              color: AppTheme.primaryColor, size: 22),
                          const SizedBox(width: 10),
                          isLoadingRunner
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryColor),
                                )
                              : runnerUsername != null
                                  ? Text(
                                      runnerUsername!,
                                      style: AppTheme.textStyle2.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )
                                  : Text(
                                      'Assigned Runner',
                                      style: AppTheme.textStyle2.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            // --- Info Card: Task Details & Requirements ---
            if (!isEvent &&
                ((additionalAttributes != null &&
                        additionalAttributes.isNotEmpty) ||
                    (additionalRequirements.isNotEmpty))) ...[
              MyBox(
                boxPadding: AppTheme.paddingLarge,
                boxChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (additionalAttributes != null &&
                        additionalAttributes.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.circleInfo,
                              color: AppTheme.primaryColor, size: 22),
                          const SizedBox(width: 10),
                          Text('Task Details',
                              style:
                                  AppTheme.textStyle1.copyWith(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      ...additionalAttributes.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(FontAwesomeIcons.angleRight,
                                    size: 16, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text('${entry.key}: ',
                                    style: AppTheme.textStyle2.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    (entry.key == 'startTime' ||
                                                entry.key == 'endTime') &&
                                            entry.value != null &&
                                            entry.value.toString().isNotEmpty
                                        ? DateFormat('yyyy-MM-dd').format(
                                            DateTime.tryParse(
                                                    entry.value.toString()) ??
                                                DateTime.now())
                                        : '${entry.value}',
                                    style: AppTheme.textStyle2
                                        .copyWith(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: AppTheme.paddingSmall),
                    ],
                    if (additionalRequirements.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.clipboardList,
                              color: AppTheme.primaryColor, size: 22),
                          const SizedBox(width: 10),
                          Text('Requirements',
                              style:
                                  AppTheme.textStyle1.copyWith(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      ...additionalRequirements.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(FontAwesomeIcons.angleRight,
                                    size: 16, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text('${entry.key}: ',
                                    style: AppTheme.textStyle2.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Expanded(
                                  child: Text('${entry.value}',
                                      style: AppTheme.textStyle2
                                          .copyWith(fontSize: 16)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
            ],
            // Description
            Text('Description',
                style: AppTheme.textStyle1.copyWith(fontSize: 22)),
            const SizedBox(height: AppTheme.paddingSmall),
            MyBox(
              boxPadding: AppTheme.paddingMedium,
              boxChild: Text(
                task.description,
                style: AppTheme.textStyle2.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingHuge),
            // Action Buttons Row
            Row(
              children: [
                // Delete Task button (poster only, status OPEN)
                if (selectedRole != 'runner' &&
                    task.status == 'OPEN' &&
                    (task.runnerId == null || task.runnerId == 0))
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.urgentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setState(() => isDeleting = true);
                              // Prepare a map with only non-null values
                              final fullJson = task.toJson();
                              final nonNullJson = <String, dynamic>{};
                              fullJson.forEach((key, value) {
                                if (value != null) nonNullJson[key] = value;
                              });
                              if (!nonNullJson.containsKey('task_type')) {
                                if (task.category.name == 'EVENT_STAFFING') {
                                  nonNullJson['task_type'] = 'EVENT';
                                } else {
                                  nonNullJson['task_type'] = 'REGULAR';
                                }
                              }
                              final success = await TaskService()
                                  .deleteTask(task.taskId, nonNullJson);
                              setState(() => isDeleting = false);
                              if (success && mounted) {
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Failed to delete task.')),
                                );
                              }
                            },
                      child: isDeleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Delete Task',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                if (selectedRole != 'runner' &&
                    task.status == 'OPEN' &&
                    (task.runnerId == null || task.runnerId == 0))
                  const SizedBox(width: 12),
                // View Offers/Applications button (poster only, status OPEN)
                if (selectedRole != 'runner' && task.status == 'OPEN')
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        if (isEvent) {
                          // Toggle applicants section
                          if (!showApplicantsSection) {
                            await _fetchApplicants();
                            setState(() {
                              showOffersSection = false;
                            });
                          } else {
                            toggleApplicantsSection();
                          }
                        } else {
                          // Toggle offers section
                          if (!showOffersSection) {
                            setState(() {
                              isLoadingOffers = true;
                              showOffersSection = true;
                              showApplicantsSection = false;
                            });
                            final fetchedOffers = await OfferService()
                                .getOffersForTask(task.taskId);
                            final usernameMap = <int, String>{};
                            for (final offer in fetchedOffers) {
                              final username = await UserService()
                                  .getUsernameById(offer.runnerId.toString());
                              if (username != null) {
                                usernameMap[offer.runnerId] = username;
                              }
                            }
                            setState(() {
                              offers = fetchedOffers;
                              offerRunnerUsernames = usernameMap;
                              isLoadingOffers = false;
                            });
                          } else {
                            toggleOffersSection();
                          }
                        }
                      },
                      child: Text(
                        isEvent ? 'View Applications' : 'View Offers',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                if (selectedRole == 'runner')
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        task.category.name != "EVENT_STAFFING"
                            ?
                            // Open RaiseOfferBottomSheet
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28)),
                                ),
                                builder: (context) => RaiseOfferBottomSheet(
                                  category: widget.task.category.name,
                                  onSubmit: (
                                      {double? amount,
                                      String? comment,
                                      String? resumeLink}) {
                                    onOfferSubmit(
                                        taskId: task.taskId, amount: amount!, comment: comment);
                                  },
                                ),
                              )
                            : showModalBottomSheet(
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
                      child: Text(
                        isEvent ? 'Apply' : 'Raise Offer',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
            if (showOffersSection)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text('Offers', style: AppTheme.headerTextStyle),
                  const SizedBox(height: AppTheme.paddingSmall),
                  MyBox(
                    boxPadding: AppTheme.paddingLarge,
                    boxChild: isLoadingOffers
                        ? const Center(child: CircularProgressIndicator())
                        : (offers == null || offers!.isEmpty)
                            ? const Center(child: Text('No offers found.'))
                            : Column(
                                children: [
                                  for (int i = 0; i < offers!.length; i++) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('${offers![i].amount} EGP',
                                                  style: AppTheme.textStyle1),
                                              if (offers![i].comment != null && offers![i].comment.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Comment: ${offers![i].comment}',
                                                  style: AppTheme.textStyle2,
                                                  softWrap: true,
                                                ),
                                              ],
                                              Text(
                                                  'By: ${offerRunnerUsernames[offers![i].runnerId] ?? '...'}',
                                                  style: AppTheme.textStyle2),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            // Chat button
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.chat, color: Colors.blue),
                                                tooltip: 'Chat with user',
                                                onPressed: () async {
                                                  final runnerId = offers![i].runnerId.toString();
                                                  final runnerName = offerRunnerUsernames[offers![i].runnerId] ?? 'User';
                                                  // Fetch current user info from SharedPreferences
                                                  final prefs = await SharedPreferences.getInstance();
                                                  final currentUserId = prefs.getString('userId') ?? '';
                                                  final currentUsername = prefs.getString('username') ?? 'Me';
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatScreen(
                                                        currentUserId: currentUserId,
                                                        currentUsername: currentUsername,
                                                        otherUserId: runnerId,
                                                        otherUsername: runnerName,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Accept button
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.check, color: Colors.green),
                                                tooltip: 'Accept',
                                                onPressed: isProcessingOffer
                                                    ? null
                                                    : () async {
                                                        setState(() => isProcessingOffer = true);
                                                        final success = await OfferService().acceptOffer(
                                                          taskId: task.taskId,
                                                          offerId: offers![i].offerId,
                                                          taskPosterId: task.taskPoster,
                                                        );
                                                        setState(() => isProcessingOffer = false);
                                                        if (success) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Offer accepted.')),
                                                          );
                                                          // Refresh offers
                                                          final fetchedOffers = await OfferService().getOffersForTask(task.taskId);
                                                          final usernameMap = <int, String>{};
                                                          for (final offer in fetchedOffers) {
                                                            final username = await UserService().getUsernameById(offer.runnerId.toString());
                                                            if (username != null) {
                                                              usernameMap[offer.runnerId] = username;
                                                            }
                                                          }
                                                          setState(() {
                                                            offers = fetchedOffers;
                                                            offerRunnerUsernames = usernameMap;
                                                          });
                                                        }
                                                      },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withOpacity(0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red),
                                                tooltip: 'Decline',
                                                onPressed: isProcessingOffer
                                                    ? null
                                                    : () async {
                                                        setState(() =>
                                                            isProcessingOffer =
                                                                true);
                                                        final success =
                                                            await OfferService()
                                                                .cancelOffer(
                                                                    offers![i]
                                                                        .offerId);
                                                        setState(() =>
                                                            isProcessingOffer =
                                                                false);
                                                        if (success) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Offer declined.')),
                                                          );
                                                          // Refresh offers
                                                          final fetchedOffers =
                                                              await OfferService()
                                                                  .getOffersForTask(
                                                                      task.taskId);
                                                          final usernameMap =
                                                              <int, String>{};
                                                          for (final offer
                                                              in fetchedOffers) {
                                                            final username =
                                                                await UserService()
                                                                    .getUsernameById(offer
                                                                        .runnerId
                                                                        .toString());
                                                            if (username !=
                                                                null) {
                                                              usernameMap[offer
                                                                      .runnerId] =
                                                                  username;
                                                            }
                                                          }
                                                          setState(() {
                                                            offers =
                                                                fetchedOffers;
                                                            offerRunnerUsernames =
                                                                usernameMap;
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Failed to decline offer.')),
                                                          );
                                                        }
                                                      },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (i < offers!.length - 1)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Divider(
                                            height: 1,
                                            color: AppTheme.disabledColor),
                                      ),
                                  ],
                                ],
                              ),
                  ),
                ],
              ),
            // Applicants section for event tasks
            if (showApplicantsSection && isEvent && selectedRole != 'runner')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text('Applicants', style: AppTheme.headerTextStyle),
                  const SizedBox(height: AppTheme.paddingSmall),
                  MyBox(
                    boxPadding: AppTheme.paddingLarge,
                    boxChild: isLoadingApplicants
                        ? const Center(child: CircularProgressIndicator())
                        : (applicants == null || applicants!.isEmpty)
                            ? const Center(child: Text('No applicants found.'))
                            : Column(
                                children: applicants!
                                    .map((app) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(FontAwesomeIcons.user,
                                                  size: 18,
                                                  color: AppTheme.primaryColor),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'By: ${applicantUsernames[app.applicantId] ?? '...'}',
                                                      style:
                                                          AppTheme.textStyle1,
                                                    ),
                                                    if (app.comment!.isNotEmpty)
                                                      Text(
                                                          'Comment: ${app.comment}',
                                                          style: AppTheme
                                                              .textStyle2),
                                                    if (app
                                                        .resumeLink!.isNotEmpty)
                                                      Text(
                                                          'Resume: ${app.resumeLink}',
                                                          style: AppTheme
                                                              .textStyle2),
                                                  ],
                                                ),
                                              ),
                                              // Chat button for applicant
                                              Container(
                                                margin: const EdgeInsets.only(left: 8, top: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.chat, color: Colors.blue),
                                                  tooltip: 'Chat with applicant',
                                                  onPressed: () async {
                                                    final applicantId = app.applicantId.toString();
                                                    final applicantName = applicantUsernames[app.applicantId] ?? 'User';
                                                    // Fetch current user info from SharedPreferences
                                                    final prefs = await SharedPreferences.getInstance();
                                                    final currentUserId = prefs.getString('userId') ?? '';
                                                    final currentUsername = prefs.getString('username') ?? 'Me';
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ChatScreen(
                                                          currentUserId: currentUserId,
                                                          currentUsername: currentUsername,
                                                          otherUserId: applicantId,
                                                          otherUsername: applicantName,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// --- Dispute Bottom Sheet Widget ---
class _DisputeBottomSheet extends StatefulWidget {
  final int taskId;
  final Future<List<int>> Function() getUserIds;
  const _DisputeBottomSheet({required this.taskId, required this.getUserIds});

  @override
  State<_DisputeBottomSheet> createState() => _DisputeBottomSheetState();
}

class _DisputeBottomSheetState extends State<_DisputeBottomSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  late AnimationController _animController;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _reasonController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Raise a Dispute',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _evidenceController,
              decoration: const InputDecoration(
                labelText: 'Evidence URLs (comma separated)',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      setState(() {
                        _isSubmitting = true;
                        _error = null;
                      });
                      final ids = await widget.getUserIds();
                      final reason = _reasonController.text.trim();
                      final evidenceUris = _evidenceController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      if (reason.isEmpty) {
                        setState(() {
                          _error = 'Reason is required.';
                          _isSubmitting = false;
                        });
                        return;
                      }
                      final success = await DisputeService().sendDispute(
                        taskId: widget.taskId,
                        complainantId: ids[0],
                        defendantId: ids[1],
                        reason: reason,
                        evidenceUris: evidenceUris,
                      );
                      setState(() => _isSubmitting = false);
                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dispute submitted successfully!')),
                        );
                      } else {
                        setState(() {
                          _error = 'Failed to submit dispute. Please try again.';
                        });
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Send Request', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
