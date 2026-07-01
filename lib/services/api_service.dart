import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizasign/models/category_model.dart';
import 'package:quizasign/models/question_model.dart';

class ApiService {
  static const String baseUrl = 'https://sadiks-quiz-apihub.lovable.app/api/v1';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((category) => Category.fromJson(category))
              .toList();
        }
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Question>> getQuestions(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/$categoryId/questions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((question) => Question.fromJson(question))
              .toList();
        }
      }
      throw Exception('Failed to load questions');
    } catch (e) {
      rethrow;
    }
  }
}
