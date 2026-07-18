import 'dart:io';

import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../domain/repositories/partner_repository.dart';
import '../datasources/partner_remote_data_source.dart';
import '../models/partner_customer_model.dart';
import '../models/partner_dashboard_stats_model.dart';
import '../models/partner_promotion_model.dart';
import '../models/partner_revenue_report_model.dart';
import '../models/partner_review_model.dart';

class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerRemoteDataSource remoteDataSource;

  PartnerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PartnerDashboardStatsModel> getDashboardStats() {
    return remoteDataSource.getDashboardStats();
  }

  @override
  Future<List<Branch>> getBranches() async {
    return remoteDataSource.getBranches();
  }

  @override
  Future<List<FitnessClass>> getClasses() async {
    return remoteDataSource.getClasses();
  }

  @override
  Future<void> createClass(Map<String, dynamic> body) {
    return remoteDataSource.createClass(body);
  }

  @override
  Future<void> updateClass(String classId, Map<String, dynamic> body) {
    return remoteDataSource.updateClass(classId, body);
  }

  @override
  Future<void> deleteClass(String classId) {
    return remoteDataSource.deleteClass(classId);
  }

  @override
  Future<List<Gym>> getGyms() async {
    return remoteDataSource.getGyms();
  }

  @override
  Future<void> updateGym(String gymId, Map<String, dynamic> body) {
    return remoteDataSource.updateGym(gymId, body);
  }

  @override
  Future<List<PartnerCustomerModel>> getCustomers() {
    return remoteDataSource.getCustomers();
  }

  @override
  Future<PartnerRevenueReportModel> getRevenueReport() {
    return remoteDataSource.getRevenueReport();
  }

  @override
  Future<List<PartnerReviewModel>> getReviews(String gymId) {
    return remoteDataSource.getReviews(gymId);
  }

  // Staff
  @override
  Future<void> assignStaff(String branchId, String email) {
    return remoteDataSource.assignStaff(branchId, email);
  }

  @override
  Future<void> removeStaff(String branchId, String staffId) {
    return remoteDataSource.removeStaff(branchId, staffId);
  }

  // Branch CRUD
  @override
  Future<void> createBranch(Map<String, dynamic> body) {
    return remoteDataSource.createBranch(body);
  }

  @override
  Future<void> updateBranch(String branchId, Map<String, dynamic> body) {
    return remoteDataSource.updateBranch(branchId, body);
  }

  @override
  Future<void> deleteBranch(String branchId) {
    return remoteDataSource.deleteBranch(branchId);
  }

  // Multipart uploads
  @override
  Future<void> createBranchWithImage(Map<String, String> fields, File imageFile) {
    return remoteDataSource.createBranchWithImage(fields, imageFile);
  }

  @override
  Future<void> updateBranchWithImage(String branchId, Map<String, String> fields, File imageFile) {
    return remoteDataSource.updateBranchWithImage(branchId, fields, imageFile);
  }

  @override
  Future<void> updateGymWithImage(String gymId, Map<String, String> fields, File imageFile) {
    return remoteDataSource.updateGymWithImage(gymId, fields, imageFile);
  }

  @override
  Future<void> createClassWithImage(Map<String, String> fields, File imageFile) {
    return remoteDataSource.createClassWithImage(fields, imageFile);
  }

  @override
  Future<void> updateClassWithImage(String classId, Map<String, String> fields, File imageFile) {
    return remoteDataSource.updateClassWithImage(classId, fields, imageFile);
  }

  // Promotions
  @override
  Future<List<PartnerPromotionModel>> getPromotions() {
    return remoteDataSource.getPromotions();
  }

  @override
  Future<void> createPromotion(Map<String, dynamic> body) {
    return remoteDataSource.createPromotion(body);
  }

  @override
  Future<void> deletePromotion(String promotionId) {
    return remoteDataSource.deletePromotion(promotionId);
  }
}
