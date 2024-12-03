import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailedProfilePage extends StatefulWidget {
  const DetailedProfilePage({super.key});

  @override
  State<DetailedProfilePage> createState() => _DetailedProfilePageState();
}

class _DetailedProfilePageState extends State<DetailedProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _careerController = TextEditingController();
  final _goalController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _fatPercentageController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _bmiController = TextEditingController();

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
          _careerController.text = userDoc['운동 경력'] ?? '';
          _goalController.text = userDoc['목표'] ?? '';
          _heightController.text = userDoc['키'] ?? '';
          _weightController.text = userDoc['몸무게'] ?? '';
          _fatPercentageController.text = userDoc['체지방률'] ?? '';
          _muscleMassController.text = userDoc['골격근량'] ?? '';
          _bmiController.text = userDoc['BMI'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        '운동 경력': _careerController.text,
        '목표': _goalController.text,
        '키': _heightController.text,
        '몸무게': _weightController.text,
        '체지방률': _fatPercentageController.text,
        '골격근량': _muscleMassController.text,
        'BMI': _bmiController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다!')),
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/profile.jpg'), // 이미지
              ),
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
    int maxLines = 1,
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
                  decoration: InputDecoration.collapsed(hintText: title),
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
