class TeacherTimetableEntry {
  final String day;
  final int period;
  final String subjectName;
  final String branchName;
  final String roomName;

  TeacherTimetableEntry({
    required this.day,
    required this.period,
    required this.subjectName,
    required this.branchName,
    required this.roomName,
  });

  factory TeacherTimetableEntry.fromJson(Map<String, dynamic> json) {
    return TeacherTimetableEntry(
      day: json['day_of_week'],
      period: json['period_no'],
      subjectName: json['subject']['subject_name'],
      branchName: json['subject']['dept_id'].toString(), // or map to CSE/ECE
      roomName: json['room']['room_name'],
    );
  }
}
