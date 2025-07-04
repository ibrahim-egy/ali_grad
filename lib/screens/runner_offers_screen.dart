import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/offer_model.dart';
import '../models/task_model.dart';
import '../services/offer_service.dart';
import '../services/task_service.dart';
import '../services/event_application_service.dart';
import '../models/event_application_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RunnerOffersScreen extends StatefulWidget {
  const RunnerOffersScreen({Key? key}) : super(key: key);

  @override
  State<RunnerOffersScreen> createState() => _RunnerOffersScreenState();
}

class _RunnerOffersScreenState extends State<RunnerOffersScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<OfferResponse>? offers;
  Map<int, String> taskTitles = {};
  bool isLoading = true;

  List<TaskResponse>? eventApplications;
  bool isLoadingApplications = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    fetchOffers();
    fetchEventApplications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchOffers();
      fetchEventApplications();
    }
  }

  Future<void> fetchOffers() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final runnerId = prefs.getString('userId');
    if (runnerId == null) {
      setState(() {
        offers = [];
        isLoading = false;
      });
      return;
    }
    final fetchedOffers =
        await OfferService().getOffersByRunner(int.parse(runnerId));
    final Map<int, String> titles = {};
    for (final offer in fetchedOffers) {
      final task = await TaskService().fetchRegularTaskById(offer.taskId);
      if (task != null) {
        titles[offer.taskId] = task.title;
      } else {
        titles[offer.taskId] = 'Unknown Task';
      }
    }
    setState(() {
      offers = fetchedOffers;
      taskTitles = titles;
      isLoading = false;
    });
  }

  Future<void> fetchEventApplications() async {
    setState(() => isLoadingApplications = true);
    final prefs = await SharedPreferences.getInstance();
    final runnerId = prefs.getString('userId');
    if (runnerId == null) {
      setState(() {
        eventApplications = [];
        isLoadingApplications = false;
      });
      return;
    }
    final fetchedApplications =
        await EventApplicationService().getTasksForRunner(int.parse(runnerId));
    setState(() {
      eventApplications = fetchedApplications;
      isLoadingApplications = false;
    });
  }

  Future<void> cancelOffer(int offerId) async {
    final success = await OfferService().cancelOffer(offerId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer cancelled successfully.')),
      );
      fetchOffers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel offer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers & Applications'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/runner-home',
              (route) => false,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Offers'),
              Tab(text: 'Event Applications'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        body: TabBarView(
          children: [
            // Tab 1: Offers
            RefreshIndicator(
              onRefresh: fetchOffers,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (offers == null || offers!.isEmpty)
                      ? const Center(child: Text('No offers found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppTheme.paddingLarge),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppTheme.paddingMedium),
                          itemCount: offers!.length,
                          itemBuilder: (context, i) {
                            final offer = offers![i];
                            final title = taskTitles[offer.taskId] ?? '...';
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.paddingLarge),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title,
                                        style: AppTheme.headerTextStyle
                                            .copyWith(fontSize: 20)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money,
                                            color: AppTheme.primaryColor,
                                            size: 20),
                                        const SizedBox(width: 6),
                                        Text('Amount: ${offer.amount} EGP',
                                            style: AppTheme.textStyle1
                                                .copyWith(fontSize: 16)),
                                      ],
                                    ),
                                    if (offer.comment.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.comment,
                                              color: AppTheme.textColor1,
                                              size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                              child: Text(
                                                  'Comment: ${offer.comment}',
                                                  style: AppTheme.textStyle2)),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: AppTheme.textColor1,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                            'Status: ${offer.status.toString().split('.').last}',
                                            style: AppTheme.textStyle2),
                                        const Spacer(),
                                        if (offer.status == OfferStatus.PENDING)
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.urgentColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () =>
                                                cancelOffer(offer.offerId),
                                            icon: const Icon(Icons.close,
                                                color: Colors.white, size: 18),
                                            label: const Text('Cancel Offer',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Tab 2: Event Applications
            RefreshIndicator(
              onRefresh: fetchEventApplications,
              child: isLoadingApplications
                  ? const Center(child: CircularProgressIndicator())
                  : (eventApplications == null || eventApplications!.isEmpty)
                      ? const Center(
                          child: Text('No event applications found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppTheme.paddingLarge),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppTheme.paddingMedium),
                          itemCount: eventApplications!.length,
                          itemBuilder: (context, i) {
                            final task = eventApplications![i];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                              color: Colors.white,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.paddingLarge),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title,
                                        style: AppTheme.headerTextStyle
                                            .copyWith(fontSize: 20)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.event,
                                            color: AppTheme.primaryColor,
                                            size: 20),
                                        const SizedBox(width: 6),
                                        Text('Event Task',
                                            style: AppTheme.textStyle1
                                                .copyWith(fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      task.description,
                                      style: AppTheme.textStyle2,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: AppTheme.textColor1,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                            'Status: Accepted', // You can update this if you fetch application status
                                            style: AppTheme.textStyle2),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
