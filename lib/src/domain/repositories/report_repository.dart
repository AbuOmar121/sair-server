import 'package:sair_apis/src/domain/entities/report.dart';

abstract class ReportRepository {
  Future<void> createReport(Report report);

  Future<List<Report>> getReportsByCitizen(
    String citizenId, {
    String? status,
    DateTime? from,
    DateTime? to,
  });

  Future<List<Report>> getReportsByZone(String zoneId);

  Future<Report?> getReportById(String id);

  Future<Report?> updateStatus(String id, String status);
  Future<Report?> appendMedia(String id, List<String> mediaUrls);
  Future<List<Report>> getAllReports();
}
