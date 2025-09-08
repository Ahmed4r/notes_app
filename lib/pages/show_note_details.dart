import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/pages/add_note.dart';
import 'package:crud_firebase/service/firestore.dart';
import 'package:crud_firebase/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowNoteDetails extends StatefulWidget {
  final String title;
  final String description;
  final String? docID;
  final String noteTime;
  final List<String> tags;
  const ShowNoteDetails({
    super.key,
    required this.title,
    required this.description,
    this.docID,
    required this.noteTime,
    required this.tags,
  });

  @override
  State<ShowNoteDetails> createState() => _ShowNoteDetailsState();
}

class _ShowNoteDetailsState extends State<ShowNoteDetails> {
  final firestore = FirestoreService();
  String? aiSummary; // Add this

  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;
  Future<void> fetchSummary() async {
    final summary = await getNoteSummaries();
    setState(() {
      isHidden = false;
      aiSummary = summary;
    });
  }

  bool isHidden = true;

  Future<String?> getNoteSummaries() async {
    Uri url = Uri.parse('${Constants.baseUrl}${Constants.apikey}');
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {
                      "text":
                          "Detect the language of the following text and summarize it in the SAME language only. If Arabic → summarize in Arabic. If English → summarize in English. Do NOT translate to any other language. Text: ${widget.description}",
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['candidates'][0]['content']['parts'][0]['text'];
        return summary;
      } else {
        print(
          'Failed to fetch note summaries. Status code: ${response.statusCode}',
        );
        return null;
      }
    } on http.ClientException catch (_) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request timed out.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unexpected error: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

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
      bottomNavigationBar: Padding(
        padding: EdgeInsetsGeometry.only(bottom: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNote(docID: widget.docID),
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
                firestore.deleteNote(widget.docID!);
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
      ),
      body: StreamBuilder<QueryDocumentSnapshot>(
        stream: firestore.readNotes().map(
          (querySnapshot) =>
              querySnapshot.docs.firstWhere((doc) => doc.id == widget.docID),
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
          return SingleChildScrollView(
            child: Column(
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
                          widget.noteTime,
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
                                  for (var tag in widget.tags)
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
                SizedBox(height: 50),

                isHidden
                    ? InkWell(
                        onTap: () {
                          try {
                            fetchSummary();
                          } catch (e) {
                            print('Error fetching summary: $e');
                          }
                        },
                        child: Container(
                          height: 70,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xff2a2439),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: Colors.purpleAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Show AI Summary',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )
                    : Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xff293038),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 20,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: Colors.purpleAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Ai Summary',
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 40),

                                Text(
                                  aiSummary ?? 'Error , no internet connection',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                SizedBox(height: 40),
              ],
            ),
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
