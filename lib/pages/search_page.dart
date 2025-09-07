import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/pages/show_note_details.dart';
import 'package:crud_firebase/service/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Search Notes',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),

            _buildNotesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search notes',
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            searchController.clear();
            setState(() {}); // refresh
          },
        ),
        filled: true,
        fillColor: const Color(0xff1e2837),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {}); // refresh UI on typing
      },
    );
  }

  Widget _buildNotesList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.readNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!.docs;
          final query = searchController.text.toLowerCase();

          final filteredNotes = notes.where((note) {
            final title = (note['title'] ?? '').toString().toLowerCase();
            final description = (note['description'] ?? '')
                .toString()
                .toLowerCase();
            final tags = List<String>.from(
              note['tags'] ?? [],
            ).map((tag) => tag.toLowerCase()).toList();

            return title.contains(query) ||
                description.contains(query) ||
                tags.any((tag) => tag.contains(query));
          }).toList();

          if (filteredNotes.isEmpty) {
            return const Center(
              child: Text(
                'No notes found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              Timestamp timestamp = note['timestamp'];
              DateTime dateTime = timestamp.toDate();
              // Format date
              String noteTime = DateFormat(
                'dd/MM/yyyy hh:mm a',
              ).format(dateTime).toString();

              List<String> noteTags = List<String>.from(note['tags'] ?? []);

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShowNoteDetails(
                          title: note['title'],
                          description: note['description'],
                          noteTime: noteTime,
                          tags: noteTags,
                          docID: note.id,
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  color: const Color(0xff1e2837),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      note['title'] ?? '',
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      note['description'] ?? '',
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
