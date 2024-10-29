class JournalEntry {
  String description; // Content of the journal entry
  DateTime date;      
  final int userId;

  JournalEntry({
    required this.description,
    required this.date,
    required this.userId,
  });

  // Factory method to create a JournalEntry from JSON
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      description: json['description'] as String,
      date: DateTime(
        json['date'][0], // Year
        json['date'][1], // Month
        json['date'][2], // Day
        json['date'][3],//hour
        json['date'][4],//minute
      ),
      userId: json['userId'] as int,
    );
  }

  // Method to convert a JournalEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date.toIso8601String(), 
      'userId': userId,
    };
  }
}
