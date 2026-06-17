class FitnessClass {
  const FitnessClass({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    this.coachName,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.creditCost,
    this.difficultyLevel,
    this.caloriesBurnEstimate,
    this.thumbnailUrl,
    required this.status,
  });

  final String id;
  final String branchId;
  final String branchName;
  final String categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final String? coachName;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int creditCost;
  final String? difficultyLevel;
  final int? caloriesBurnEstimate;
  final String? thumbnailUrl;
  final String status;
}
