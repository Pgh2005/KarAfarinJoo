import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/features/profile/models/profile.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:karafarini/features/profile/providers/profile_photo_provider.dart';
import 'package:karafarini/features/profile/data/profile_photo_service.dart';

class ProfileAvatar extends ConsumerWidget {
  final String fullName;
  final String? avatarUrl;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;

  const ProfileAvatar({
    super.key,
    required this.fullName,
    required this.avatarUrl,
    this.radius = 24,
    this.backgroundColor = AppTheme.primaryLight,
    this.foregroundColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrlAsync = ref.watch(profilePhotoUrlProvider(avatarUrl));
    final imageUrl = imageUrlAsync.maybeWhen(
      data: (url) => url,
      orElse: () => null,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: imageUrl == null
          ? _initials()
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) => _initials(),
              ),
            ),
    );
  }

  Widget _initials() {
    final words = fullName.trim().split(RegExp(r'\s+'));
    final initials = words.where((word) => word.isNotEmpty).take(2).map(
      (word) => word[0],
    );
    final text = initials.join().toUpperCase();

    return Text(
      text.isEmpty ? '?' : text,
      style: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.65,
      ),
    );
  }
}

class EditableStudentProfileAvatar extends ConsumerStatefulWidget {
  final Profile profile;

  const EditableStudentProfileAvatar({super.key, required this.profile});

  @override
  ConsumerState<EditableStudentProfileAvatar> createState() =>
      _EditableStudentProfileAvatarState();
}

class _EditableStudentProfileAvatarState
    extends ConsumerState<EditableStudentProfileAvatar> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _chooseAndUploadPhoto() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;

      final photoPath = await ref
          .read(profilePhotoServiceProvider)
          .uploadOwnStudentPhoto(image);
      ref.invalidate(profilePhotoUrlProvider(photoPath));
      ref.invalidate(currentSessionProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عکس پروفایل با موفقیت ذخیره شد.')),
        );
      }
    } on ProfilePhotoCleanupException catch (error) {
      ref.invalidate(currentSessionProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ذخیرهٔ عکس پروفایل ناموفق بود: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfileAvatar(
          fullName: widget.profile.fullName,
          avatarUrl: widget.profile.avatarUrl,
          radius: 58,
          backgroundColor: Colors.white,
        ),
        Positioned(
          bottom: -2,
          left: -2,
          child: IconButton.filled(
            tooltip: _isUploading
                ? 'در حال انتخاب یا ذخیره عکس پروفایل'
                : 'افزودن یا تغییر عکس پروفایل',
            onPressed: _isUploading ? null : _chooseAndUploadPhoto,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
            icon: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.camera_alt_outlined),
          ),
        ),
      ],
    );
  }
}
