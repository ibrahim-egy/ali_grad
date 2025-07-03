class EventApplication {
  final int taskId;
  final int applicantId;
  final String comment;
  final String resumeLink;

  EventApplication({
    required this.taskId,
    required this.applicantId,
    required this.comment,
    required this.resumeLink,
  });

  factory EventApplication.fromJson(Map<String, dynamic> json) {
    return EventApplication(
      taskId: json['taskId'],
      applicantId: json['applicantId'],
      comment: json['comment'],
      resumeLink: json['resumeLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'applicantId': applicantId,
      'comment': comment,
      'resumeLink': resumeLink,
    };
  }
}

enum ApplicationStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  CANCELLED,
}
