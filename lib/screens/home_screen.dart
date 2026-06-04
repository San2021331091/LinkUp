import 'package:flutter/material.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/screens/following_video_screen.dart';
import 'package:vibely/screens/for_you_video_screen.dart';
import 'package:vibely/screens/profile_screen.dart';
import 'package:vibely/screens/search_screen.dart';
import 'package:vibely/screens/upload_video_screen.dart';
import 'package:vibely/widgets/banner_widget.dart';
import 'package:vibely/widgets/linkup_ai_widget.dart';
import 'package:vibely/widgets/upload_custom_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String currentUserId;
  int screenIndex = 0;
  late final List<Widget> screenList;

  @override
  void initState() {
    super.initState();
    currentUserId = SupabaseAuth.supabase.auth.currentUser?.id ?? "";

    screenList = [
      ForYouVideoScreen(),
      SearchScreen(),
      UploadVideoScreen(),
      FollowingVideoScreen(),
      ProfileScreen(userId: currentUserId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LinkUpAIView()),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            screenIndex = index;
          });
        },
        backgroundColor: Colors.blueAccent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFFAF9F6),
        currentIndex: screenIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: "Discover",
          ),
          BottomNavigationBarItem(icon: UploadCustomIcon(), label: "Upload"),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_sharp, size: 30),
            label: "Following",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: "Me",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: screenList[screenIndex]),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
