import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/staff_booking.dart';
import '../../domain/entities/staff_customer.dart';
import '../providers/staff_customers_provider.dart';

class StaffCustomersPage extends StatelessWidget {
  const StaffCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<StaffCustomersProvider>()..load(),
      child: const _CustomersView(),
    );
  }
}

class _CustomersView extends StatelessWidget {
  const _CustomersView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffCustomersProvider>();
    if (provider.isLoading && provider.visibleCustomers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.visibleCustomers.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }
    final customers = provider.visibleCustomers;
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khách hàng',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Khách hàng có lịch đặt tại chi nhánh bạn được phân công.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: provider.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'Tìm theo tên hoặc email',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (customers.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 1100
                      ? 3
                      : width >= 680
                      ? 2
                      : 1;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CustomerCard(
                        customer: customers[index],
                        onTap: () =>
                            _showCustomerDetails(context, customers[index]),
                      ),
                      childCount: customers.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 190,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, StaffCustomer customer) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(22),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              customer.fullName.isEmpty ? 'Khách hàng' : customer.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              customer.email.isEmpty ? 'Chưa có email' : customer.email,
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            Text(
              'Lịch đặt liên quan (${customer.bookings.length})',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...customer.bookings.map(_BookingRow.new),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap});

  final StaffCustomer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF263244)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF163322),
                    child: Icon(Icons.person_rounded, color: Color(0xFF22C55E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customer.fullName.isEmpty
                          ? 'Khách hàng'
                          : customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                customer.email.isEmpty ? 'Chưa có email' : customer.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF94A3B8)),
              ),
              const Spacer(),
              Row(
                children: [
                  Text('${customer.bookings.length} lịch đặt'),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow(this.booking);

  final StaffBooking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0B1220),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          booking.isClassBooking
              ? Icons.groups_2_rounded
              : Icons.fitness_center_rounded,
          color: const Color(0xFF22C55E),
        ),
        title: Text(booking.bookingCode),
        subtitle: Text(
          '${booking.branchName} • ${_dateTime(booking.startTime)}',
        ),
        trailing: Text(
          booking.checkInStatus,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_off_rounded, size: 54, color: Color(0xFF64748B)),
            SizedBox(height: 14),
            Text(
              'Không có khách hàng phù hợp.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Danh sách được tạo từ lịch đặt thực tế tại chi nhánh.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không thể tải khách hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateTime(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
