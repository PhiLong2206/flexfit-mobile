import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';

/// Widget chọn ảnh từ gallery.
/// - [currentUrl]: URL ảnh hiện tại (từ server).
/// - [pickedFile]: file ảnh mới được chọn từ thiết bị (chưa upload).
/// - [onFilePicked]: callback khi user chọn file mới.
/// - [onClear]: callback khi user xóa ảnh đã chọn (về null).
class ImagePickerField extends StatefulWidget {
  final String? currentUrl;
  final File? pickedFile;
  final ValueChanged<File?> onFilePicked;
  final VoidCallback? onClear;

  const ImagePickerField({
    super.key,
    this.currentUrl,
    this.pickedFile,
    required this.onFilePicked,
    this.onClear,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pick() async {
    try {
      setState(() => _isLoading = true);
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );
      if (xFile == null) return;
      widget.onFilePicked(File(xFile.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPickedFile = widget.pickedFile != null;
    final hasCurrentUrl = widget.currentUrl != null && widget.currentUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Preview ----
        GestureDetector(
          onTap: _isLoading ? null : _pick,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasPickedFile
                    ? AppConstants.primaryColor
                    : AppConstants.borderColor,
                width: hasPickedFile ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: _buildPreview(hasPickedFile, hasCurrentUrl),
          ),
        ),
        const SizedBox(height: 10),

        // ---- Buttons ----
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                  side: const BorderSide(color: AppConstants.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: _isLoading ? null : _pick,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppConstants.primaryColor,
                        ),
                      )
                    : const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(
                  _isLoading
                      ? 'Đang xử lý...'
                      : hasPickedFile
                          ? 'Thay đổi ảnh'
                          : 'Chọn từ thiết bị',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (hasPickedFile || hasCurrentUrl) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                tooltip: 'Xóa ảnh',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPreview(bool hasPickedFile, bool hasCurrentUrl) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      );
    }

    // Ảnh mới chọn từ thiết bị
    if (hasPickedFile) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(widget.pickedFile!, fit: BoxFit.cover),
          Positioned(
            top: 6, right: 6,
            child: _badge('Ảnh mới', AppConstants.primaryColor),
          ),
        ],
      );
    }

    // Ảnh hiện tại từ server
    if (hasCurrentUrl) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.currentUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
            errorBuilder: (_, __, ___) => _noImage(),
          ),
          Positioned(
            top: 6, right: 6,
            child: _badge('Ảnh hiện tại', Colors.grey),
          ),
        ],
      );
    }

    // Chưa có ảnh
    return _noImage();
  }

  Widget _noImage() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, color: AppConstants.textSecondary, size: 40),
        SizedBox(height: 8),
        Text('Nhấn để chọn ảnh', style: TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
