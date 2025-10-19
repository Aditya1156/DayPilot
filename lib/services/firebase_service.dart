import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daypilot/models/user_profile.dart';
import 'package:daypilot/models/task.dart';

/// Centralized Firebase service for all database operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if Firebase is available
  bool isAvailable() {
    try {
      _firestore.settings;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER PROFILE ====================

  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    if (!isAvailable()) return;
    
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(profile.toFirestore(), SetOptions(merge: true));
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    if (!isAvailable()) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserProfile.fromFirestore(doc.data()!);
  }

  /// Update username
  Future<void> updateUsername(String uid, String username) async {
    if (!isAvailable()) return;

    await _firestore.collection('users').doc(uid).update({
      'username': username,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  /// Update last active timestamp
  Future<void> updateLastActive(String uid) async {
    if (!isAvailable()) return;

    await _firestore.collection('users').doc(uid).update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // ==================== TASKS ====================

  /// Save task to Firestore
  Future<void> saveTask(String userId, Task task) async {
    if (!isAvailable()) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  /// Get all tasks for user
  Stream<List<Task>> getUserTasks(String userId) {
    if (!isAvailable()) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data()))
          .toList();
    });
  }

  /// Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    if (!isAvailable()) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  /// Batch save multiple tasks
  Future<void> batchSaveTasks(String userId, List<Task> tasks) async {
    if (!isAvailable()) return;

    final batch = _firestore.batch();
    final tasksRef = _firestore.collection('users').doc(userId).collection('tasks');

    for (final task in tasks) {
      batch.set(tasksRef.doc(task.id), task.toMap());
    }

    await batch.commit();
  }

  // ==================== ROUTINES ====================

  /// Save routine
  Future<void> saveRoutine(String userId, Map<String, dynamic> routine) async {
    if (!isAvailable()) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('routines')
        .doc(routine['id'])
        .set(routine);
  }

  /// Get routines stream
  Stream<List<Map<String, dynamic>>> getUserRoutines(String userId) {
    if (!isAvailable()) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('routines')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // ==================== ANALYTICS ====================

  /// Save analytics data
  Future<void> saveAnalyticsData(String userId, Map<String, dynamic> data) async {
    if (!isAvailable()) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get analytics for date range
  Future<List<Map<String, dynamic>>> getAnalytics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!isAvailable()) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ==================== SYNC ====================

  /// Sync local data to Firebase
  Future<void> syncToFirebase(String userId, List<Task> localTasks) async {
    if (!isAvailable()) return;

    await batchSaveTasks(userId, localTasks);
  }
}
