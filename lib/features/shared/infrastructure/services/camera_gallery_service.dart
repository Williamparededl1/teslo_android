abstract class CameraGalleryService {
  Future<String?> takePhoto();
  Future<String?> selectPhoto();
  Future<List<String>?> selectMultiplePhotos();
}
