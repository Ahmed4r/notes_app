import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/pages/add_note.dart';
import 'package:crud_firebase/pages/auth/login_page.dart';
import 'package:crud_firebase/pages/show_note_details.dart';
import 'package:crud_firebase/service/firebase_auth.dart';
import 'package:crud_firebase/service/firestore.dart';
import 'package:crud_firebase/shared/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestore = FirestoreService();

  final TextEditingController controller = TextEditingController();
  FirebaseAuthService auth = FirebaseAuthService();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  await auth.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } catch (e) {
                  debugPrint("Sign out error: $e");
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
          backgroundColor: AppColors.backgroundColor,
          title: const Text('Pinotes', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            tabs: [
              Tab(text: "All Notes"),
              Tab(text: "Work"),
              Tab(text: "Personal"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
          onPressed: () {
            // openNoteBox;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNote()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: firestore.readNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List notesList = snapshot.data!.docs;

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notesList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String noteTitle = data['title'];
                      String noteDescription = data['description'];

                      // Firestore Timestamp → DateTime
                      Timestamp timestamp = data['timestamp'];
                      DateTime dateTime = timestamp.toDate();

                      // Format date
                      String noteTime = DateFormat(
                        'dd/MM/yyyy hh:mm a',
                      ).format(dateTime);

                      List<String> noteTags = List<String>.from(
                        data['tags'] ?? [],
                      );

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ShowNoteDetails(
                                  title: noteTitle,
                                  description: noteDescription,
                                  docID: docID,
                                  tags: noteTags,
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
                          color: Color(0xff1e2837),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      noteTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      noteTime,
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  noteDescription,
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < noteTags.length && i < 2;
                                      i++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: getTagType(
                                              noteTags[i],
                                            ).color,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '#${noteTags[i]}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // لو أكتر من ٢ تاج، اعمل "…+X"
                                    if (noteTags.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '+${noteTags.length - 2}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    const Spacer(),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddNote(docID: docID),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        CupertinoIcons.delete,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        firestore.deleteNote(docID);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: notesList.length,
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No notes found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'No notes found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),

            // Work Tab
            StreamBuilder<QuerySnapshot>(
              stream: firestore.readNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List notesList = snapshot.data!.docs;

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notesList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String noteTitle = data['title'];
                      String noteDescription = data['description'];

                      // Firestore Timestamp → DateTime
                      Timestamp timestamp = data['timestamp'];
                      DateTime dateTime = timestamp.toDate();

                      // Format date
                      String noteTime = DateFormat(
                        'dd/MM/yyyy hh:mm a',
                      ).format(dateTime);

                      List<String> noteTags = List<String>.from(
                        data['tags'] ?? [],
                      );

                      if (!noteTags.contains('Work')) {
                        return SizedBox.shrink();
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ShowNoteDetails(
                                  title: noteTitle,
                                  description: noteDescription,
                                  docID: docID,
                                  tags: noteTags,
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
                          color: Color(0xff1e2837),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      noteTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      noteTime,
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  noteDescription,
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < noteTags.length && i < 2;
                                      i++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: getTagType(
                                              noteTags[i],
                                            ).color,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '#${noteTags[i]}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // لو أكتر من ٢ تاج، اعمل "…+X"
                                    if (noteTags.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '+${noteTags.length - 2}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    const Spacer(),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddNote(docID: docID),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        CupertinoIcons.delete,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        firestore.deleteNote(docID);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: notesList.length,
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),

            StreamBuilder<QuerySnapshot>(
              stream: firestore.readNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List notesList = snapshot.data!.docs;

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notesList[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String noteTitle = data['title'];
                      String noteDescription = data['description'];

                      // Firestore Timestamp → DateTime
                      Timestamp timestamp = data['timestamp'];
                      DateTime dateTime = timestamp.toDate();

                      // Format date
                      String noteTime = DateFormat(
                        'dd/MM/yyyy hh:mm a',
                      ).format(dateTime);

                      List<String> noteTags = List<String>.from(
                        data['tags'] ?? [],
                      );

                      if (!noteTags.contains('Personal')) {
                        return SizedBox.shrink();
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ShowNoteDetails(
                                  title: noteTitle,
                                  description: noteDescription,
                                  docID: docID,
                                  tags: noteTags,
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
                          color: Color(0xff1e2837),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      noteTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      noteTime,
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  noteDescription,
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < noteTags.length && i < 2;
                                      i++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: getTagType(
                                              noteTags[i],
                                            ).color,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '#${noteTags[i]}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    // لو أكتر من ٢ تاج، اعمل "…+X"
                                    if (noteTags.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '+${noteTags.length - 2}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                    const Spacer(),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddNote(docID: docID),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        CupertinoIcons.delete,
                                        color: Colors.white38,
                                      ),
                                      onPressed: () {
                                        firestore.deleteNote(docID);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: notesList.length,
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
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
