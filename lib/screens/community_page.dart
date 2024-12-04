import 'package:flutter/material.dart';
import 'create_class_page.dart'; // 새로운 페이지 임포트

class CommunityApp extends StatefulWidget {
  const CommunityApp({super.key});

  @override
  _CommunityAppState createState() => _CommunityAppState();
}

class _CommunityAppState extends State<CommunityApp> {
  List<Map<String, String>> classes = []; // 생성된 클래스 목록 (제목과 내용)
  String searchQuery = ''; // 검색어 저장

  void addClass(String className, String classContent) {
    setState(() {
      classes.add({
        'title': className,
        'content': classContent,
        'author': '사용자 이름', // 클래스 생성자의 이름 추가
      }); // 클래스 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    // 검색된 클래스 목록 필터링
    final filteredClasses = classes
        .where((classItem) => classItem['title']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        classItem['content']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('커뮤니티'), // 앱바 제목 추가
      // ),
      body: Column(
        children: [
          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // 검색어 업데이트
                });
              },
              decoration: InputDecoration(
                hintText: '클래스를 검색하세요',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20), // 검색 바와 텍스트 사이의 간격
          // 안내 텍스트
          if (filteredClasses.isEmpty && searchQuery.isNotEmpty) // 필터링된 클래스가 없을 때만 표시
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '검색 결과가 없습니다.\n새로운 클래스를 만들어보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          else if (filteredClasses.isEmpty) // 클래스가 없을 때만 표시
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '아직 나만의 클래스를 만들지 않았나요?\n어서 만들어보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 20), // 안내 텍스트와 클래스 목록 사이의 간격
          // 생성된 클래스 목록
          Expanded(
            child: ListView.builder(
              itemCount: filteredClasses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('P')), // 프로필 아이콘
                  title: Text(filteredClasses[index]['title']!), // 클래스 제목 표시
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filteredClasses[index]['content']!), // 클래스 내용 표시
                      const SizedBox(height: 4), // 간격 추가
                      Text(
                        filteredClasses[index]['author']!, // 클래스 생성자의 이름 표시
                        style: TextStyle(color: Colors.grey), // 색상 변경
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          // 클래스 만들기 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateClassPage(
                      onClassCreated: addClass, // 클래스 생성 시 호출할 함수 전달
                    ),
                  ),
                );
              },
              child: Image.asset('assets/create_class.png', height: 48), // 이미지만 추가
            ),
          ),
        ],
      ),
    );
  }
}
