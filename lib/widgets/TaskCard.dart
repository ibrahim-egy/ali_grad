import 'package:ali_grad/models/task_model.dart';
import 'package:ali_grad/utils/date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/theme.dart';
import '../screens/task/task_details.dart';
import '../screens/task/post_task_screen.dart';
import 'my_box.dart';

class TaskCard extends StatefulWidget {
  final TaskResponse task;
  final double? distance;
  final String? city;
  final VoidCallback? button2OnPress;
  final bool showActions;
  final bool isButtonDisabled;
  const TaskCard({
    super.key,
    required this.task,
    this.distance,
    this.city,
    this.button2OnPress,
    this.showActions = true,
    this.isButtonDisabled = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String? selectedRole;
  Future<void> fetchSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('role');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSelectedRole();
  }

  @override
  Widget build(BuildContext context) {
    return MyBox(
      boxPadding: AppTheme.paddingLarge,
      boxChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.task.title,
                  style: AppTheme.textStyle1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppTheme.paddingSmall),
              if (selectedRole == "runner")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.task.category.name == "EVENT_STAFFING"
                          ? "${widget.task.fixedPay.toString()}"
                          : "${widget.task.amount.toString()}",
                      style: AppTheme.textStyle0,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("EGP")
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: AppTheme.borderRadius,
                  ),
                  child: Text(
                    widget.task.category.name == "EVENT_STAFFING"
                        ? "Event"
                        : widget.task.category.name,
                    style: AppTheme.textStyle1.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Text(
            widget.task.description,
            style: AppTheme.textStyle2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            children: [
              Icon(FontAwesomeIcons.locationDot,
                  color: AppTheme.textColor1, size: 17),
              SizedBox(width: AppTheme.paddingTiny),
              Text(
                widget.city ??
                    (widget.distance != null
                        ? "${widget.distance!.toStringAsFixed(1)} km"
                        : "Unknown location"),
                style: AppTheme.textStyle2,
              ),
              SizedBox(width: AppTheme.paddingMedium),
              Icon(FontAwesomeIcons.clock,
                  color: AppTheme.textColor1, size: 16),
              SizedBox(width: AppTheme.paddingTiny),
              Text(timeAgoFromString(widget.task.createdDate),
                  style: AppTheme.textStyle2),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showActions) ...[
                Expanded(
                  child: FloatingActionButton.small(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    child: Text(
                      selectedRole == "runner" ? "View details" : "Edit",
                      style: AppTheme.textStyle2.copyWith(
                        fontWeight: FontWeight.w100,
                        color: AppTheme.textColor,
                      ),
                    ),
                    onPressed: () {
                      if (selectedRole == "runner") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TaskDetailsScreen(task: widget.task),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostTaskScreen(taskToEdit: widget.task),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: AppTheme.paddingMedium),
                if (selectedRole == "runner")
                  Expanded(
                    child: FloatingActionButton.small(
                      heroTag: widget.task.taskId,
                      elevation: 0,
                      backgroundColor: widget.isButtonDisabled 
                          ? AppTheme.disabledColor 
                          : AppTheme.primaryColor,
                      child: Text(
                        widget.task.category.name == "EVENT_STAFFING"
                            ? "Apply"
                            : "Raise Offer",
                        style: AppTheme.textStyle1
                            .copyWith(
                              fontWeight: FontWeight.w500,
                              color: widget.isButtonDisabled 
                                  ? AppTheme.textColor1 
                                  : Colors.white,
                            ),
                      ),
                      onPressed: widget.isButtonDisabled ? null : widget.button2OnPress,
                    ),
                  )
                else
                  Expanded(
                    child: FloatingActionButton.small(
                      elevation: 0,
                      backgroundColor: AppTheme.urgentColor.withOpacity(0.15),
                      child: Text(
                        "Delete",
                        style: AppTheme.textStyle1.copyWith(
                          color: AppTheme.urgentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: widget.button2OnPress,
                    ),
                  ),
              ] else ...[
                Expanded(
                  child: FloatingActionButton.small(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    child: Text(
                      "View details",
                      style: AppTheme.textStyle2.copyWith(
                        fontWeight: FontWeight.w100,
                        color: AppTheme.textColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailsScreen(task: widget.task),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
