import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId; // The user to follow/unfollow
  final String currentUserId; // The logged-in user
  final double width;
  final double height;

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.currentUserId,
    this.width = 80,
    this.height = 40,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
  }

  Future<void> _loadFollowStatus() async {
    try {
      final currentUser = await Supabase.instance.client
          .from('users')
          .select('following')
          .eq('uid', widget.currentUserId)
          .maybeSingle();

      final targetUser = await Supabase.instance.client
          .from('users')
          .select('followers_count')
          .eq('uid', widget.targetUserId)
          .maybeSingle();

      if (currentUser != null && targetUser != null) {
        final followingList = List<dynamic>.from(currentUser['following'] ?? []);
        setState(() {
          isFollowing = followingList.contains(widget.targetUserId);
          followersCount = targetUser['followers_count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error loading follow status: $e");
    }
  }

  Future<void> _toggleFollow() async {
    try {
      final usersTable = Supabase.instance.client.from('users');

      // 1️⃣ Get current following array of logged-in user
      final currentUser = await usersTable
          .select('following')
          .eq('uid', widget.currentUserId)
          .maybeSingle();

      // 2️⃣ Get target user's followers count
      final targetUser = await usersTable
          .select('followers_count')
          .eq('uid', widget.targetUserId)
          .maybeSingle();

      if (currentUser == null || targetUser == null) return;

      List<dynamic> following = List<dynamic>.from(currentUser['following'] ?? []);
      int updatedFollowersCount = targetUser['followers_count'] ?? 0;

      if (isFollowing) {
        // Unfollow
        following.remove(widget.targetUserId);
        if (updatedFollowersCount > 0) updatedFollowersCount -= 1;
        isFollowing = false;
      } else {
        // Follow
        following.add(widget.targetUserId);
        updatedFollowersCount += 1;
        isFollowing = true;
      }

      // 3️⃣ Update current user's following
      await usersTable.update({'following': following}).eq('uid', widget.currentUserId);

      // 4️⃣ Update target user's followers_count
      await usersTable.update({'followers_count': updatedFollowersCount}).eq('uid', widget.targetUserId);

      setState(() {
        followersCount = updatedFollowersCount;
      });
    } catch (e) {
      debugPrint("Error toggling follow: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleFollow,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.grey : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$followersCount followers',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}