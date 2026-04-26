import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/controller/comment_controller.dart';
import 'package:vibely/models/comment.dart';
import 'package:vibely/models/user.dart';

class CommentSheet extends StatefulWidget {
  final String videoId;
  final String userId;
  final VoidCallback? onCommentAdded;

  const CommentSheet({
    super.key,
    required this.videoId,
    required this.userId,
    this.onCommentAdded,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final CommentController commentController = Get.find<CommentController>();

  @override
  void initState() {
    super.initState();

    commentController.fetchComments(widget.videoId);

    ever(commentController.comments, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  User getUser(String userId) {
    return commentController.userCache[userId] ??
        User(uid: userId, name: "Unknown");
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getUser(widget.userId);

    return Obx(() {
      final comments = commentController.comments;
      final isLoading = commentController.isLoading.value;

      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Drag Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Comments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            /// COMMENT LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                  ? const Center(
                      child: Text(
                        "No comments yet",
                        style: TextStyle(color: Colors.black45),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final Comment comment =
                            comments[comments.length - 1 - index];
                        final user = getUser(comment.userId);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Avatar
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: user.image != null
                                    ? NetworkImage(user.image!)
                                    : null,
                                backgroundColor: Colors.blueGrey.shade200,
                                child: user.image == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),

                              const SizedBox(width: 10),

                              /// Content
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// USERNAME + ACTIONS
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user.name ?? "Unknown",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),

                                          if (comment.userId == widget.userId)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: Colors.brown,
                                                  ),
                                                  onPressed: () async {
                                                    final editController =
                                                        TextEditingController(
                                                          text: comment
                                                              .commentText,
                                                        );

                                                    final newText = await showDialog<String>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text(
                                                          "Edit Comment",
                                                        ),
                                                        content: TextField(
                                                          controller:
                                                              editController,
                                                          autofocus: true,
                                                          decoration:
                                                              const InputDecoration(
                                                                hintText:
                                                                    "Edit your comment",
                                                              ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(null),
                                                            child: const Text(
                                                              "Cancel",
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(
                                                                  editController
                                                                      .text
                                                                      .trim(),
                                                                ),
                                                            child: const Text(
                                                              "Save",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );

                                                    if (newText != null &&
                                                        newText.isNotEmpty) {
                                                      await commentController
                                                          .editComment(
                                                            commentId:
                                                                comment.id!,
                                                            newText: newText,
                                                          );
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    await commentController
                                                        .deleteComment(
                                                          commentId:
                                                              comment.id!,
                                                        );
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      /// COMMENT TEXT
                                      Text(
                                        comment.commentText,
                                        style: const TextStyle(fontSize: 14,color: Colors.black87),
                                        softWrap: true,
                                      ),

                                      const SizedBox(height: 6),

                                      /// DATE
                                      Text(
                                        comment.createdAt
                                            .toLocal()
                                            .toString()
                                            .substring(0, 16),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            /// INPUT FIELD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: const Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueGrey.shade200,
                    backgroundImage: currentUser.image != null
                        ? NetworkImage(currentUser.image!)
                        : null,
                    child: currentUser.image == null
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      await commentController.addComment(
                        videoId: widget.videoId,
                        userId: widget.userId,
                        text: text,
                      );

                      controller.clear();
                      widget.onCommentAdded?.call();

                      if (scrollController.hasClients) {
                        scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
