import 'package:crud_firebase/service/firestore.dart';
import 'package:crud_firebase/shared/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddNote extends StatefulWidget {
  final String? docID;
  final String? oldTitle;
  final String? oldDescription;
  final List<String>? tags;

  const AddNote({
    super.key,
    this.docID,
    this.oldTitle,
    this.oldDescription,
    this.tags,
  });

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers and tags
    titleController.text = widget.oldTitle ?? '';
    descriptionController.text = widget.oldDescription ?? '';
    _tags = List<String>.from(widget.tags ?? []);
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showAddTagDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1e2837),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose Tag",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (var tag in availableTags)
                    ChoiceChip(
                      label: Text(
                        tag,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
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
              SizedBox(height: 20.h),

              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 14.h,
                    ),
                  ),
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
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
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white, fontSize: 36.sp),
                decoration: InputDecoration(
                  hintText: widget.docID == null ? 'Title' : 'Edit Title',
                  hintStyle: TextStyle(
                    fontSize: 36.sp,
                    color: const Color(0xff959da6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
                maxLines: 2,
                keyboardType: TextInputType.multiline,
              ),
              // description
              TextField(
                controller: descriptionController,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
                decoration: InputDecoration(
                  hintText: widget.docID == null
                      ? 'Description'
                      : 'Edit Description',
                  hintStyle: TextStyle(
                    fontSize: 18.sp,
                    color: const Color.fromARGB(255, 96, 98, 100),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Tags',
                  style: TextStyle(
                    color: const Color(0xff959da6),
                    fontSize: 18.sp,
                  ),
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
              SizedBox(height: 50.h),
              Center(
                child: InkWell(
                  onTap: () {
                    if (titleController.text.trim().isEmpty) return;
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
                    height: 60.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: Colors.white, size: 24.sp),
                        SizedBox(width: 10.w),
                        Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
