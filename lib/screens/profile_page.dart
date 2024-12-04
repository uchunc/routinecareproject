import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'detailed_profile_page.dart';

class ProfileApp extends StatefulWidget {
  const ProfileApp({super.key});

  @override
  State<ProfileApp> createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _nickname = "닉네임을 설정하세요"; // 기본값
  String _profileImageUrl = ""; // 기본값
  String _bio = "소개를 추가하세요"; // 본인 소개 기본값

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nickname = userDoc['닉네임'] ?? "닉네임을 설정하세요";
          _profileImageUrl = userDoc['프로필 사진'] ?? "";
          _bio = userDoc['본인 소개'] ?? "소개를 추가하세요"; // 본인 소개 데이터 로드
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 정보
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                        : const AssetImage('assets/profile.jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nickname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _bio, // 본인 소개 표시
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailedProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 프리미엄 멤버십
            Container(
              width: double.infinity, // 화면 너비에 꽉 차도록 설정
              color: Colors.deepPurple[100],
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Premium Membership\nUpgrade for more features',
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 계정 섹션
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailedProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // 비밀번호 변경 페이지로 이동
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // 알림 설정 페이지로 이동
              },
            ),
            const SizedBox(height: 16),
            // 기타 섹션
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'More',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rate & Review'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // 평가 및 리뷰 페이지로 이동
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // 도움말 페이지로 이동
              },
            ),
            const SizedBox(height: 16),
            // 로그아웃
            Center(
              child: TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut(); // Firebase 로그아웃
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  } catch (e) {
                    print("로그아웃 실패: $e");
                  }
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // 스크롤 가능하도록 여백 추가
          ],
        ),
      ),
    );
  }
}
