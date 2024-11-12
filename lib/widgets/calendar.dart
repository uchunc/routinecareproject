import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onDateSelected;
  final Map<String, List<String>> journalEntries;

  Calendar(
      {required this.date,
      required this.onDateSelected,
      required this.journalEntries});

  String getWeekdayString(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  Color getCircleColor(DateTime currentDate) {
    String formattedDate =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";
    if (currentDate == date) {
      return Colors.blue; // 선택한 날짜
    } else if (journalEntries.containsKey(formattedDate) &&
        journalEntries[formattedDate]!.isNotEmpty) {
      return Colors.green; // 일지가 있는 날짜
    } else {
      return Colors.grey; // 일지가 없는 날짜
    }
  }

  @override
  Widget build(BuildContext context) {
    int lastDay = DateTime(date.year, date.month + 1, 0).day;

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lastDay,
        itemBuilder: (context, index) {
          DateTime currentDate = DateTime(date.year, date.month, index + 1);
          return GestureDetector(
            onTap: () => onDateSelected(currentDate),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: getCircleColor(currentDate),
                    child: Text('${currentDate.day}'),
                  ),
                  Text(getWeekdayString(currentDate.weekday)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
