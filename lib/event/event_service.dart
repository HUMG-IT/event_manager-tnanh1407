import 'package:event_manager/event/event_model.dart';
import 'package:localstore/localstore.dart';

class EventService {
  final db = Localstore.getInstance(useSupportDir: true);

  //ten collection trong localstore(giong nhu trong ten bang)
  final path = 'events';

  //ham lay ds su kien tu localstore
  Future<List<EventModel>> getAllEvents() async {
    final eventsMap = await db.collection(path).get();

    if (eventsMap != null) {
      return eventsMap.entries.map((entry) {
        final eventData = entry.value as Map<String, dynamic>;
        if (!eventData.containsKey('id')) {
          eventData['id'] = entry.key.split('/').last;
        }
        return EventModel.fromMap(eventData);
      }).toList();
    }
    return [];
  }

  //ham luu 1 su kien vao localstore
  Future<void> saveEvent(EventModel item) async {
    //Neu id k ton tai(tao moi) thi lay 1 id ngau nhien
    item.id ??= db.collection(path).doc().id;
    await db.collection(path).doc(item.id).set(item.toMap());
  }

  //Hàm xóa 1 sự kiện từ localstore
  Future<void> deleteEvent(EventModel item) async {
    await db.collection(path).doc(item.id).delete();
  }
}
