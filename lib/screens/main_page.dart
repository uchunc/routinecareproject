import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지
import '../widgets/calendar.dart';
import '../widgets/journal_entry.dart';
import 'community_page.dart'; // 커뮤니티 페이지
import 'profile_page.dart'; // 프로필 페이지

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
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
    // 선택된 날짜의 데이터를 필터링
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    Map<String, List<String>> filteredJournalEntries = {
      formattedDate: journalEntries[formattedDate] ?? [],
    };

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                // Tab 1: 커뮤니티
                CommunityApp(),
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
                      Container(
                        width: double.infinity,
                        height: 53,
                        color: Colors.black12, // 바의 배경색
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                          ),
                        ),
                      ),
                      Expanded(
                        child: JournalViewer(
                          selectedDate: selectedDate,
                          journalEntries: filteredJournalEntries, // 필터링된 데이터 전달
                          onEntryChanged: (updatedJournalEntries) {
                            setState(() {
                              journalEntries = updatedJournalEntries; // 전체 데이터 업데이트
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab 3: 프로필
                ProfileApp(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.index,
        onTap: (index) {
          setState(() {
            controller.index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }


}
