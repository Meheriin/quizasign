import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class QuizProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  
  List<Category> _categories = [];
  String _currentCategoryName = '';
  List<Question> _questions = [];
  List<int?> _userAnswers = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Question> get questions => _questions;
  List<int?> get userAnswers => _userAnswers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 20; // Changed to 20s as requested
  Timer? _timer;

  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get timeLeft => _timeLeft;

  void startTimer(VoidCallback onTimeUp) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        // Auto-finish quiz when global time is up
        _dbService.saveQuizResult(
          categoryName: _currentCategoryName,
          score: _score,
          totalQuestions: _questions.length,
          questions: _questions,
          userAnswers: _userAnswers,
        );
        onTimeUp(); 
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQuestions({required int id, required String name}) async {
    _isLoading = true;
    _error = null;
    _questions = [];
    _userAnswers = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _timeLeft = 20; // Global quiz time: 20 seconds
    _currentCategoryName = name;
    notifyListeners();

    try {
      _questions = await _apiService.getQuestions(id);
      _userAnswers = List.filled(_questions.length, null);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void answerQuestion(int selectedIndex) {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return;
    
    _userAnswers[_currentQuestionIndex] = selectedIndex;

    if (selectedIndex != -1 && selectedIndex == _questions[_currentQuestionIndex].answerIndex) {
      _score += _questions[_currentQuestionIndex].mark;
    }
    _currentQuestionIndex++;

    if (_currentQuestionIndex >= _questions.length) {
      stopTimer(); // Stop timer if questions finished early
      _dbService.saveQuizResult(
        categoryName: _currentCategoryName,
        score: _score,
        totalQuestions: _questions.length,
        questions: _questions,
        userAnswers: _userAnswers,
      );
    }

    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    notifyListeners();
  }
}
