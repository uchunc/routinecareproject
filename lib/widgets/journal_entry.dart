import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
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

  late FocusNode _textFieldFocusNode; // FocusNode 추가
  TextEditingController _textController = TextEditingController(); // 텍스트 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadAllEntries();

    // FocusNode 초기화
    _textFieldFocusNode = FocusNode();

    // 애니메이션 초기화
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.3).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        _controller.forward(); // 텍스트 필드가 활성화되면 애니메이션 실행
      } else {
        _controller.reverse(); // 텍스트 필드가 비활성화되면 이미지 크기 복원
      }
    });
  }

  @override
  void didUpdateWidget(JournalViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journalEntries != widget.journalEntries) {
      _loadAllEntries();
    }
  }

  void addJournalPage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;

      // MainPage 스타일의 다이얼로그 생성
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.all(10),
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 블러 처리
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(),
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 선택한 이미지 표시
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // 텍스트 입력 필드
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "일지를 작성하세요...",
                            border: InputBorder.none,
                          ),
                          maxLines: 5,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Save 버튼
                      ElevatedButton(
                        onPressed: () async {
                          // SQLite에 데이터 저장
                          String dateKey = "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";
                          String journalText = _textController.text;

                          await DatabaseHelper().insertJournal(dateKey, imagePath, journalText);

                          // UI 업데이트
                          setState(() {
                            widget.journalEntries.putIfAbsent(dateKey, () => []);
                            widget.journalEntries[dateKey]!.add(imagePath);
                            widget.onEntryChanged(widget.journalEntries);
                          });

                          // 데이터 새로고침 및 다이얼로그 닫기
                          _loadAllEntries();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 닫기 아이콘
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white),
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

  void _loadAllEntries() async {
    allEntries = [];

    // SQLite에서 데이터 로드
    List<Map<String, dynamic>> entries = await DatabaseHelper().getJournalsByDate(
        "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}"
    );

    // SQLite 데이터를 allEntries에 추가
    for (var entry in entries) {
      allEntries.add(MapEntry(entry['date'], entry['imagePath']));
    }

    // 최신 날짜가 가장 앞에 오도록 역순 정렬
    allEntries.sort((a, b) {
      DateTime dateA = DateTime.parse(a.key);
      DateTime dateB = DateTime.parse(b.key);
      return dateB.compareTo(dateA); // 역순 정렬
    });

    // UI 갱신
    setState(() {});
  }



  void _showImageDialog(String imagePath) async {
    // SQLite에서 일지를 가져옴
    final journalEntry = await DatabaseHelper().getJournalByImagePath(imagePath);

    // 저장된 일지 텍스트 가져오기
    final journalText = journalEntry != null ? journalEntry['journal'] : '';

    // 다이얼로그 표시
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
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 선택한 이미지 표시
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 저장된 일지 표시
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        journalText.isNotEmpty ? journalText : "일지가 없습니다.",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 지우기 버튼
                    ElevatedButton(
                      onPressed: () async {
                        // 데이터베이스에서 삭제
                        await DatabaseHelper().deleteJournalByImagePath(imagePath);

                        // UI 업데이트
                        setState(() {
                          allEntries.removeWhere((entry) => entry.value == imagePath);
                        });

                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Text(
                          "지우기",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  // 이미지를 로드하는 Future 메소드
  Future<Image> _loadImage(String imagePath) async {
    final image = Image.file(File(imagePath));
    await precacheImage(image.image, context); // 이미지를 미리 로드
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,               // 3열로 배치
        crossAxisSpacing: 0.0,           // 열 간 간격 0
        mainAxisSpacing: 0.0,            // 행 간 간격 0
        childAspectRatio: 1.0,           // 자식 항목의 비율을 정사각형으로 설정
      ),
      itemCount: allEntries.length + 1, // 이미지 + 추가 버튼
      itemBuilder: (context, index) {
        if (index == allEntries.length) {
          // + 아이콘 추가
          return GestureDetector(
            onTap: addJournalPage,
            child: Container(
              color: Colors.grey[200],
              child: Icon(Icons.add_a_photo, size: 40),
            ),
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
