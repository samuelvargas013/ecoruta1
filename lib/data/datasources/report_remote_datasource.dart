import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/exceptions.dart';
import '../models/report_model.dart';

/// Acceso directo a Firestore (datos) y Firebase Storage (fotos)
/// para el módulo de reportes (F-02, F-03, F-04).
abstract class ReportRemoteDataSource {
  Future<ReportModel> createReport({
    required String authorId,
    required String authorName,
    required MaterialType material,
    required double latitude,
    required double longitude,
    required String address,
    required List<Uint8List> photos,
    String? descriptionText,
  });

  Stream<List<ReportModel>> watchActiveReports();
  Stream<List<ReportModel>> watchReportsByAuthor(String authorId);
  Future<void> markAsCollected(String reportId, String recyclerId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ReportRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection(FirestorePaths.reports);

  @override
  Future<ReportModel> createReport({
    required String authorId,
    required String authorName,
    required MaterialType material,
    required double latitude,
    required double longitude,
    required String address,
    required List<Uint8List> photos,
    String? descriptionText,
  }) async {
    try {
      final docRef = _reports.doc();

      // 1) Subir fotos a Storage (putData funciona en web, Android e iOS).
      final List<String> urls = [];
      for (var i = 0; i < photos.length; i++) {
        final ref = _storage.ref().child('reports/${docRef.id}/photo_$i.jpg');
        final snap = await ref.putData(
          photos[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );
        urls.add(await snap.ref.getDownloadURL());
      }

      // 2) Guardar documento en Firestore.
      final data = ReportModel.toCreateMap(
        authorId: authorId,
        authorName: authorName,
        material: material,
        latitude: latitude,
        longitude: longitude,
        address: address,
        photoUrls: urls,
        descriptionText: descriptionText,
      );
      await docRef.set(data);

      // 3) Gamificación simple (F-05): +10 puntos por reporte.
      await _firestore
          .collection(FirestorePaths.users)
          .doc(authorId)
          .update({'points': FieldValue.increment(10)});

      final saved = await docRef.get();
      return ReportModel.fromDoc(saved);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'No se pudo crear el reporte.');
    }
  }

  @override
  /// Stream de reportes PENDIENTES (los que se pintan en el mapa, F-03).
  /// snapshots() = escucha en tiempo real: si un vecino crea un reporte,
  /// aparece en el mapa del reciclador sin refrescar.
  Stream<List<ReportModel>> watchActiveReports() {
    return _reports
        .where('status', isEqualTo: ReportStatus.pendiente.id)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map(ReportModel.fromDoc).toList());
  }

  @override
  /// Stream de los reportes de un autor específico ("Mis reportes").
  Stream<List<ReportModel>> watchReportsByAuthor(String authorId) {
    return _reports
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map(ReportModel.fromDoc).toList());
  }

  @override
  /// F-04: cambia el estado a "recogido" y registra qué reciclador
  /// lo recogió y cuándo (hora del servidor).
  Future<void> markAsCollected(String reportId, String recyclerId) async {
    try {
      await _reports.doc(reportId).update({
        'status': ReportStatus.recogido.id,
        'collectedBy': recyclerId,
        'collectedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'No se pudo actualizar el reporte.');
    }
  }
}
