import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../widgets/journal_entry.dart';
import 'community_page.dart'; // 커뮤니티 페이지
import 'profile_page.dart'; // 프로필 페이지

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
    controller = TabController(length: 3, vsync: this, initialIndex: 1);
    controller.addListener(() {
      setState(() {}); // 탭 변경 시 상태 업데이트
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  AppBar buildAppBar() {
    if (controller.index == 1) {
      // 홈 탭의 AppBar
      return AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  selectedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                  );
                });
              },
            ),
            Text('${selectedDate.year}년 ${selectedDate.month}월'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  selectedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      );
    } else {
      // 다른 탭의 AppBar
      return AppBar(
        title: Text(controller.index == 0 ? '커뮤니티' : '프로필'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: TabBarView(
        controller: controller,
        children: [
          // Tab 1: 커뮤니티
          CommunityApp(), // 커뮤니티 페이지 불러오기
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
                        journalEntries[formatDate(selectedDate)] =
                            updatedEntries;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tab 3: 프로필
          ProfileApp(), // 프로필 페이지 불러오기
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
