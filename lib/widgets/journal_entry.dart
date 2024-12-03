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
    int newIndex = currentEntries.length;

    // 이미지 선택 전에 imagePaths와 controllers 리스트에 null을 추가하여 빈 값이 되지 않도록 함
    setState(() {
      imagePaths.add(null);
      controllers.add(TextEditingController());
    });

    await _pickImage(newIndex); // 이미지 선택 후 추가

    setState(() {
      currentEntries.add(""); // 빈 일지 텍스트 추가
      widget.onEntryChanged(currentEntries);
    });
  }

  Future<void> _pickImage(int index) async {
    // 이미지 선택 함수에서 인덱스가 유효한지 확인
    if (index >= imagePaths.length) {
      return; // 유효하지 않으면 함수 종료
    }
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePaths[index] = pickedFile.path; // 선택된 이미지 경로 저장
      });
    }
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
                if (imagePaths[index] != null && imagePaths[index]!.isNotEmpty)
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
