import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/controller/search_controller.dart';
import 'package:vibely/screens/profile_screen.dart';
import 'package:vibely/widgets/profile_icon.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final SearchControllerX controller = Get.put(SearchControllerX());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: searchController,
            onChanged: controller.searchUsers,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search users",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          // Show center responsive image when no users
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.network(
                'https://i.postimg.cc/NjzYFyb6/search.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.6,
              
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return ListTile(
              leading: ProfileIcon(
                userId: user.uid ?? "",
                size: 45,
              ),
              title: Text(
                user.name ?? "",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                user.email ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.red,
                size: 18,
              ),
              onTap: () {
                Get.to(() => ProfileScreen(
                      userId: user.uid!,
                    ));
              },
            );
          },
        );
      }),
    );
  }
}