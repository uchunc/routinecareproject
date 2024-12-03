import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 버튼을 통해 이동
        children: [
          // 첫 번째 페이지: 기본정보 입력
          _buildBasicInfoPage(),
          // 두 번째 페이지: 사용자 정보 입력
          _buildUserInfoPage(),
          // 세 번째 페이지: 소셜 계정 연동
          _buildSocialAccountPage(),
          // 네 번째 페이지: 회원가입 완료
          _buildSignupCompletePage(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기본정보 입력',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '이름', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '아이디', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '전화번호', border: OutlineInputBorder()),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFFD9D9D9),
            ),
            child: const Text('다음', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사용자 정보 입력',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            items: ['남성', '여성'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(labelText: '성별', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            items: List.generate(100, (index) => '${index + 1}').map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(labelText: '나이', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '키', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: '몸무게', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'BMI', border: OutlineInputBorder()),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFFD9D9D9),
            ),
            child: const Text('다음', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAccountPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '소셜계정 연동',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '소셜로그인을 연동하면 더 편리하게 운동일기짱을 이용하실 수 있습니다.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Image.asset('assets/google_icon.png', width: 50, height: 50),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: Image.asset('assets/kakao_icon.png', width: 50, height: 50),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: Image.asset('assets/naver_icon.png', width: 50, height: 50),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFFD9D9D9),
            ),
            child: const Text('지금은 하지 않기', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCompletePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '회원가입 완료',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '성공적으로 회원가입을 완료하였습니다.\n이제 운동일기짱과 건강한 삶을 함께하세요!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFFD9D9D9),
            ),
            child: const Text(
              '로그인화면으로 이동',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
