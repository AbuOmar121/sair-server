import 'package:sair_apis/src/domain/entities/report.dart';
import 'package:sair_apis/src/domain/repositories/report_repository.dart';
import 'package:sair_apis/src/persistence/app_backend.dart';

class ReportRepositoryImpl implements ReportRepository {
  Future<List<Report>> _readReports() async {
    final backend = await AppBackend.instance();
    return (await backend.list('reports')).map(Report.fromJson).toList();
  }

  @override
  Future<void> createReport(Report report) async {
    final backend = await AppBackend.instance();
    await backend.put('reports', report.id, report.toJson());
  }

  @override
  Future<Report?> getReportById(String id) async {
    final reports = await _readReports();
    try {
      return reports.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Report>> getReportsByCitizen(
    String citizenId, {
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    final reports = await _readReports();
    return reports.where((r) {
      if (r.citizenId != citizenId) return false;
      if (status != null && r.status != status) return false;
      if (from != null && r.createdAt.isBefore(from)) return false;
      if (to != null && r.createdAt.isAfter(to)) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<Report>> getReportsByZone(String zoneId) async {
    final reports = await _readReports();
    return reports.where((r) => r.zoneId == zoneId).toList();
  }

  @override
  Future<Report?> updateStatus(String id, String status) async {
    final backend = await AppBackend.instance();
    final existing = await getReportById(id);
    if (existing == null) return null;
    final report = existing;
    final updated = Report(
      id: report.id,
      citizenId: report.citizenId,
      officerId: report.officerId,
      zoneId: report.zoneId,
      lat: report.lat,
      lng: report.lng,
      address: report.address,
      accidentType: report.accidentType,
      description: report.description,
      occurredAt: report.occurredAt,
      locationSource: report.locationSource,
      mediaUrls: report.mediaUrls,
      status: status,
      createdAt: report.createdAt,
      updatedAt: DateTime.now(),
    );
    await backend.put('reports', updated.id, updated.toJson());
    return updated;
  }

  @override
  Future<Report?> appendMedia(String id, List<String> mediaUrls) async {
    final backend = await AppBackend.instance();
    final report = await getReportById(id);
    if (report == null) return null;
    final updated = Report(
      id: report.id,
      citizenId: report.citizenId,
      officerId: report.officerId,
      zoneId: report.zoneId,
      lat: report.lat,
      lng: report.lng,
      address: report.address,
      accidentType: report.accidentType,
      description: report.description,
      occurredAt: report.occurredAt,
      locationSource: report.locationSource,
      mediaUrls: [...report.mediaUrls, ...mediaUrls],
      status: report.status,
      createdAt: report.createdAt,
      updatedAt: DateTime.now(),
    );
    await backend.put('reports', updated.id, updated.toJson());
    return updated;
  }

  @override
  Future<List<Report>> getAllReports() async => _readReports();
}
