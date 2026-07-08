import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/partner_customer_model.dart';
import '../../providers/partner_provider.dart';

class PartnerCustomersSubpage extends StatelessWidget {
  final PartnerProvider provider;

  const PartnerCustomersSubpage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final customers = provider.customers;

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      onRefresh: () => provider.fetchCustomers(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách hội viên',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Tổng số: ${customers.length}',
                  style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Danh sách những khách hàng/hội viên đã đăng ký tham gia lớp hoặc mua gói.',
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            _buildCustomersList(customers, provider.isLoadingCustomers),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersList(List<PartnerCustomerModel> customers, bool isLoading) {
    if (isLoading && customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }
    if (customers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
        ),
        child: const Column(
          children: [
            Icon(Icons.people, color: AppConstants.textSecondary, size: 40),
            SizedBox(height: 12),
            Text(
              'Chưa có hội viên nào đăng ký.',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final joinDateStr = customer.joinDate != null
            ? DateFormat('dd/MM/yyyy').format(customer.joinDate!)
            : 'N/A';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                radius: 20,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'M',
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Email: ${customer.email}',
                      style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SĐT: ${customer.phone}',
                      style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Join date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Ngày tham gia',
                    style: TextStyle(fontSize: 10, color: AppConstants.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    joinDateStr,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
