// gap_repository.dart

import 'package:cobit/models/gap.dart';

abstract class GapRepository {
  Future<List<Gap>> getGapsForAudit(String auditId);
  Future<Gap?> getGapById(String id); // 👈 ajout
  Future<Gap> createGap(Gap gap);
  Future<Gap> updateGap(Gap gap);
  Future<void> deleteGap(String gapId);
}

/// Implémentation in-memory / mock pour commencer
class InMemoryGapRepository implements GapRepository {
  final List<Gap> _gaps = [];

  @override
  Future<List<Gap>> getGapsForAudit(String auditId) async {
    return _gaps.where((g) => g.auditId == auditId).toList();
  }

  Future<Gap?> getGapById(String id) async {
    // 👈 implémentation
    try {
      return _gaps.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Gap> createGap(Gap gap) async {
    _gaps.add(gap);
    return gap;
  }

  @override
  Future<Gap> updateGap(Gap gap) async {
    final index = _gaps.indexWhere((g) => g.id == gap.id);
    if (index != -1) {
      _gaps[index] = gap;
    }
    return gap;
  }

  @override
  Future<void> deleteGap(String gapId) async {
    _gaps.removeWhere((g) => g.id == gapId);
  }
}
