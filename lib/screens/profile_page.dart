import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'detailed_profile_page.dart';

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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
                    backgroundImage: AssetImage('assets/profile.jpg'), // 프로필 이미지
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '맨몸 운동 이준명',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'instagram: zakta__//',
                        style: TextStyle(
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
                      // 프로필 상세 페이지 이동
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
