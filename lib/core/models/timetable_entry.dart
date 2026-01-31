class TimetableEntry {
  final String day;
  final int period;
  final String subjectName;
  final String teacherName;
  final String roomName;

  TimetableEntry({
    required this.day,
    required this.period,
    required this.subjectName,
    required this.teacherName,
    required this.roomName,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      day: json['day_of_week'] ?? '',
      period: json['period_no'] ?? 0,
      subjectName: json['subject']?['subject_name'] ?? 'No Subject',
      teacherName: json['teacher']?['teacher_name'] ?? 'Staff',
      roomName: json['room']?['room_name'] ?? 'N/A',
    );
  }
}
