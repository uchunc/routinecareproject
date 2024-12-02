import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Google 로그인 메서드 추가
  Future<User?> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      // 로그인 성공 시 MainPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );

      print("Google 로그인 성공: ${userCredential.user?.displayName}");
      return userCredential.user;
    } catch (e) {
      print("Google 로그인 실패: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  '운동일기짱',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                // 아이디 입력 필드
                const TextField(
                  decoration: InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // 비밀번호 입력 필드
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                // 로그인 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFFD9D9D9),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 소셜 로그인 글자
                const Text(
                  '소셜로그인',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // 소셜 로그인 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: IconButton(
                        onPressed: () async {
                          final User? user = await _signInWithGoogle(context);
                          if (user != null) {
                            print("Google 로그인 성공: ${user.displayName}");
                            // 로그인 성공 후 추가 작업
                          }
                        },
                        icon: Image.asset(
                          'assets/google_icon.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: IconButton(
                        onPressed: () {
                          print("Kakao 로그인 준비중");
                        },
                        icon: Image.asset(
                          'assets/kakao_icon.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: IconButton(
                        onPressed: () {
                          print("Naver 로그인 준비중");
                        },
                        icon: Image.asset(
                          'assets/naver_icon.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '또는',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // 회원가입 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFFD9D9D9),
                  ),
                  child: const Text(
                    '회원가입 하기',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
