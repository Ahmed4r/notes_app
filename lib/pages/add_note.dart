import 'dart:developer';

import 'package:crud_firebase/service/firestore.dart';
import 'package:crud_firebase/shared/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class AddNote extends StatefulWidget {
  String? docID;
  AddNote({super.key, this.docID});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final firestore = FirestoreService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> availableTags = [
    "Work",
    "Personal",
    "Ideas",
    "Study",
    "Shopping",
  ];
  List<String> _tags = [];

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  // خلي عندك ليست التاجات المتاحة

  void _showAddTagDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1e2837),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Choose Tag",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var tag in availableTags)
                    ChoiceChip(
                      label: Text(
                        tag,
                        style: const TextStyle(color: Colors.white),
                      ),
                      selected: _tags.contains(tag),
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.grey[850],
                      onSelected: (selected) {
                        setState(() {
                          if (selected && !_tags.contains(tag)) {
                            _tags.add(tag);
                          } else {
                            _tags.remove(tag);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.docID == null ? 'Add Note' : 'Edit Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.docID == null ? 'Title' : 'Edit Title',
                  hintStyle: TextStyle(fontSize: 40, color: Color(0xff959da6)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                maxLines: 2,
                keyboardType: TextInputType.multiline,
              ),
              // description
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.docID == null
                      ? 'Description'
                      : 'Edit Description',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 96, 98, 100),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 200),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Tags',
                  style: TextStyle(color: Color(0xff959da6), fontSize: 20),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var tag in _tags)
                    Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Color(0xff2a2a2a),
                      deleteIcon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                      ),
                      onDeleted: () => _removeTag(tag),
                    ),

                  // add tag button
                  GestureDetector(
                    onTap: _showAddTagDialog,
                    child: DottedBorder(
                      color: Colors.grey,
                      strokeWidth: 2,
                      dashPattern: const [6, 2],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(30),
                      child: Container(
                        height: 40,
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.grey, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Add Tag",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Center(
                child: InkWell(
                  onTap: () {
                    if (widget.docID == null) {
                      firestore.addNote(
                        titleController.text,
                        descriptionController.text,
                        _tags,
                      );
                    } else {
                      firestore.updateNotes(
                        widget.docID!,
                        titleController.text,
                        descriptionController.text,
                        _tags,
                      );
                    }

                    titleController.clear();
                    descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 70,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
