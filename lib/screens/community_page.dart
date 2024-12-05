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
          'profile_image': doc['profile_image'],
          'bio' : doc['bio'],
          'subscription_count' : doc['subscription_count'],
          'career': doc['career'],
        };
      }).toList();
    });
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> classItem) {
  bool isSubscribed = classItem['is_subscribed'] ?? false; // 초기 구독 상태
  int subscriptionCount = classItem['subscription_count'] ?? 0;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: classItem['profile_image'] != null
                            ? NetworkImage(classItem['profile_image'])
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classItem['author'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '소개: ${classItem['bio'] ?? '소개가 없습니다.'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '경력: ${classItem['career'] ?? '경력이 없습니다.'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        classItem['title'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '구독: $subscriptionCount',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('${classItem['content']}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        if (isSubscribed) {
                          subscriptionCount--;
                          isSubscribed = false;
                        } else {
                          subscriptionCount++;
                          isSubscribed = true;
                        }

                        setState(() {}); // StatefulBuilder 내 상태 갱신

                        await FirebaseFirestore.instance.collection('classes').doc(classItem['id']).update({
                          'subscription_count': subscriptionCount,
                          'is_subscribed': isSubscribed, // Firestore에 구독 상태 저장
                        });
                      }
                    },
                    child: Text(isSubscribed ? '구독 취소' : '구독하기'),
                  ),
                  const SizedBox(height: 20),
                  if (currentUserName != null && classItem['author'] == currentUserName)
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('classes').doc(classItem['id']).delete();
                        Navigator.pop(context);
                        _loadClasses(); // 클래스 목록 새로고침
                      },
                      child: const Text('클래스 삭제하기'),
                    ),
                ],
              ),
            ),
          );
        },
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
                    leading: filteredClasses[index]['profile_image'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(filteredClasses[index]['profile_image']),
                          )
                        : CircleAvatar(child: Text('기본')), // 프로필 아이콘
                    title: Text(filteredClasses[index]['title']!), // 클래스 제목 표시
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 제목과 구독 수를 양쪽 끝으로 배치
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filteredClasses[index]['content']!, // 클래스 내용 표시
                              maxLines: 1, // 최대 1줄로 제한
                              overflow: TextOverflow.ellipsis, // 넘치는 내용은 '...'으로 표시
                            ),
                            const SizedBox(height: 4), // 간격 추가
                            Text(
                              filteredClasses[index]['author']!, // 클래스 생성자의 이름 표시
                              style: TextStyle(color: Colors.grey), // 색상 변경
                            ),
                          ],
                        ),
                        Text(
                          '구독: ${filteredClasses[index]['subscription_count']}', // 구독 수 표시
                          style: TextStyle(color: Colors.grey), // 색상 변경
                        ),
                      ],
                    ),
                    onTap: () => _showClassDetails(context, filteredClasses[index]), // 클래스 클릭 시 모달 표시
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
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
