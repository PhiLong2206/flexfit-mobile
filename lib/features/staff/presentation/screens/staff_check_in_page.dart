import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/staff_booking.dart';
import '../../domain/entities/staff_check_in_log.dart';
import '../providers/staff_check_in_provider.dart';
import '../providers/staff_dashboard_provider.dart';

class StaffCheckInPage extends StatelessWidget {
  const StaffCheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<StaffCheckInProvider>()..refresh(),
      child: const _StaffCheckInView(),
    );
  }
}

class _StaffCheckInView extends StatefulWidget {
  const _StaffCheckInView();

  @override
  State<_StaffCheckInView> createState() => _StaffCheckInViewState();
}

class _StaffCheckInViewState extends State<_StaffCheckInView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkIn() async {
    final completed = await context
        .read<StaffCheckInProvider>()
        .checkInSelectedBooking();
    if (!mounted || !completed) return;
    _codeController.clear();
    await context.read<StaffDashboardProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1050;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-in khách hàng',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Xác minh lịch đặt và ghi nhận khách hàng vào tập.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 24),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _verificationCard()),
                      const SizedBox(width: 20),
                      const Expanded(flex: 4, child: _TodayHistoryCard()),
                    ],
                  )
                else ...[
                  _verificationCard(),
                  const SizedBox(height: 20),
                  const _TodayHistoryCard(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _verificationCard() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xác minh Check-in',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Chọn phương thức đọc mã QR hoặc nhập tay',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.keyboard_rounded), text: 'Nhập mã'),
              Tab(icon: Icon(Icons.camera_alt_rounded), text: 'Camera'),
              Tab(icon: Icon(Icons.upload_file_rounded), text: 'Tải ảnh'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 520,
            child: TabBarView(
              children: [
                _ManualCodeTab(
                  controller: _codeController,
                  onCheckIn: _checkIn,
                ),
                _CameraQrTab(onCheckIn: _checkIn),
                _UploadQrTab(onCheckIn: _checkIn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualCodeTab extends StatelessWidget {
  const _ManualCodeTab({required this.controller, required this.onCheckIn});

  final TextEditingController controller;
  final Future<void> Function() onCheckIn;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffCheckInProvider>();
    final booking = provider.selectedBooking;
    return ListView(
      padding: const EdgeInsets.only(top: 4),
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: provider.isLoading
              ? null
              : (_) => provider.lookupBooking(controller.text),
          decoration: const InputDecoration(
            labelText: 'Mã đặt lịch',
            hintText: 'Nhập mã booking',
            prefixIcon: Icon(Icons.confirmation_number_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => provider.lookupBooking(controller.text),
          icon: provider.isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search_rounded),
          label: const Text('Tra cứu'),
        ),
        if (provider.errorMessage != null) ...[
          const SizedBox(height: 14),
          _MessageBanner(
            message: provider.errorMessage!,
            color: Colors.redAccent,
            icon: Icons.error_outline_rounded,
          ),
        ],
        if (provider.successMessage != null) ...[
          const SizedBox(height: 14),
          _MessageBanner(
            message: provider.successMessage!,
            color: const Color(0xFF22C55E),
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
        if (booking != null) ...[
          const SizedBox(height: 16),
          _BookingDetailCard(booking: booking),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: booking.isCheckedIn || provider.isCheckingIn
                ? null
                : onCheckIn,
            icon: provider.isCheckingIn
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.how_to_reg_rounded),
            label: Text(
              booking.isCheckedIn
                  ? 'Đã check-in'
                  : booking.isClassBooking
                  ? 'Check-in lớp học'
                  : 'Check-in phòng Gym',
            ),
          ),
        ],
      ],
    );
  }
}

class _BookingDetailCard extends StatelessWidget {
  const _BookingDetailCard({required this.booking});

  final StaffBooking booking;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263244)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow('Khách hàng', booking.userFullName),
            _DetailRow('Email', booking.userEmail),
            _DetailRow('Mã đặt lịch', booking.bookingCode),
            _DetailRow('Loại lịch', booking.isClassBooking ? 'Lớp học' : 'Gym'),
            _DetailRow('Chi nhánh', booking.branchName),
            _DetailRow(
              'Thời gian',
              '${_dateTime(booking.startTime)} – ${_time(booking.endTime)}',
            ),
            _DetailRow('Trạng thái', booking.status),
            _DetailRow('Check-in', booking.checkInStatus, isLast: true),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Chưa có dữ liệu' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayHistoryCard extends StatelessWidget {
  const _TodayHistoryCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffCheckInProvider>();
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch sử hôm nay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Làm mới',
                onPressed: provider.isLoading ? null : provider.loadTodayLogs,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (provider.isLoading && provider.todayLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.todayLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Hôm nay chưa có lượt check-in thành công.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...provider.todayLogs.take(10).map(_HistoryRow.new),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow(this.log);

  final StaffCheckInLog log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF163322),
            child: Icon(Icons.check_rounded, color: Color(0xFF22C55E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.memberName.isEmpty ? 'Khách hàng' : log.memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  log.className ?? log.memberEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _time(log.scannedAt),
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _CameraQrTab extends StatefulWidget {
  const _CameraQrTab({required this.onCheckIn});

  final Future<void> Function() onCheckIn;

  @override
  State<_CameraQrTab> createState() => _CameraQrTabState();
}

class _CameraQrTabState extends State<_CameraQrTab> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  String? _scannerError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    final value = _extractQrValue(rawValue);
    if (value == null) {
      if (mounted) {
        setState(() => _scannerError = 'Mã QR không chứa dữ liệu hợp lệ.');
      }
      return;
    }

    _handled = true;
    await _controller.stop();
    if (!mounted) return;
    setState(() => _scannerError = null);
    context.read<StaffCheckInProvider>().lookupBooking(value);
  }

  Future<void> _scanAgain() async {
    context.read<StaffCheckInProvider>().clearLookup();
    setState(() {
      _handled = false;
      _scannerError = null;
    });
    try {
      await _controller.start();
    } on MobileScannerException catch (error) {
      if (!mounted) return;
      setState(() => _scannerError = _scannerErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 250,
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                final message = _scannerErrorMessage(error);
                return ColoredBox(
                  color: const Color(0xFF0B1220),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(message, textAlign: TextAlign.center),
                    ),
                  ),
                );
              },
              overlayBuilder: (context, constraints) => Center(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF22C55E),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Đưa mã QR vào giữa khung để quét.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        if (_scannerError != null) ...[
          const SizedBox(height: 12),
          _MessageBanner(
            message: _scannerError!,
            color: Colors.redAccent,
            icon: Icons.camera_alt_outlined,
          ),
        ],
        if (_handled) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _scanAgain,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Quét mã khác'),
          ),
        ],
        _BookingResultSection(onCheckIn: widget.onCheckIn),
      ],
    );
  }
}

class _UploadQrTab extends StatefulWidget {
  const _UploadQrTab({required this.onCheckIn});

  final Future<void> Function() onCheckIn;

  @override
  State<_UploadQrTab> createState() => _UploadQrTabState();
}

class _UploadQrTabState extends State<_UploadQrTab> {
  final _picker = ImagePicker();
  final _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _isAnalyzing = false;
  String? _uploadMessage;
  bool _isError = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze() async {
    if (_isAnalyzing) return;
    setState(() {
      _isAnalyzing = true;
      _uploadMessage = null;
      _isError = false;
    });
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (image == null) {
        setState(() => _uploadMessage = 'Đã huỷ chọn ảnh.');
        return;
      }

      final capture = await _scanner.analyzeImage(
        image.path,
        formats: const [BarcodeFormat.qrCode],
      );
      final rawValue = capture?.barcodes
          .map((barcode) => barcode.rawValue)
          .whereType<String>()
          .firstOrNull;
      final value = _extractQrValue(rawValue);
      if (value == null) {
        setState(() {
          _uploadMessage = 'Không tìm thấy mã QR hợp lệ trong ảnh.';
          _isError = true;
        });
        return;
      }

      if (!mounted) return;
      context.read<StaffCheckInProvider>().lookupBooking(value);
      setState(() => _uploadMessage = 'Đã đọc mã QR từ ảnh.');
    } on UnsupportedError {
      if (!mounted) return;
      setState(() {
        _uploadMessage =
            'Thiết bị hoặc nền tảng này chưa hỗ trợ đọc QR từ ảnh.';
        _isError = true;
      });
    } on MobileScannerBarcodeException {
      if (!mounted) return;
      setState(() {
        _uploadMessage = 'Không tìm thấy mã QR trong ảnh đã chọn.';
        _isError = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _uploadMessage =
            'Không thể truy cập hoặc đọc ảnh. Hãy kiểm tra quyền thư viện ảnh.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF263244)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
            child: Column(
              children: [
                const Icon(
                  Icons.image_search_rounded,
                  size: 58,
                  color: Color(0xFF22C55E),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Chọn ảnh có mã QR từ thư viện',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isAnalyzing ? null : _pickAndAnalyze,
                  icon: _isAnalyzing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined),
                  label: const Text('Chọn ảnh QR'),
                ),
              ],
            ),
          ),
        ),
        if (_uploadMessage != null) ...[
          const SizedBox(height: 12),
          _MessageBanner(
            message: _uploadMessage!,
            color: _isError ? Colors.redAccent : const Color(0xFF22C55E),
            icon: _isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
          ),
        ],
        _BookingResultSection(onCheckIn: widget.onCheckIn),
      ],
    );
  }
}

class _BookingResultSection extends StatelessWidget {
  const _BookingResultSection({required this.onCheckIn});

  final Future<void> Function() onCheckIn;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffCheckInProvider>();
    final booking = provider.selectedBooking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (provider.errorMessage != null) ...[
          const SizedBox(height: 12),
          _MessageBanner(
            message: provider.errorMessage!,
            color: Colors.redAccent,
            icon: Icons.error_outline_rounded,
          ),
        ],
        if (booking != null) ...[
          const SizedBox(height: 14),
          _BookingDetailCard(booking: booking),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: booking.isCheckedIn || provider.isCheckingIn
                ? null
                : onCheckIn,
            icon: provider.isCheckingIn
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.how_to_reg_rounded),
            label: Text(
              booking.isCheckedIn
                  ? 'Đã check-in'
                  : booking.isClassBooking
                  ? 'Check-in lớp học'
                  : 'Check-in phòng Gym',
            ),
          ),
        ],
      ],
    );
  }
}

String? _extractQrValue(String? rawValue) {
  final raw = rawValue?.trim();
  if (raw == null || raw.isEmpty) return null;

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      for (final key in const [
        'bookingCode',
        'BookingCode',
        'code',
        'qrToken',
      ]) {
        final value = decoded[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
  } on FormatException {
    // The QR value can legitimately be plain text or a URL.
  }

  final uri = Uri.tryParse(raw);
  if (uri != null && uri.hasScheme) {
    for (final key in const ['bookingCode', 'code', 'qrToken']) {
      final value = uri.queryParameters[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
  }
  return raw;
}

String _scannerErrorMessage(MobileScannerException error) {
  return switch (error.errorCode) {
    MobileScannerErrorCode.permissionDenied =>
      'Quyền camera bị từ chối. Hãy cấp quyền camera trong cài đặt thiết bị.',
    MobileScannerErrorCode.unsupported =>
      'Thiết bị này không hỗ trợ quét mã bằng camera.',
    _ => 'Không thể khởi động camera. Vui lòng thử lại.',
  };
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263244)),
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

String _time(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _dateTime(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')} ${_time(value)}';
