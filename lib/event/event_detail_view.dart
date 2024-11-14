import 'event_model.dart';
import 'event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Man hinh chi tiet su kien cho phep them moi hoac cap nhat
class EventDetailView extends StatefulWidget {
  final EventModel event;
  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final subjectController = TextEditingController();
  final notesController = TextEditingController();
  final eventService = EventService();

  @override
  void initState() {
    super.initState();
    subjectController.text = widget.event.subject;
    notesController.text = widget.event.notes ?? '';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    //hien hop thoai chon ngay
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: isStart ? widget.event.startTime : widget.event.endTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? widget.event.startTime : widget.event.endTime,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
          if (isStart) {
            widget.event.startTime = newDateTime;
            if (widget.event.startTime.isAfter(widget.event.endTime)) {
              //tu thiet lap endtime 1 tieng sau starttime
              widget.event.endTime =
                  widget.event.startTime.add(const Duration(hours: 1));
            }
          } else {
            widget.event.endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    widget.event.subject = subjectController.text;
    widget.event.notes = notesController.text;
    await eventService.saveEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteEvent() async {
    await eventService.deleteEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true); // tra ve man hinh truowc do
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.id == null ? al.addEvent : al.eventDetails,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Tên sự kiện'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Sự kiện cả ngày'),
                trailing: Switch(
                    value: widget.event.isAllDay,
                    onChanged: (value) {
                      setState(() {
                        widget.event.isAllDay = value;
                      });
                    }),
              ),
              //Sử dụng toán tử mở rộng trong Dart...
              if (!widget.event.isAllDay) ...[
                const SizedBox(height: 16),
                ListTile(
                  title:
                      Text('Bắt đầu: ${widget.event.formatedStartTimeString}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDateTime(isStart: true),
                ),
                ListTile(
                  title:
                      Text('Kết thúc: ${widget.event.formatedEndTimeString}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDateTime(isStart: false),
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Ghi chú sự kiện'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //chỉ hiện thị nút xóa nếu không phải sựkin mới
                  if (widget.event.id != null)
                    FilledButton.tonalIcon(
                        onPressed: _deleteEvent,
                        label: const Text('Xóa sự kiện')),
                  FilledButton.icon(
                      onPressed: _saveEvent, label: const Text('Lưu sự kiện'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
