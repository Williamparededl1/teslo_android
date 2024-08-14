import 'package:image_picker/image_picker.dart';
import 'package:teslo_android/features/shared/infrastructure/services/camera_gallery_service.dart';

class CameraGalleryServiceImpl extends CameraGalleryService {
  final ImagePicker picker = ImagePicker();
  @override
  Future<String?> selectPhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return null;
    return image.path;
  }

  @override
  Future<String?> takePhoto() async {
    final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear);
    if (photo == null) return null;
    return photo.path;
  }

  @override
  Future<List<String>?> selectMultiplePhotos() async {
    final List<XFile> medias = await picker.pickMultipleMedia(limit: 3);
    if (medias.isEmpty) return null;
    List<String> paths = medias.map((media) => media.path).toList();
    return paths;
  }
}
