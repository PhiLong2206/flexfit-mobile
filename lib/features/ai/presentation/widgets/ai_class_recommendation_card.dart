import 'package:flutter/material.dart';

import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../gym/presentation/screens/explore_page.dart';
import '../../../booking/presentation/screens/booking_confirmation_page.dart';

class ClassPreviewBottomSheet extends StatelessWidget {
  const ClassPreviewBottomSheet({super.key, required this.fitnessClass});

  final FitnessClass fitnessClass;

  static Future<void> show(BuildContext context, FitnessClass fitnessClass) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ClassPreviewBottomSheet(fitnessClass: fitnessClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              fitnessClass.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${fitnessClass.branchName} - ${fitnessClass.categoryName}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFFF6B16),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(fitnessClass.startTime)} - ${_formatTime(fitnessClass.endTime)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFF6B16),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${fitnessClass.creditCost} Credit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (fitnessClass.description != null &&
                fitnessClass.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Mô tả',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fitnessClass.description!,
                style: const TextStyle(color: Colors.white70),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close preview
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExplorePage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Xem trong Khám phá'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context); // Close preview
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmationPage(
                            gymName:
                                fitnessClass.branchName, // Placeholder gym name
                            address: '',
                            branchName: fitnessClass.branchName,
                            rating: 5.0,
                            creditCost: fitnessClass.creditCost,
                            branchId: fitnessClass.branchId,
                            startTime: fitnessClass.startTime,
                            endTime: fitnessClass.endTime,
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B16),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đặt chỗ ngay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class AiClassRecommendationWidget extends StatelessWidget {
  const AiClassRecommendationWidget({super.key, required this.fitnessClass});

  final FitnessClass fitnessClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fitnessClass.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${fitnessClass.branchName} • ${_formatDate(fitnessClass.startTime)} • ${_formatTime(fitnessClass.startTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B16),
              backgroundColor: const Color(0xFFFF6B16).withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              ClassPreviewBottomSheet.show(context, fitnessClass);
            },
            child: const Text(
              'Xem lớp',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
