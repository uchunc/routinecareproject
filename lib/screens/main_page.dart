import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../widgets/journal_entry.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, List<String>> journalEntries = {}; // 날짜별 일지 저장

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  @override
  void initState() {
    super.initState();
    // 초기에는 오늘 날짜를 선택한 상태로 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedDate = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  selectedDate =
                      DateTime(selectedDate.year, selectedDate.month - 1);
                });
              },
            ),
            Text('${selectedDate.year}년 ${selectedDate.month}월'),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  selectedDate =
                      DateTime(selectedDate.year, selectedDate.month + 1);
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Calendar(
            date: selectedDate,
            onDateSelected: (DateTime date) {
              setState(() {
                selectedDate = date;
              });
            },
            journalEntries: journalEntries,
          ),
          Expanded(
            child: JournalViewer(
              selectedDate: selectedDate,
              journalEntries: journalEntries,
              onEntryChanged: (updatedEntries) {
                setState(() {
                  journalEntries[formatDate(selectedDate)] = updatedEntries;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
