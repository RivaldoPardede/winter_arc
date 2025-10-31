import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:winter_arc/models/exercise.dart';

class CustomExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the custom exercises collection for a specific user
  CollectionReference _getUserExercisesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('customExercises');
  }

  // Stream of custom exercises for a user
  Stream<List<Exercise>> getCustomExercises(String userId) {
    return _getUserExercisesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Exercise.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Add a new custom exercise
  Future<void> addCustomExercise(String userId, Exercise exercise) async {
    await _getUserExercisesCollection(userId).doc(exercise.id).set(exercise.toJson());
  }

  // Update an existing custom exercise
  Future<void> updateCustomExercise(String userId, Exercise exercise) async {
    await _getUserExercisesCollection(userId).doc(exercise.id).update(exercise.toJson());
  }

  // Delete a custom exercise
  Future<void> deleteCustomExercise(String userId, String exerciseId) async {
    await _getUserExercisesCollection(userId).doc(exerciseId).delete();
  }

  // Get all exercises (default + custom) for a user
  Future<List<Exercise>> getAllExercises(String userId) async {
    final customExercises = await _getUserExercisesCollection(userId).get();
    final custom = customExercises.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Exercise.fromJson({...data, 'id': doc.id});
    }).toList();
    
    return [...Exercise.defaultExercises, ...custom];
  }

  // Stream of all exercises (default + custom)
  Stream<List<Exercise>> getAllExercisesStream(String userId) {
    return getCustomExercises(userId).map((customExercises) {
      return [...Exercise.defaultExercises, ...customExercises];
    });
  }
}
