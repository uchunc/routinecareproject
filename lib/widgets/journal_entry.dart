import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class JournalViewer extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, List<String>> journalEntries;
  final ValueChanged<List<String>> onEntryChanged;

  const JournalViewer({
    super.key,
    required this.selectedDate,
    required this.journalEntries,
    required this.onEntryChanged,
  });

  @override
  _JournalViewerState createState() => _JournalViewerState();
}

class _JournalViewerState extends State<JournalViewer> {
  late List<String> currentEntries;
  late List<String?> imagePaths; // 이미지 경로를 null로 초기화
  late List<TextEditingController> controllers; // 텍스트 컨트롤러 추가
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEntries();
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
      imagePaths = List.generate(
          currentEntries.length, (index) => null); // 각 일지에 대해 이미지 경로를 null로 초기화
      controllers = List.generate(
          currentEntries.length,
          (index) => TextEditingController(
              text: currentEntries[index])); // 텍스트 컨트롤러 추가
    });
  }

  void addJournalPage() async {
    // 이미지 경로 추가를 위해 리스트 확장
    imagePaths.add(null);

    final bool imageAdded = await _pickImage(imagePaths.length - 1);

    if (imageAdded) {
      // 이미지가 성공적으로 추가된 경우에만 데이터 추가
      setState(() {
        currentEntries.add(""); // 빈 텍스트로 초기화
        controllers.add(TextEditingController()); // 텍스트 컨트롤러 추가
        widget.onEntryChanged(currentEntries); // 상태 업데이트
      });
    } else {
      // 이미지 선택이 취소된 경우 리스트 정리
      setState(() {
        imagePaths.removeLast(); // 마지막으로 추가된 빈 경로 제거
      });
    }
  }

  Future<bool> _pickImage(int index) async {
    if (index < 0 || index >= imagePaths.length) {
      return false; // 유효하지 않은 인덱스라면 중단
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePaths[index] = pickedFile.path; // 이미지 경로 설정
      });
      return true; // 이미지 선택 성공
    }

    return false; // 이미지 선택 취소
  }

  void deleteJournalPage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("페이지를 삭제하겠습니까?"),
        actions: [
          TextButton(
            child: Text("취소"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("삭제"),
            onPressed: () {
              setState(() {
                currentEntries.removeAt(index);
                imagePaths.removeAt(index); // 해당 일지의 이미지도 삭제
                controllers.removeAt(index); // 텍스트 컨트롤러도 삭제
                widget.onEntryChanged(currentEntries);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: currentEntries.length + 1, // +1 to include the Add Page button
      itemBuilder: (context, index) {
        if (index == currentEntries.length) {
          return Center(
            child: IconButton(
              icon: Icon(Icons.add_a_photo, size: 50),
              onPressed: addJournalPage,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (index < imagePaths.length &&
                    imagePaths[index] != null &&
                    imagePaths[index]!.isNotEmpty)
                  Image.file(
                    File(imagePaths[index]!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    onChanged: (value) {
                      setState(() {
                        currentEntries[index] = value;
                        widget.onEntryChanged(currentEntries);
                      });
                    },
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '일지 ${index + 1}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => deleteJournalPage(index),
                  child: const Text("페이지 삭제"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
