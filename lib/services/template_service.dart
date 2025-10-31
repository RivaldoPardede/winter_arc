import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/workout_template.dart';

class TemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user's templates collection
  CollectionReference _userTemplatesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('templates');
  }

  /// Save a new template
  Future<void> saveTemplate(WorkoutTemplate template) async {
    try {
      await _userTemplatesCollection(template.userId)
          .doc(template.id)
          .set(template.toJson());
      debugPrint('✅ Template "${template.name}" saved');
    } catch (e) {
      debugPrint('❌ Error saving template: $e');
      rethrow;
    }
  }

  /// Get all templates for a user
  Future<List<WorkoutTemplate>> getTemplates(String userId) async {
    try {
      final snapshot = await _userTemplatesCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting templates: $e');
      return [];
    }
  }

  /// Stream of templates (real-time)
  Stream<List<WorkoutTemplate>> templatesStream(String userId) {
    return _userTemplatesCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Delete a template
  Future<void> deleteTemplate(String userId, String templateId) async {
    try {
      await _userTemplatesCollection(userId).doc(templateId).delete();
      debugPrint('✅ Template deleted');
    } catch (e) {
      debugPrint('❌ Error deleting template: $e');
      rethrow;
    }
  }

  /// Update a template
  Future<void> updateTemplate(WorkoutTemplate template) async {
    try {
      await _userTemplatesCollection(template.userId)
          .doc(template.id)
          .update(template.toJson());
      debugPrint('✅ Template "${template.name}" updated');
    } catch (e) {
      debugPrint('❌ Error updating template: $e');
      rethrow;
    }
  }
}
