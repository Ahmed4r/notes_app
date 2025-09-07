import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Firebase Firestore CRUD
  // collection
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  // todo: add

  Future<void> addNote(
    String titleNote,
    String descriptionNote,
    List<String> tags,
  ) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return notes.add({
      "title": titleNote,
      "description": descriptionNote,
      "tags": tags,
      'timestamp': Timestamp.now(),
      'uid': uid, // ربط النوت باليوزر
    });
  }

  // todo :  read
  Stream<QuerySnapshot> readNotes() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final notesStream = notes
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
    return notesStream;
  }

  // todo: update
  Future<void> updateNotes(
    String docID,
    String newTitleNote,
    String newDescriptionNote,
    List<String> newTags,
  ) {
    return notes.doc(docID).update({
      'title': newTitleNote,
      'description': newDescriptionNote,
      'tags': newTags,
      'timestamp': Timestamp.now(),
    });
  }

  // todo: delete

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
