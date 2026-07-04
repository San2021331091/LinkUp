import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibely/controller/status_controller.dart';
import 'package:vibely/models/status.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatusController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Status',
          style: GoogleFonts.acme(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.statuses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.statuses.isEmpty) {
          return const Center(child: Text('No statuses yet'));
        }
        return RefreshIndicator(
          onRefresh: controller.fetchStatuses,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.statuses.length,
            itemBuilder: (context, index) {
              final status = controller.statuses[index];
              return _StatusCard(
                status: status,
                controller: controller,
                onLike: () => controller.likeStatus(status.id),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C5CFC),
        onPressed: () => showComposeSheet(context, controller),
        child: const Icon(Icons.edit, color: Colors.white),
      
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
    );
  }
}

/// Opens the compose sheet. 
void showComposeSheet(
  BuildContext context,
  StatusController controller, {
  StatusModel? editStatus,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _ComposeSheet(controller: controller, editStatus: editStatus),
  );
}

/// Bottom sheet for writing or editing a status.
class _ComposeSheet extends StatefulWidget {
  final StatusController controller;
  final StatusModel? editStatus;
  const _ComposeSheet({required this.controller, this.editStatus});

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  late final TextEditingController _contentCtrl;
  final _picker = ImagePicker();
  File? _pickedImage;
  String? _existingImageUrl; // kept image from the edited status
  bool _isPosting = false;

  bool get _isEditing => widget.editStatus != null;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(
      text: widget.editStatus?.content ?? '',
    );
    _existingImageUrl = widget.editStatus?.imageUrl;
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _existingImageUrl = null; // replacing the old image
      });
    }
  }

  Future<void> _submit() async {
    final content = _contentCtrl.text.trim();
    final hasAnyImage =
        _pickedImage != null ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

    if (content.isEmpty && !hasAnyImage) {
      Get.snackbar('Error', 'Write something or add an image');
      return;
    }

    setState(() => _isPosting = true);

    // start with whatever image the status already had
    String? imageUrl = _existingImageUrl;

    // if a new image was picked, upload it
    if (_pickedImage != null) {
      imageUrl = await widget.controller.uploadToImgbb(_pickedImage!);
      if (imageUrl == null) {
        setState(() => _isPosting = false);
        return;
      }
    }

    if (_isEditing) {
      await widget.controller.updateStatus(
        statusId: widget.editStatus!.id,
        content: content.isEmpty ? null : content,
        imageUrl: imageUrl,
      );
    } else {
      await widget.controller.createStatus(
        content: content.isEmpty ? null : content,
        imageUrl: imageUrl,
      );
    }

    if (mounted) {
      setState(() => _isPosting = false);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final showImage =
        _pickedImage != null ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            _isEditing ? 'Edit Status' : 'New Status',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // ── content field ──
          TextField(
            controller: _contentCtrl,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── image preview / picker ──
          if (showImage) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _pickedImage != null
                      ? Image.file(
                          _pickedImage!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _existingImageUrl!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _pickedImage = null;
                      _existingImageUrl = null;
                    }),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7C5CFC),
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text('Add image'),
            ),

          const SizedBox(height: 16),

          // ── submit button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPosting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFC),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? 'Save' : 'Post',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final StatusModel status;
  final StatusController controller;
  final VoidCallback onLike;

  const _StatusCard({
    required this.status,
    required this.controller,
    required this.onLike,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Active just now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours} hours ago';
    return 'Active ${diff.inDays} days ago';
  }

  Future<void> _share() async {
    final user = status.user;
    final buffer = StringBuffer();
    if (user?.name != null) buffer.writeln('${user!.name} on Vibely:');
    if (status.content != null && status.content!.isNotEmpty) {
      buffer.writeln(status.content);
    }
    if (status.imageUrl != null && status.imageUrl!.isNotEmpty) {
      buffer.writeln(status.imageUrl);
    }
    final text = buffer.toString().trim();
    if (text.isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text));
  }

 Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete status?'),
        backgroundColor: Colors.blueGrey,
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),   
            child: Text(
              'Cancel',
              style: GoogleFonts.acme(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),    
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteStatus(status.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = status.user;
    final isOwner = status.userId == controller.currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header row ──
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (user?.image != null)
                    ? NetworkImage(user!.image!)
                    : null,
                child: (user?.image == null)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(status.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // ── edit/delete menu: always visible, disabled for non-owners ──
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                color: Colors.blue,
                surfaceTintColor: Colors.blue,
                enabled:
                    isOwner, // whole button greys out & is untappable for others
                onSelected: (value) {
                  if (value == 'edit') {
                    showComposeSheet(context, controller, editStatus: status);
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    enabled: isOwner,
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: isOwner ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: isOwner ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    enabled: isOwner,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: isOwner ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: isOwner ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── content ──
          if (status.content != null && status.content!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              status.content!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],

          // ── image ──
          if (status.imageUrl != null && status.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                status.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── action row ──
          Row(
            children: [
              const Spacer(),
              _ActionIcon(
                icon: Icons.favorite_border,
                count: status.likesCount,
                onTap: onLike,
              ),
              const SizedBox(width: 20),
              _ActionIcon(
                icon: Icons.share_outlined,
                count: status.sharesCount,
                onTap: _share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  const _ActionIcon({required this.icon, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text('$count', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ],
      ),
    );
  }
}
