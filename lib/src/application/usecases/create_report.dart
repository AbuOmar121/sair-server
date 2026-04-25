import 'package:sair_apis/src/domain/entities/report.dart';
import 'package:sair_apis/src/domain/repositories/report_repository.dart';
import 'package:sair_apis/src/features/common/image_service.dart';

class CreateReportUseCase {
  final ReportRepository repo;
  final ImageService imageService;

  CreateReportUseCase(this.repo, {ImageService? imageService})
      : imageService = imageService ?? ImageService();

  Future<Report> execute({
    required String citizenId,
    required double lat,
    required double lng,
    required String description,
    required String accidentType,
    required DateTime occurredAt,
    required String locationSource,
    required List<String> platesNumber,
    List<List<int>>? mediaData,
  }) async {
    final now = DateTime.now();

    final List<String> mediaUrls = [];
    if (mediaData != null) {
      for (final data in mediaData) {
        final path = await imageService.saveImage(data);
        mediaUrls.add(path);
      }
    }

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
      mediaUrls: mediaUrls,
      status: 'submitted',
      createdAt: now,
      updatedAt: now,
      platesNumber: platesNumber,
    );

    await repo.createReport(report);
    return report;
  }
}
