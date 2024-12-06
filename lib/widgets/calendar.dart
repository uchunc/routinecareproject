import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  final DateTime date;
  final Function(DateTime) onDateSelected;
  final Map<String, List<Map<String, dynamic>>> journalEntries;

  const Calendar({
    super.key,
    required this.date,
    required this.onDateSelected,
    required this.journalEntries,
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late ScrollController _scrollController;
  late int selectedDayIndex;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    selectedDate = widget.date;
    selectedDayIndex = widget.date.day - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    double itemWidth = 56.0;
    double position = itemWidth * selectedDayIndex -
        MediaQuery.of(context).size.width / 2 +
        itemWidth / 2;

    double maxScroll = _scrollController.position.maxScrollExtent;
    double minScroll = _scrollController.position.minScrollExtent;
    if (position < minScroll) {
      position = minScroll;
    } else if (position > maxScroll) {
      position = maxScroll;
    }

    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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
    if (isSameDate(currentDate, selectedDate)) {
      return Colors.blue;
    } else {
      String formattedDate =
          "${currentDate.year}-${currentDate.month}-${currentDate.day}";
      if (widget.journalEntries.containsKey(formattedDate) &&
          widget.journalEntries[formattedDate]!.isNotEmpty) {
        return Colors.green;
      } else {
        return Colors.grey;
      }
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    int lastDay = DateTime(widget.date.year, widget.date.month + 1, 0).day;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lastDay,
        controller: _scrollController,
        itemBuilder: (context, index) {
          DateTime currentDate =
              DateTime(widget.date.year, widget.date.month, index + 1);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = currentDate;
                selectedDayIndex = index;
              });
              widget.onDateSelected(currentDate);
              _scrollToSelectedDate();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20.0,
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
