import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_class_page.dart'; // 새로운 페이지 임포트

class CommunityApp extends StatefulWidget {
  const CommunityApp({super.key});

  @override
  _CommunityAppState createState() => _CommunityAppState();
}

class _CommunityAppState extends State<CommunityApp> {
  List<Map<String, dynamic>> classes = []; // 생성된 클래스 목록 (제목과 내용)
  String searchQuery = ''; // 검색어 저장
  String? currentUserName; // 현재 로그인한 사용자의 닉네임

  @override
  void initState() {
    super.initState();
    _loadClasses(); // 클래스 불러오기
    _loadCurrentUserName(); // 현재 사용자 닉네임 불러오기
  }

  Future<void> _loadCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentUserName = userDoc['닉네임']; // 현재 사용자 닉네임 저장
        });
      }
    }
  }

  Future<void> _loadClasses() async {
    final classDocs = await FirebaseFirestore.instance.collection('classes').get();
    setState(() {
      classes = classDocs.docs.map((doc) {
        return {
          'id': doc.id, // 문서 ID 추가
          'title': doc['title'],
          'content': doc['content'],
          'author': doc['author'],
        };
      }).toList();
    });
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> classItem) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),  // 모서리 둥글게
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.8, // 넓이 설정
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classItem['title'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('내용: ${classItem['content']}'),
              const SizedBox(height: 10),
              Text('작성자: ${classItem['author']}'),
              const SizedBox(height: 20),
              if (currentUserName != null && classItem['author'] == currentUserName) // 본인 계정 확인
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('classes').doc(classItem['id']).delete();
                    Navigator.pop(context); // 모달 닫기
                    _loadClasses(); // 클래스 목록 새로 고침
                  },
                  child: const Text('클래스 삭제하기'),
                ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    // 검색된 클래스 목록 필터링
    final filteredClasses = classes
        .where((classItem) => classItem['title']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        classItem['content']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return WillPopScope( // 뒤로가기 버튼 동작 제어
      onWillPop: () async {
        Navigator.popAndPushNamed(context, '/main_page'); // main_page로 이동
        return false; // 기본 동작 방지
      },
      child: Scaffold(
        // appBar: AppBar( // appBar 제거
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
                    onTap: () => _showClassDetails(context, filteredClasses[index]), // 클래스 클릭 시 모달 표시
                  );
                },
              ),
            ),
            const Spacer(),
            // 클래스 만들기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateClassPage(
                        onClassCreated: (className, classContent) {
                          // Firestore에 클래스 저장 후 다시 불러오기
                          _loadClasses(); // 클래스 목록 새로 고침
                        },
                      ),
                    ),
                  );
                  _loadClasses(); // 페이지가 돌아올 때 클래스 목록 새로 고침
                },
                child: Image.asset('assets/create_class.png', height: 48), // 이미지만 추가
              ),
            ),
          ],
        ),
      ),
    );
  }
}
