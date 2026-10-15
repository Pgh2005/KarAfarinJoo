import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePhotoCleanupException implements Exception {
  final Object cause;

  const ProfilePhotoCleanupException(this.cause);

  @override
  String toString() =>
      'عکس جدید ذخیره شد، اما پاک‌کردن عکس قبلی ناموفق بود: $cause';
}

class ProfilePhotoService {
  static const bucketName = 'student-profile-photos';
  static const maxPhotoSizeBytes = 5 * 1024 * 1024;
  static const _maxSignedUrlAgeSeconds = 60 * 60;
  static const _signedUrlCacheDuration = Duration(minutes: 55);

  final SupabaseClient _supabase;
  final Map<String, _CachedPhotoUrl> _signedUrlCache = {};

  ProfilePhotoService(this._supabase);

  Future<String?> getDisplayUrl(String? avatarUrl) async {
    final path = avatarUrl?.trim();
    if (path == null || path.isEmpty) return null;

    if (_isWebUrl(path)) return path;

    final now = DateTime.now();
    final cached = _signedUrlCache[path];
    if (cached != null && cached.expiresAt.isAfter(now)) {
      return cached.url;
    }

    final urls = await getDisplayUrls([path]);
    return urls[path];
  }

  Future<Map<String, String?>> getDisplayUrls(
    Iterable<String?> avatarUrls,
  ) async {
    final paths = avatarUrls
        .map((url) => url?.trim())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toSet();
    final displayUrls = <String, String?>{};
    final pathsToSign = <String>[];
    final now = DateTime.now();

    for (final path in paths) {
      if (_isWebUrl(path)) {
        displayUrls[path] = path;
        continue;
      }

      final cached = _signedUrlCache[path];
      if (cached != null && cached.expiresAt.isAfter(now)) {
        displayUrls[path] = cached.url;
      } else {
        pathsToSign.add(path);
      }
    }

    if (pathsToSign.isEmpty) return displayUrls;

    final results = await _supabase.storage
        .from(bucketName)
        .createSignedUrlsResult(pathsToSign, _maxSignedUrlAgeSeconds);
    final cacheExpiry = now.add(_signedUrlCacheDuration);

    for (final result in results) {
      switch (result) {
        case SignedUrlSuccess(:final path, :final signedUrl):
          displayUrls[path] = signedUrl;
          _signedUrlCache[path] = _CachedPhotoUrl(signedUrl, cacheExpiry);
        case SignedUrlFailure(:final path):
          displayUrls[path] = null;
          _signedUrlCache[path] = _CachedPhotoUrl(null, cacheExpiry);
      }
    }

    for (final path in pathsToSign) {
      if (!displayUrls.containsKey(path)) {
        displayUrls[path] = null;
        _signedUrlCache[path] = _CachedPhotoUrl(null, cacheExpiry);
      }
    }

    return displayUrls;
  }

  bool _isWebUrl(String path) {
    final uri = Uri.tryParse(path);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<String> uploadOwnStudentPhoto(XFile image) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('برای بارگذاری عکس وارد حساب کاربری شوید.');
    }

    final profile = await _supabase
        .from('profiles')
        .select('role, avatar_url')
        .eq('id', userId)
        .maybeSingle();
    if (profile?['role'] != 'student') {
      throw Exception('بارگذاری عکس پروفایل فقط برای دانشجو مجاز است.');
    }

    final contentType = _getSupportedImageType(image);
    final fileLength = await image.length();
    if (fileLength > maxPhotoSizeBytes) {
      throw Exception('حجم عکس نباید بیشتر از ۵ مگابایت باشد.');
    }

    final bytes = await image.readAsBytes();
    if (bytes.length > maxPhotoSizeBytes) {
      throw Exception('حجم عکس نباید بیشتر از ۵ مگابایت باشد.');
    }

    final photoPath =
        '$userId/${DateTime.now().microsecondsSinceEpoch}-profile';
    await _supabase.storage
        .from(bucketName)
        .uploadBinary(
          photoPath,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            contentType: contentType,
          ),
        );

    await _supabase.rpc(
      'set_student_profile_photo',
      params: {'p_avatar_path': photoPath},
    );

    final oldAvatarUrl = (profile?['avatar_url'] as String?)?.trim();
    if (oldAvatarUrl != null &&
        _isManagedPhotoPath(oldAvatarUrl, userId) &&
        oldAvatarUrl != photoPath) {
      try {
        await _supabase.storage.from(bucketName).remove([oldAvatarUrl]);
        _signedUrlCache.remove(oldAvatarUrl);
      } on Exception catch (error) {
        throw ProfilePhotoCleanupException(error);
      }
    }

    return photoPath;
  }

  bool _isManagedPhotoPath(String? path, String userId) {
    if (path == null || path.isEmpty || path.startsWith('http')) return false;
    return path.startsWith('$userId/');
  }

  String _getSupportedImageType(XFile image) {
    final contentType = image.mimeType?.toLowerCase();
    if (contentType == 'image/jpeg') return 'image/jpeg';
    if (contentType == 'image/png') return 'image/png';
    if (contentType == 'image/webp') return 'image/webp';

    final extension = image.name.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw Exception('فرمت عکس باید JPG، PNG یا WebP باشد.'),
    };
  }
}

class _CachedPhotoUrl {
  final String? url;
  final DateTime expiresAt;

  const _CachedPhotoUrl(this.url, this.expiresAt);
}
