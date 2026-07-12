import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UsersProvider extends ChangeNotifier {
  final List<UserModel> _users = [
    UserModel(
      id: '1',
      name: 'Ana Souza',
      email: 'ana.souza@example.com',
      createdAt: DateTime(2024, 1, 10),
      isActive: true,
    ),
    UserModel(
      id: '2',
      name: 'Bruno Lima',
      email: 'bruno.lima@example.com',
      createdAt: DateTime(2024, 2, 15),
      isActive: true,
    ),
    UserModel(
      id: '3',
      name: 'Carlos Mendes',
      email: 'carlos.mendes@example.com',
      createdAt: DateTime(2024, 3, 5),
      isActive: false,
    ),
    UserModel(
      id: '4',
      name: 'Diana Ferreira',
      email: 'diana.f@example.com',
      createdAt: DateTime(2024, 4, 22),
      isActive: true,
    ),
    UserModel(
      id: '5',
      name: 'Eduardo Costa',
      email: 'edu.costa@example.com',
      createdAt: DateTime(2024, 5, 8),
      isActive: false,
    ),
    UserModel(
      id: '6',
      name: 'Fernanda Rocha',
      email: 'fernanda.r@example.com',
      createdAt: DateTime(2024, 6, 30),
      isActive: true,
    ),
    UserModel(
      id: '7',
      name: 'Gabriel Torres',
      email: 'gabriel.t@example.com',
      createdAt: DateTime(2024, 7, 14),
      isActive: true,
    ),
    UserModel(
      id: '8',
      name: 'Helena Dias',
      email: 'helena.d@example.com',
      createdAt: DateTime(2024, 8, 3),
      isActive: false,
    ),
  ];

  String _searchQuery = '';
  bool _isLoading = false;

  List<UserModel> get allUsers => _users;

  List<UserModel> get filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  int get totalUsers => _users.length;
  int get activeUsers =>
      _users.where((u) => u.isActive).length;

  bool get isLoading => _isLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addUser(String name, String email) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
      isActive: false,
    );
    _users.add(newUser);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _users.removeWhere((u) => u.id == id);
    _isLoading = false;
    notifyListeners();
  }
}
