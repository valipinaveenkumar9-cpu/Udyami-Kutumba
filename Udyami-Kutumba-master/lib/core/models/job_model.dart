class JobModel {
  final String jobId;
  final String title;
  final String companyName;
  final String category;
  final String location;
  final String city;
  final String ward;
  final String salaryRange;
  final String jobType;
  final int openings;
  final String experience;
  final String requirements;
  final String status;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  JobModel({
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.category,
    required this.location,
    required this.city,
    required this.ward,
    required this.salaryRange,
    required this.jobType,
    required this.openings,
    required this.experience,
    required this.requirements,
    required this.status,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['jobId'] ?? '',
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      ward: json['ward'] ?? '',
      salaryRange: json['salaryRange'] ?? '',
      jobType: json['jobType'] ?? '',
      openings: json['openings'] ?? 0,
      experience: json['experience'] ?? '',
      requirements: json['requirements'] ?? '',
      status: json['status'] ?? 'OPEN',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
