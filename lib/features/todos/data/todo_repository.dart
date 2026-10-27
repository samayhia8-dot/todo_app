
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _todos =>
      _firestore.collection('todos');

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to continue.');
    }

    return user.uid;
  }

  Future<void> addTodo({
    required String title,
    required String description,
  }) async {
    final userId = _currentUserId;

    await _todos.add({
      'title': title.trim(),
      'description': description.trim(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<TodoModel>> fetchTodos() async {
    final userId = _currentUserId;

    final snapshot = await _todos
        .where('userId', isEqualTo: userId)
        .get();

    final todos = snapshot.docs.map((doc) {
      return TodoModel.fromMap(doc.id, doc.data());
    }).toList();

    todos.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) {
        return 0;
      }

      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;

      return b.createdAt!.compareTo(a.createdAt!);
    });

    return todos;
  }
}
