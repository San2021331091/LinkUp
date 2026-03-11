import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vibely/models/user.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class SearchControllerX extends GetxController {
  final supabase = SupabaseAuth.supabase;

  RxList<User> users = <User>[].obs;
  RxBool isLoading = false.obs;

  /// search users
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      users.clear();
      return;
    }

    try {
      isLoading.value = true;

      final response = await supabase
          .from('users')
          .select()
          .ilike('name', '%$query%')
          .limit(20);

      final results =
          (response as List).map((e) => User.fromMap(e)).toList();

      users.assignAll(results);
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}