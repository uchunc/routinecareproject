import 'package:flutter/material.dart';

class CreateClassPage extends StatelessWidget {
  final Function(String, String) onClassCreated; // 제목과 내용을 전달할 함수

  const CreateClassPage({super.key, required this.onClassCreated});

  @override
  Widget build(BuildContext context) {
    final classNameController = TextEditingController(); // 클래스명 입력 필드 컨트롤러
    final classContentController = TextEditingController(); // 클래스 내용 입력 필드 컨트롤러

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티 생성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('클래스 제목을 입력하세요', style: TextStyle(fontSize: 16)),
            TextField(
              controller: classNameController,
              decoration: InputDecoration(hintText: '운동 클래스 제목'),
            ),
            const SizedBox(height: 20),
            const Text('클래스 내용을 입력하세요', style: TextStyle(fontSize: 16)),
            TextField(
              controller: classContentController,
              decoration: InputDecoration(hintText: '클래스 내용'),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () {
                  // 클래스 생성 시 호출
                  onClassCreated(classNameController.text, classContentController.text);
                  Navigator.pop(context); // 페이지 닫기
                },
                child: Image.asset('assets/create_class.png', height: 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
