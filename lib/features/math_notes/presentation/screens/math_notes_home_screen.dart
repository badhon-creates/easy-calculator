import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/math_notes/data/repositories/local_note_repository.dart';
import 'package:easy_calculator/features/math_notes/data/repositories/local_note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/models/math_note.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_repository.dart';
import 'package:easy_calculator/features/math_notes/domain/repositories/note_session_repository.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/notes_list_cubit.dart';
import 'package:easy_calculator/features/math_notes/presentation/cubit/notes_list_state.dart';
import 'package:easy_calculator/features/math_notes/presentation/screens/note_editor_screen.dart';
import 'package:easy_calculator/features/math_notes/presentation/widgets/note_card.dart';

/// Home screen for Math Notes displaying the searchable note list,
/// new-note button, sort options, and multi-note selection/deletion.
class MathNotesHomeScreen extends StatefulWidget {
  const MathNotesHomeScreen({
    super.key,
    this.noteRepository,
    this.sessionRepository,
  });

  final NoteRepository? noteRepository;
  final NoteSessionRepository? sessionRepository;

  @override
  State<MathNotesHomeScreen> createState() => _MathNotesHomeScreenState();
}

class _MathNotesHomeScreenState extends State<MathNotesHomeScreen> {
  late final NoteRepository _noteRepository;
  late final NoteSessionRepository _sessionRepository;
  late final NotesListCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteRepository = widget.noteRepository ?? LocalNoteRepository();
    _sessionRepository =
        widget.sessionRepository ?? LocalNoteSessionRepository();
    _cubit = NotesListCubit(noteRepository: _noteRepository);
    _cubit.loadNotes();
    _checkUnfinishedSession();
  }

  Future<void> _checkUnfinishedSession() async {
    try {
      final session = await _sessionRepository.loadSession();
      if (session != null && mounted && !session.draftNote.isEmpty) {
        // Automatically restore unfinished note draft
        await _openNoteEditor(session.draftNote, isNewNote: session.isNewNote);
      }
    } catch (_) {
      // Safe recovery
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _openNoteEditor(MathNote note, {bool isNewNote = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NoteEditorScreen(
          note: note,
          noteRepository: _noteRepository,
          sessionRepository: _sessionRepository,
          isNewNote: isNewNote,
        ),
      ),
    );
    if (mounted) {
      await _cubit.loadNotes();
    }
  }

  void _createNewNote() {
    final newNote = MathNote.empty();
    _openNoteEditor(newNote, isNewNote: true);
  }

  Future<void> _confirmDeleteSelected(BuildContext context) async {
    final colors = context.calcColors;
    final count = _cubit.state.selectedIds.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Delete Selected Notes?',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete $count note${count > 1 ? 's' : ''}? This action cannot be undone.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _cubit.deleteSelectedNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<NotesListCubit, NotesListState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: colors.backgroundColor,
            appBar: AppBar(
              backgroundColor: colors.backgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: state.isSelectionMode
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.textPrimary,
                      ),
                      tooltip: 'Cancel selection',
                      onPressed: _cubit.exitSelectionMode,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.textPrimary,
                      ),
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
              title: state.isSelectionMode
                  ? Text(
                      '${state.selectedIds.length} selected',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      'Math Notes',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              actions: [
                if (state.isSelectionMode) ...[
                  IconButton(
                    icon: Icon(
                      Icons.select_all_rounded,
                      color: colors.textPrimary,
                    ),
                    tooltip: 'Select all',
                    onPressed: _cubit.selectAll,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_rounded, color: colors.errorColor),
                    tooltip: 'Delete selected',
                    onPressed: state.selectedIds.isNotEmpty
                        ? () => _confirmDeleteSelected(context)
                        : null,
                  ),
                ] else ...[
                  // Calculator return icon
                  IconButton(
                    icon: Icon(
                      Icons.calculate_outlined,
                      color: colors.textPrimary,
                    ),
                    tooltip: 'Return to calculator',
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Three-dot menu
                  PopupMenuButton<String>(
                    tooltip: 'Notes options',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colors.textPrimary,
                    ),
                    color: colors.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white12
                            : colors.numberButtonBorder,
                      ),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'sort':
                          _cubit.toggleSortOrder();
                          break;
                        case 'select':
                          _cubit.enterSelectionMode();
                          break;
                        case 'delete':
                          _cubit.enterSelectionMode();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'sort',
                        child: Row(
                          children: [
                            Icon(
                              Icons.sort_rounded,
                              color: colors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              state.newestFirst
                                  ? 'Sort: Oldest first'
                                  : 'Sort: Newest first',
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'select',
                        child: Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              color: colors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Select notes',
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            body: Column(
              children: [
                // Top Search bar with New-Note pencil button
                if (!state.isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
                    child: Row(
                      children: [
                        // Search text field
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2626)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : colors.numberButtonBorder,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search notes...',
                                hintStyle: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: colors.textPrimary,
                                  size: 22,
                                ),
                                suffixIcon: state.hasActiveSearch
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear_rounded,
                                          color: colors.textSecondary,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          _cubit.clearSearch();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                              ),
                              onChanged: _cubit.setSearchQuery,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Pencil / New Note Icon Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.operatorButton,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.operatorButton.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              color: colors.operatorText,
                              size: 22,
                            ),
                            tooltip: 'New note',
                            onPressed: _createNewNote,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Note list or empty states
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.notes.isEmpty
                      ? _buildEmptyState(context, state)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            final isSelected = state.selectedIds.contains(
                              note.id,
                            );
                            return NoteCard(
                              note: note,
                              isSelected: isSelected,
                              isSelectionMode: state.isSelectionMode,
                              onTap: () {
                                if (state.isSelectionMode) {
                                  _cubit.toggleSelection(note.id);
                                } else {
                                  _openNoteEditor(note);
                                }
                              },
                              onLongPress: () {
                                if (!state.isSelectionMode) {
                                  _cubit.enterSelectionMode(note.id);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NotesListState state) {
    final colors = context.calcColors;
    final hasSearch = state.hasActiveSearch;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.operatorButton.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch ? Icons.search_off_rounded : Icons.edit_note_rounded,
                size: 40,
                color: colors.operatorButton,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No Matching Notes' : 'No Math Notes Yet',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'No notes matched "${state.searchQuery}". Try a different search term.'
                  : 'Tap the pencil icon above to create your first rich Math Note.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
