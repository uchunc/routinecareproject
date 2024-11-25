import 'package:flutter/material.dart';

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

  void _loadEntries() {
    // 선택된 날짜의 일지 페이지를 로드
    String dateKey = formatDate(widget.selectedDate);
    setState(() {
      currentEntries = widget.journalEntries[dateKey] ?? [];
    });
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void addJournalPage() {
    setState(() {
      currentEntries.add("");
      widget.onEntryChanged(currentEntries);
    });
  }

  void deleteJournalPage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("페이지를 삭제하겠습니까?"),
        actions: [
          TextButton(
            child: const Text("취소"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("삭제"),
            onPressed: () {
              setState(() {
                currentEntries.removeAt(index);
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
          // 마지막 페이지는 + 버튼
          return Center(
            child: IconButton(
              icon: const Icon(Icons.add, size: 50),
              onPressed: addJournalPage,
            ),
          );
        } else {
          // 일지 작성 페이지
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: currentEntries[index]),
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
