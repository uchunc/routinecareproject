import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class JournalViewer extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, List<Map<String, dynamic>>> journalEntries;
  final ValueChanged<List<Map<String, dynamic>>> onEntryChanged;

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
  late List<Map<String, dynamic>> currentEntries;
  late List<TextEditingController> controllers;
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
        currentEntries.add(newEntry);
        controllers.add(TextEditingController());
        widget.onEntryChanged(currentEntries);
      });
    }
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
                controllers.removeAt(index);
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
              icon: const Icon(Icons.add_a_photo, size: 50),
              onPressed: addJournalPage,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (currentEntries[index]['imagePath'] != null)
                  Image.file(
                    File(currentEntries[index]['imagePath']),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    onChanged: (value) {
                      setState(() {
                        currentEntries[index]['content'] = value;
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
