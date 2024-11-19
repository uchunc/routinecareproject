import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../widgets/journal_entry.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  Map<String, List<String>> journalEntries = {}; // 날짜별 일지 저장
  late TabController controller;

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    // 초기에는 오늘 날짜를 선택한 상태로 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedDate = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
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
      body: TabBarView(
        controller: controller,
        children: [
          // Tab 1: 커뮤니티
          Center(child: Text('홈 페이지')),
          // Tab 2: 홈
          Center(
            child: Column(
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
          ),

          // Tab 3: 프로필
          Center(child: Text('프로필 페이지')),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: controller,
        tabs: const <Tab>[
          Tab(icon: Icon(Icons.group), text: '커뮤니티'),
          Tab(icon: Icon(Icons.home), text: '홈'),
          Tab(icon: Icon(Icons.person), text: '프로필'),
        ],
        labelColor: Colors.deepPurple,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.deepPurple,
      ),
    );
  }
}
