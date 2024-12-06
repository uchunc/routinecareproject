class JournalEntry {
  final int? id; // 데이터베이스에서 생성된 고유 ID
  final String date; // 작성 날짜
  final String imagePath; // 이미지 파일 경로
  final String? text;

  JournalEntry({
    this.id,
    required this.date,
    required this.imagePath,
    required this.text,
  });

  // 데이터베이스에 저장할 수 있도록 Map 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'imagePath': imagePath,
      'text': text,
    };
  }

  // 데이터베이스에서 읽어온 데이터를 모델 객체로 변환
  static JournalEntry fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      date: map['date'],
      imagePath: map['imagePath'],
      text: map['text'],
    );
  }
}
