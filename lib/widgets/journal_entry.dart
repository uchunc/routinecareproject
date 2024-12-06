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

class _JournalViewerState extends State<JournalViewer>
    with SingleTickerProviderStateMixin {
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
    _animation = Tween<double>(begin: 0.0, end: 0.3)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadEntries();
    }
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void _loadEntries() {
    String dateKey = formatDate(widget.selectedDate);
    setState(() {
      currentEntries = widget.journalEntries[dateKey] ?? [];
      controllers = List.generate(
        currentEntries.length,
        (index) => TextEditingController(
          text: currentEntries[index]['content'] ?? "",
        ),
      );
    });
  }

  Future<void> addJournalPage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newEntry = {
        'content': '',
        'imagePath': pickedFile.path,
      };

      setState(() {
        // 날짜를 두 자릿수 형식으로 포맷
        String dateKey =
            "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";

        // 날짜에 맞는 리스트에 이미지 경로 추가
        widget.journalEntries.putIfAbsent(dateKey, () => []);
        widget.journalEntries[dateKey]!.add(pickedFile.path);

        widget.onEntryChanged(widget.journalEntries);

        // 이미지가 추가된 후 모든 항목을 로드하고 날짜별로 정렬
        _loadAllEntries(); // 이 메서드는 날짜별로 정렬된 이미지를 로드하고 UI를 갱신
      });
    }
  }

  void _loadAllEntries() {
    allEntries = [];
    widget.journalEntries.forEach((date, entries) {
      for (var imagePath in entries) {
        allEntries.add(MapEntry(date, imagePath));
      }
    });

    // 최신 날짜가 가장 앞에 오도록 역순 정렬
    allEntries.sort((a, b) {
      DateTime dateA = DateTime.parse(a.key);
      DateTime dateB = DateTime.parse(b.key);
      return dateB.compareTo(dateA); // 역순 정렬
    });

    // setState 호출하여 UI 갱신
    setState(() {});
  }

  void _showImageDialog(String imagePath) {
    _textController.clear(); // 텍스트 필드 초기화

    // 텍스트 색상을 결정 (예: 흰색, 회색, 검정색 등)
    final textColor = Colors.white; // 여기에 동적으로 텍스트 색을 지정할 수 있습니다.

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
              // 배경 블러 처리
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                    // color: Colors.black.withOpacity(0.5),
                    ),
              ),
              SingleChildScrollView(
                // Column을 SingleChildScrollView로 감쌈
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 이미지 표시
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return FutureBuilder<Image>(
                          future: _loadImage(imagePath), // 이미지 로드
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (!snapshot.hasData) {
                              return Container();
                            }

                            final image = snapshot.data!;
                            final width =
                                image.width?.toDouble() ?? 100.0; // 기본값 100.0
                            final height =
                                image.height?.toDouble() ?? 100.0; // 기본값 100.0

                            final aspectRatio = height / width;

                            return Container(
                              width: MediaQuery.of(context).size.width * 1,
                              height: MediaQuery.of(context).size.width *
                                  0.8 *
                                  aspectRatio, // 비율에 맞는 높이
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: textColor, // 텍스트 색상으로 테두리 색상 설정
                                  width: 20, // 테두리 두께
                                ),
                                // borderRadius: BorderRadius.circular(10),  // 테두리 모서리 둥글기
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain, // 이미지를 비율에 맞게 크기를 조정
                                child: Image.file(
                                  File(imagePath),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // 텍스트 입력 컨테이너 (이미지 밑에 배치)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: textColor, // 텍스트 색상에 맞는 배경 색상
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          // 텍스트 필드
                          TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              labelText: "일지",
                              labelStyle:
                                  TextStyle(color: Colors.black), // 라벨 텍스트 색상
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.black), // 텍스트 색상
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
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
                  ],
                ),
              ),
              // X 아이콘을 왼쪽 상단에 배치
              Positioned(
                top: 10,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
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
        crossAxisCount: 3, // 3열로 배치
        crossAxisSpacing: 0.0, // 열 간 간격 0
        mainAxisSpacing: 0.0, // 행 간 간격 0
        childAspectRatio: 1.0, // 자식 항목의 비율을 정사각형으로 설정
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
