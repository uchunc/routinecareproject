import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DetailedProfilePage extends StatefulWidget {
  const DetailedProfilePage({super.key});

  @override
  State<DetailedProfilePage> createState() => _DetailedProfilePageState();
}

class _DetailedProfilePageState extends State<DetailedProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  final _nicknameController = TextEditingController();
  final _careerController = TextEditingController();
  final _goalController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _fatPercentageController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _bmiController = TextEditingController();
  final _bioController = TextEditingController(); // 메신저 추가

  File? _profileImage;
  String? _profileImageUrl;

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
          _nicknameController.text = userDoc['닉네임'] ?? '';
          _careerController.text = userDoc['운동 경력'] ?? '';
          _goalController.text = userDoc['목표'] ?? '';
          _heightController.text = userDoc['키'] ?? '';
          _weightController.text = userDoc['몸무게'] ?? '';
          _fatPercentageController.text = userDoc['체지방률'] ?? '';
          _muscleMassController.text = userDoc['골격근량'] ?? '';
          _bmiController.text = userDoc['BMI'] ?? '';
          _bioController.text = userDoc['메신저'] ?? ''; // 본인 소개 로드
          _profileImageUrl = userDoc['프로필 사진'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        '닉네임': _nicknameController.text,
        '운동 경력': _careerController.text,
        '목표': _goalController.text,
        '키': _heightController.text,
        '몸무게': _weightController.text,
        '체지방률': _fatPercentageController.text,
        '골격근량': _muscleMassController.text,
        'BMI': _bmiController.text,
        '메신저': _bioController.text, // 메신저 저장
        '프로필 사진': _profileImageUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다!')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      setState(() {
        _profileImage = file;
      });

      // Firebase Storage 경로
      final storageRef = _firebaseStorage
          .ref()
          .child('profile_images/${user.uid}/profile.jpg');

      // 업로드
      await storageRef.putFile(file);

      // 다운로드 URL 가져오기
      final downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadUrl;
      });

      // Firestore에 URL 저장
      await _firestore.collection('users').doc(user.uid).update({
        '프로필 사진': downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 사진이 업로드되었습니다!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 정보'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveUserData,
            child: const Text('저장', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 이미지 섹션
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : const AssetImage('assets/profile.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickAndUploadImage,
                    ),
                  ),
                ],
              ),
            ),
            // 닉네임 설정
            _buildEditableContainer(
              title: '닉네임',
              controller: _nicknameController,
            ),
            // 메신저 섹션
            _buildEditableContainer(
              title: '카카오, 인스타 id',
              controller: _bioController,
              maxLines: 1,
              validationMessage: '20자 이하로 입력해야 합니다.',
              maxLength: 20,
            ),
            // 운동 경력
            _buildEditableContainer(
              title: '운동 경력',
              controller: _careerController,
              maxLines: 5,
            ),
            // 신체 정보
            _buildEditableContainer(
              title: '신체 정보',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(label: '키 (cm)', controller: _heightController),
                  _buildTextField(label: '몸무게 (kg)', controller: _weightController),
                  _buildTextField(label: '체지방률 (%)', controller: _fatPercentageController),
                  _buildTextField(label: '골격근량 (kg)', controller: _muscleMassController),
                  _buildTextField(label: 'BMI', controller: _bmiController),
                ],
              ),
            ),
            // 목표
            _buildEditableContainer(
              title: '목표',
              controller: _goalController,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableContainer({
    required String title,
    TextEditingController? controller,
    Widget? child,
    String? validationMessage,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            child ??
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  maxLength: maxLength, // 최대 길이 설정
                  decoration: InputDecoration(
                    counterText: '', // 글자 수 제한 표시 제거
                    hintText: title,
                    errorText: validationMessage != null &&
                        controller!.text.length > maxLength!
                        ? validationMessage
                        : null,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}