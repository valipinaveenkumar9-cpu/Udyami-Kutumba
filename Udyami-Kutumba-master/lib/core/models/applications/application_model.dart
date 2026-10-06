import '../job_model.dart';

class ApplicationModel {
  final String applicationId;
  final String jobId;
  final String fullName;
  final String email;
  final String mobile;
  final String currentCity;
  final String qualification;
  final String experience;
  final String currentCompany;
  final String currentSalary;
  final String expectedSalary;
  final String resumeUrl;
  final String coverLetter;
  final String status;
  final String? createdAt;
  final JobModel? job;

  ApplicationModel({
    required this.applicationId,
    required this.jobId,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.currentCity,
    required this.qualification,
    required this.experience,
    required this.currentCompany,
    required this.currentSalary,
    required this.expectedSalary,
    required this.resumeUrl,
    required this.coverLetter,
    required this.status,
    this.createdAt,
    this.job,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId'] ?? json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      currentCity: json['currentCity'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? '',
      currentCompany: json['currentCompany'] ?? '',
      currentSalary: json['currentSalary'] ?? '',
      expectedSalary: json['expectedSalary'] ?? '',
      resumeUrl: json['resumeUrl'] ?? '',
      coverLetter: json['coverLetter'] ?? '',
      status: json['status'] ?? 'APPLIED',
      createdAt: json['createdAt'],
      job: json['job'] != null ? JobModel.fromJson(json['job']) : null,
    );
  }
}
