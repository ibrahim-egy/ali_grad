import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskService {
  final String taskEndpoint = "http://10.0.2.2:8888/api/tasks";

  Future<bool> postTask(taskRequest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("No token found");
        return false;
      }

      final response = await http.post(
        Uri.parse("$taskEndpoint/postTask"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Task posted successfully");
        return true;
      } else {
        print("❌ Failed to post task: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error posting task: $e");
      return false;
    }
  }

  Future<List<TaskResponse>> getUnassignedTasks(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found");
        return [];
      }
      final response = await http.get(
        Uri.parse("$taskEndpoint/regular/open?taskPosterId=$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<TaskResponse> tasks = data
            .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
            .toList();

        // print("✅ Unassigned tasks fetched: ${tasks.length}");
        return tasks;
      } else {
        print("❌ Failed to fetch unassigned tasks: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching unassigned tasks: $e");
      return [];
    }
  }

  Future<List<TaskResponse>> getOngoingTasks(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("❌ No token found");
        return [];
      }

      final response = await http.get(
        Uri.parse("$taskEndpoint/poster/ongoing?taskPosterId=$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<TaskResponse> tasks = data
            .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
            .toList();

        // print("✅ Ongoing tasks fetched: ${tasks.length}");
        return tasks;
      } else {
        print("❌ Failed to fetch ongoing tasks: ${response.statusCode}");
        print("Body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching ongoing tasks: $e");
      return [];
    }
  }

  Future<List<TaskResponse>?> getTasksByTaskPosterId(
      String taskPosterId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];
    final response = await http.get(
      Uri.parse("$taskEndpoint/poster/$taskPosterId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<TaskResponse> tasks = data
          .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
          .toList();

      return tasks;
    } else {
      print("jkashdfjah");
    }
    return [];
  }

  Future<List<TaskResponse>> getNearbyTasks({
    required double latitude,
    required double longitude,
    required double radius,
    required String userId,
  }) async {
    final url = Uri.parse(
        '$taskEndpoint/nearby?lat=$latitude&lon=$longitude&radius=$radius&userId=$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => TaskResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Failed to fetch nearby tasks: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching nearby tasks: $e');
      return [];
    }
  }

  Future<bool> deleteTask(int taskId, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return false;
      }

      final url = Uri.parse('$taskEndpoint/delete/$taskId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Task deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete task: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting task: $e');
      return false;
    }
  }

  Future<TaskResponse?> fetchRegularTaskById(int taskId) async {
    final url = Uri.parse('$taskEndpoint/regular/$taskId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaskResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        print("Task not found");
      } else if (response.statusCode == 400) {
        print("Task is not a RegularTask");
      } else {
        print("Unexpected error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching task: $e");
    }

    return null;
  }

  Future<bool> updateTaskStatus({
    required int taskId,
    required String newStatus, // or TaskStatus if you have an enum
    required int userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return false;
      }

      final url = Uri.parse(
          "$taskEndpoint/$taskId/status?newStatus=$newStatus&userId=$userId");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Task status updated successfully');
        return true;
      } else {
        print('❌ Failed to update task status: \\${response.statusCode}');
        print('Response body: \\${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating task status: $e');
      return false;
    }
  }
}
