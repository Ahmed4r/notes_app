import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/pages/add_note.dart';
import 'package:crud_firebase/service/firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowNoteDetails extends StatelessWidget {
  String title;
  String description;
  String? docID;
  String noteTime;
  List<String> tags;
  ShowNoteDetails({
    super.key,
    required this.title,
    required this.description,
    this.docID,
    required this.noteTime,
    required this.tags,
  });
  final firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff101518),
      appBar: AppBar(
        backgroundColor: Color(0xff101518),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text('Note Details ', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QueryDocumentSnapshot>(
        stream: firestore.readNotes().map(
          (querySnapshot) =>
              querySnapshot.docs.firstWhere((doc) => doc.id == docID),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Note not found'));
          }

          final note = snapshot.data!;
          final title = note['title'] ?? 'No Title';
          final description = note['description'] ?? 'No Description';
          return Column(
            children: [
              Card(
                color: Color(0xff1e2837),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Color(0xffB0B0B0),
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        noteTime,
                        style: TextStyle(
                          color: Color(0xff81C784),
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var tag in tags)
                                  Chip(
                                    backgroundColor: getTagType(tag).color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    label: Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNote(docID: docID),
                        ),
                      );
                    },
                    child: Container(
                      height: 70,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Color(0xff293038),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      firestore.deleteNote(docID!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 70,
                      width: 190,
                      decoration: BoxDecoration(
                        color: Color(0xffd32e2e),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.delete, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

enum TagType { work, personal, ideas, study, shopping, other }

extension TagTypeColor on TagType {
  Color get color {
    switch (this) {
      case TagType.work:
        return Color(0xff342a5a);
      case TagType.personal:
        return Color(0xff1e345a);
      case TagType.ideas:
        return Colors.purple;
      case TagType.study:
        return Colors.green;
      case TagType.shopping:
        return Colors.orange;
      case TagType.other:
        return Colors.grey;
    }
  }
}

// تحويل من String لـ Enum
TagType getTagType(String tag) {
  switch (tag.toLowerCase()) {
    case 'work':
      return TagType.work;
    case 'personal':
      return TagType.personal;
    case 'ideas':
      return TagType.ideas;
    case 'study':
      return TagType.study;
    case 'shopping':
      return TagType.shopping;
    default:
      return TagType.other;
  }
}
