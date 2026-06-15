import 'package:get/get.dart';
import '../../../data/models/need_based_post_model.dart';
import '../../../services/tolet_services.dart';

/// Controller for need-based posts (tenant needs → landlord contacts).
class NeedBasedPostController extends GetxController {
  final NeedBasedPostService _postService = NeedBasedPostService();

  // Form fields
  final RxInt bedrooms = 1.obs;
  final RxInt bathrooms = 1.obs;
  final RxString propertyType = 'bachelor'.obs;
  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString upazila = ''.obs;
  final RxString area = ''.obs;
  final RxDouble minBudget = 0.0.obs;
  final RxDouble maxBudget = 0.0.obs;
  final RxString description = ''.obs;

  // Posts
  final RxList<NeedBasedPostModel> posts = <NeedBasedPostModel>[].obs;
  final RxList<NeedBasedPostModel> userPosts = <NeedBasedPostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;

  /// Load active need-based posts with filters.
  void loadPosts({
    String? division,
    String? district,
    String? propertyType,
  }) {
    isLoading.value = true;
    _postService
        .getActivePosts(
      division: division,
      district: district,
      propertyType: propertyType,
    ).listen((results) {
      posts.value = results;
      isLoading.value = false;
    });
  }

  /// Load current user's own posts.
  void loadUserPosts(String userId) {
    _postService.getUserPosts(userId).listen((results) {
      userPosts.value = results;
    });
  }

  /// Create a new need-based post.
  Future<bool> createPost(String userId, String userName, String userPhone) async {
    error.value = '';
    isSubmitting.value = true;

    try {
      final post = NeedBasedPostModel(
        id: '',
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        bedrooms: bedrooms.value,
        bathrooms: bathrooms.value,
        propertyType: propertyType.value,
        division: division.value,
        district: district.value,
        upazila: upazila.value,
        area: area.value,
        minBudget: minBudget.value,
        maxBudget: maxBudget.value,
        description: description.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _postService.createPost(post);
      isSubmitting.value = false;
      return true;
    } catch (e) {
      error.value = e.toString();
      isSubmitting.value = false;
      return false;
    }
  }

  /// Close a post.
  Future<void> closePost(String postId) async {
    await _postService.closePost(postId);
  }

  /// Reset form.
  void resetForm() {
    bedrooms.value = 1;
    bathrooms.value = 1;
    propertyType.value = 'bachelor';
    division.value = '';
    district.value = '';
    upazila.value = '';
    area.value = '';
    minBudget.value = 0.0;
    maxBudget.value = 0.0;
    description.value = '';
    error.value = '';
  }

  @override
  void onClose() {
    super.onClose();
  }
}