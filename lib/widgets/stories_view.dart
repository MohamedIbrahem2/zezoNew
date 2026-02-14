import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/widgets/stories_shimmer.dart';

import '../main.dart';

/// =========================
/// HOME STORIES LIST
/// =========================
class ListItemsStatusHome extends StatelessWidget {
  const ListItemsStatusHome({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final stories = snapshot.data!.docs;

        if (stories.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 78,
          child: ListView.builder(
            itemCount: stories.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final data =
              stories[index].data() as Map<String, dynamic>;
              return _itemStory(context, index, data, stories);
            },
          ),
        );
      },
    );
  }

  Widget _itemStory(
      BuildContext context,
      int index,
      Map<String, dynamic> item,
      List<QueryDocumentSnapshot> stories,
      ) {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(context, index, stories);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsetsDirectional.only(start: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: mainColor, width: 3),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: item['imageSmallUrl'] ?? '',
            width: 66,
            height: 66,
            fit: BoxFit.fill,
            placeholder: (_, __) => const ImageShimmer(
              width: 66,
              height: 66,
              borderRadius: BorderRadius.all(Radius.circular(33)),
            ),
            errorWidget: (_, __, ___) =>
                Image.asset('images/logo.png'),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(
      BuildContext context,
      int index,
      List<QueryDocumentSnapshot> stories,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StoryViewer(
        stories: stories,
        initialIndex: index,
      ),
    );
  }
}

/// =========================
/// STORY VIEWER
/// =========================
class _StoryViewer extends StatefulWidget {
  final List<QueryDocumentSnapshot> stories;
  final int initialIndex;

  const _StoryViewer({
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  Future<void> _deleteCurrentStory(BuildContext context) async {
    try {
      final storyDoc = widget.stories[_currentIndex];

      await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyDoc.id)
          .delete();

      if (!mounted) return;

      Navigator.pop(context); // close story viewer
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete story: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1 / 1.2,
      widthFactor: 1,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.stories.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final data =
          widget.stories[index].data() as Map<String, dynamic>;

          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.white),

                CachedNetworkImage(
                  imageUrl: data['imageLargeUrl'] ?? '',
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                  const Center(child: ImageShimmer()),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                _topUI(context),

                /// PREVIOUS
                widget.stories.length > 1 ? PositionedDirectional(
                  start: 10,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentIndex > 0) {
                        _pageController.previousPage(
                          duration:
                          const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: _navButton(Icons.arrow_back_ios_new),
                  ),
                ) : SizedBox(),

                /// NEXT
                widget.stories.length > 1 ?  PositionedDirectional(
                  end: 10,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentIndex <
                          widget.stories.length - 1) {
                        _pageController.nextPage(
                          duration:
                          const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: _navButton(Icons.arrow_forward_ios),
                  ),
                ) : SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _navButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _topUI(BuildContext context) {
    final isAdmin = context.watch<AdminProvider>().isAdmin;
    return Stack(
      children: [
        PositionedDirectional(
          top: 16,
          start: 16,
          end: 16,
          child: Row(
            children: List.generate(
              widget.stories.length,
                  (i) => Expanded(
                child: Container(
                  height: 3,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _currentIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: 30,
          end: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close,
                color: Colors.black, size: 28),
          ),
        ),
        isAdmin
            ? PositionedDirectional(
          top: 30,
          end: 50,
          child: GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Story'),
                  content:
                  const Text('Are you sure you want to delete this story?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                _deleteCurrentStory(context);
              }
            },
            child:  Icon(
              Icons.delete,
              color: mainColor,
              size: 28,
            ),
          ),
        )
            : const SizedBox(),

      ],
    );
  }
}
