import 'package:sair_apis/src/domain/entities/report.dart';
import 'package:sair_apis/src/domain/repositories/report_repository.dart';

class CreateReportUseCase {
  final ReportRepository repo;

  CreateReportUseCase(this.repo);

  Future<Report> execute({
    required String citizenId,
    required double lat,
    required double lng,
    required String description,
    required String accidentType,
    required DateTime occurredAt,
    required String locationSource,
  }) async {
    final now = DateTime.now();

    final report = Report(
      id: now.millisecondsSinceEpoch.toString(),
      citizenId: citizenId,
      officerId: 'officer_1',
      zoneId: 'zone_1',
      lat: lat,
      lng: lng,
      address: '',
      accidentType: accidentType,
      description: description,
      occurredAt: occurredAt,
      locationSource: locationSource,
      mediaUrls: const [],
      status: 'submitted',
      createdAt: now,
      updatedAt: now,
    );

    await repo.createReport(report);
    return report;
  }
}
