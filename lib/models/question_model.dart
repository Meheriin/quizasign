class Question {
  final int id;
  final String question;
  final List<String> options;
  final int answerIndex;
  final int mark;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.mark,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      question: json['question'],
      options: List<String>.from(json['options']),
      answerIndex: json['answerIndex'],
      mark: json['mark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answerIndex': answerIndex,
      'mark': mark,
    };
  }
}
