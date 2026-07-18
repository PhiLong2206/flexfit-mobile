import 'package:flutter/material.dart';

import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../data/models/partner_customer_model.dart';
import '../../data/models/partner_dashboard_stats_model.dart';
import '../../data/models/partner_promotion_model.dart';
import '../../data/models/partner_revenue_report_model.dart';
import '../../data/models/partner_review_model.dart';
import '../../domain/repositories/partner_repository.dart';
import '../../domain/usecases/create_class_usecase.dart';
import '../../domain/usecases/delete_class_usecase.dart';
import '../../domain/usecases/get_partner_branches_usecase.dart';
import '../../domain/usecases/get_partner_classes_usecase.dart';
import '../../domain/usecases/get_partner_customers_usecase.dart';
import '../../domain/usecases/get_partner_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_partner_gyms_usecase.dart';
import '../../domain/usecases/get_partner_reviews_usecase.dart';

class PartnerProvider extends ChangeNotifier {
  final GetPartnerDashboardStatsUseCase getPartnerDashboardStatsUseCase;
  final GetPartnerBranchesUseCase getPartnerBranchesUseCase;
  final GetPartnerClassesUseCase getPartnerClassesUseCase;
  final CreateClassUseCase createClassUseCase;
  final DeleteClassUseCase deleteClassUseCase;
  final GetPartnerGymsUseCase getPartnerGymsUseCase;
  final GetPartnerCustomersUseCase getPartnerCustomersUseCase;
  final GetPartnerReviewsUseCase getPartnerReviewsUseCase;
  final PartnerRepository partnerRepository;

  PartnerProvider({
    required this.getPartnerDashboardStatsUseCase,
    required this.getPartnerBranchesUseCase,
    required this.getPartnerClassesUseCase,
    required this.createClassUseCase,
    required this.deleteClassUseCase,
    required this.getPartnerGymsUseCase,
    required this.getPartnerCustomersUseCase,
    required this.getPartnerReviewsUseCase,
    required this.partnerRepository,
  });

  bool _isLoadingStats = false;
  bool _isLoadingBranches = false;
  bool _isLoadingClasses = false;
  bool _isLoadingGyms = false;
  bool _isLoadingCustomers = false;
  bool _isLoadingRevenue = false;
  bool _isLoadingReviews = false;
  bool _isLoadingPromotions = false;
  bool _isCreatingClass = false;
  bool _isDeletingClass = false;
  bool _isSubmittingAction = false;
  String? _errorMessage;

  PartnerDashboardStatsModel? _dashboardStats;
  List<Branch> _branches = [];
  List<FitnessClass> _classes = [];
  List<Gym> _gyms = [];
  List<PartnerCustomerModel> _customers = [];
  PartnerRevenueReportModel? _revenueReport;
  List<PartnerReviewModel> _reviews = [];
  List<PartnerPromotionModel> _promotions = [];

  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingBranches => _isLoadingBranches;
  bool get isLoadingClasses => _isLoadingClasses;
  bool get isLoadingGyms => _isLoadingGyms;
  bool get isLoadingCustomers => _isLoadingCustomers;
  bool get isLoadingRevenue => _isLoadingRevenue;
  bool get isLoadingReviews => _isLoadingReviews;
  bool get isLoadingPromotions => _isLoadingPromotions;
  bool get isCreatingClass => _isCreatingClass;
  bool get isDeletingClass => _isDeletingClass;
  bool get isSubmittingAction => _isSubmittingAction;
  String? get errorMessage => _errorMessage;

  PartnerDashboardStatsModel? get dashboardStats => _dashboardStats;
  List<Branch> get branches => _branches;
  List<FitnessClass> get classes => _classes;
  List<Gym> get gyms => _gyms;
  List<PartnerCustomerModel> get customers => _customers;
  PartnerRevenueReportModel? get revenueReport => _revenueReport;
  List<PartnerReviewModel> get reviews => _reviews;
  List<PartnerPromotionModel> get promotions => _promotions;

  Future<void> fetchAllData() async {
    _errorMessage = null;
    notifyListeners();

    await Future.wait([
      fetchDashboardStats(notify: false),
      fetchBranches(notify: false),
      fetchClasses(notify: false),
      fetchGyms(notify: false),
      fetchCustomers(notify: false),
      fetchRevenue(notify: false),
      fetchPromotions(notify: false),
    ]);

    await fetchReviewsForAllGyms(notify: false);

    notifyListeners();
  }

  Future<void> fetchDashboardStats({bool notify = true}) async {
    _isLoadingStats = true;
    if (notify) notifyListeners();

    try {
      _dashboardStats = await getPartnerDashboardStatsUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingStats = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchBranches({bool notify = true}) async {
    _isLoadingBranches = true;
    if (notify) notifyListeners();

    try {
      _branches = await getPartnerBranchesUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingBranches = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchClasses({bool notify = true}) async {
    _isLoadingClasses = true;
    if (notify) notifyListeners();

    try {
      final list = await getPartnerClassesUseCase();
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
      _classes = list;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingClasses = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchGyms({bool notify = true}) async {
    _isLoadingGyms = true;
    if (notify) notifyListeners();

    try {
      _gyms = await getPartnerGymsUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingGyms = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchCustomers({bool notify = true}) async {
    _isLoadingCustomers = true;
    if (notify) notifyListeners();

    try {
      _customers = await getPartnerCustomersUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCustomers = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchRevenue({bool notify = true}) async {
    _isLoadingRevenue = true;
    if (notify) notifyListeners();

    try {
      _revenueReport = await partnerRepository.getRevenueReport();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingRevenue = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchPromotions({bool notify = true}) async {
    _isLoadingPromotions = true;
    if (notify) notifyListeners();

    try {
      _promotions = await partnerRepository.getPromotions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingPromotions = false;
      if (notify) notifyListeners();
    }
  }

  Future<void> fetchReviewsForAllGyms({bool notify = true}) async {
    _isLoadingReviews = true;
    if (notify) notifyListeners();

    try {
      if (_gyms.isEmpty) {
        _reviews = [];
        return;
      }

      final List<PartnerReviewModel> allReviews = [];
      final results = await Future.wait(
        _gyms.map((gym) => getPartnerReviewsUseCase(gym.id).catchError((_) => <PartnerReviewModel>[])),
      );

      for (var i = 0; i < _gyms.length; i++) {
        final gymName = _gyms[i].name;
        final gymReviews = results[i];
        for (final r in gymReviews) {
          allReviews.add(
            PartnerReviewModel(
              reviewId: r.reviewId,
              rating: r.rating,
              comment: r.comment,
              customerName: r.customerName,
              gymName: r.gymName.isEmpty ? gymName : r.gymName,
              className: r.className,
              createdAt: r.createdAt,
            ),
          );
        }
      }

      allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _reviews = allReviews;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingReviews = false;
      if (notify) notifyListeners();
    }
  }

  // Class CRUD operations
  Future<void> createClass(Map<String, dynamic> body) async {
    _isCreatingClass = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await createClassUseCase(body);
      await fetchClasses(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isCreatingClass = false;
      notifyListeners();
    }
  }

  Future<void> updateClass(String classId, Map<String, dynamic> body) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.updateClass(classId, body);
      await fetchClasses(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  Future<void> deleteClass(String classId) async {
    _isDeletingClass = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await deleteClassUseCase(classId);
      await fetchClasses(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isDeletingClass = false;
      notifyListeners();
    }
  }

  // Staff operations
  Future<void> assignStaff(String branchId, String email) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.assignStaff(branchId, email);
      await fetchBranches(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  Future<void> removeStaff(String branchId, String staffId) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.removeStaff(branchId, staffId);
      await fetchBranches(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  // Branch CRUD operations
  Future<void> createBranch(Map<String, dynamic> body) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.createBranch(body);
      await fetchBranches(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  Future<void> updateBranch(String branchId, Map<String, dynamic> body) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.updateBranch(branchId, body);
      await fetchBranches(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  Future<void> deleteBranch(String branchId) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.deleteBranch(branchId);
      await fetchBranches(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  // Gym branding updates
  Future<void> updateGym(String gymId, Map<String, dynamic> body) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.updateGym(gymId, body);
      await fetchGyms(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  // Promotions management
  Future<void> createPromotion(Map<String, dynamic> body) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.createPromotion(body);
      await fetchPromotions(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }

  Future<void> deletePromotion(String promotionId) async {
    _isSubmittingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await partnerRepository.deletePromotion(promotionId);
      await fetchPromotions(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmittingAction = false;
      notifyListeners();
    }
  }
}
