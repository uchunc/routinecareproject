import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';

class JournalViewer extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, List<String>> journalEntries;
  final ValueChanged<Map<String, List<String>>> onEntryChanged;

  const JournalViewer({
    super.key,
    required this.selectedDate,
    required this.journalEntries,
    required this.onEntryChanged,
  });

  @override
  _JournalViewerState createState() => _JournalViewerState();
}

class _JournalViewerState extends State<JournalViewer> with SingleTickerProviderStateMixin {
  late List<MapEntry<String, String>> allEntries; // 날짜와 이미지 경로를 함께 저장
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _animation;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadAllEntries();

    // 애니메이션 초기화
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.3).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(JournalViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journalEntries != widget.journalEntries) {
      _loadAllEntries();
    }
  }

  // 모든 날짜별 이미지를 로드하여 정렬
  void _loadAllEntries() {
    allEntries = [];
    widget.journalEntries.forEach((date, entries) {
      for (var imagePath in entries) {
        allEntries.add(MapEntry(date, imagePath));
      }
    });

    // 날짜순 정렬
    allEntries.sort((a, b) {
      DateTime dateA = DateTime.parse(a.key);
      DateTime dateB = DateTime.parse(b.key);
      return dateA.compareTo(dateB);
    });

    setState(() {});
  }

  // 이미지를 추가하는 함수
  void addJournalPage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        String dateKey = "${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}";

        // 날짜에 맞는 리스트에 이미지 경로 추가
        widget.journalEntries.putIfAbsent(dateKey, () => []);
        widget.journalEntries[dateKey]!.add(pickedFile.path);

        widget.onEntryChanged(widget.journalEntries);
        _loadAllEntries(); // 데이터 재정렬
      });
    }
  }

  void _showImageDialog(String imagePath) {
    TextEditingController textController = TextEditingController(); // 초기화

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 블러 처리된 배경
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              SingleChildScrollView(  // Column을 SingleChildScrollView로 감쌈
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 이미지 표시
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          height: MediaQuery.of(context).size.height * (1 - _animation.value), // 이미지 크기 조정
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        );
                      },
                    ),
                    // 텍스트 입력 컨테이너 (이미지 밑에 배치)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: textController, // 항상 초기화된 controller 사용
                            decoration: InputDecoration(
                              labelText: "Enter your notes",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onTap: () {
                              _controller.forward(); // 텍스트 필드가 활성화되면 애니메이션 실행
                            },
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // 저장 로직 추가 가능
                              Navigator.of(context).pop();
                            },
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    ),
                    // 닫기 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: allEntries.length + 1, // 이미지 + 추가 버튼
      itemBuilder: (context, index) {
        if (index == allEntries.length) {
          return GestureDetector(
            onTap: addJournalPage,
            child: Icon(Icons.add_a_photo, size: 40),
          );
        }

        final entry = allEntries[index];
        final date = entry.key; // 날짜
        final imagePath = entry.value; // 이미지 경로

        return GestureDetector(
          onDoubleTap: () => _showImageDialog(imagePath),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // 날짜 표시 배경
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    date,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
