import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedSubject;
  File? _selectedFile;
  bool _isLoading = false;

  final Color darkBg = const Color(0xFF0F1115);
  final Color surfaceColor = const Color(0xFF161A22);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF94A3B8);

  // مقادیر Value باید دقیقاً مطابق با CHOICES در مدل جنگو باشند
  final List<Map<String, String>> _subjects = [
    {'value': 'technical', 'label': 'پشتیبانی فنی'},
    {'value': 'financial', 'label': 'امور مالی و خرید'},
    {'value': 'educational', 'label': 'سوالات آموزشی'},
    {'value': 'other', 'label': 'سایر موارد'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final PlatformFile? pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'zip'],
    );

    if (pickedFile != null && pickedFile.path != null) {
      setState(() {
        _selectedFile = File(pickedFile.path!);
      });
    }
  }

  Future<void> _submitTicket() async {
    if (_selectedSubject == null || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً موضوع و متن پیام را وارد کنید.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();

      // ساخت FormData برای ارسال متن و فایل به شکل چندبخشی (Multipart)
      FormData formData = FormData.fromMap({
        'subject': _selectedSubject,
        'message': _messageController.text,
        if (_selectedFile != null)
          'attachment': await MultipartFile.fromFile(
            _selectedFile!.path,
            filename: _selectedFile!.path.split('/').last,
          ),
      });

      // استفاده از 127.0.0.1 برای اجرای صحیح روی مرورگر کروم
      final response = await dio.post(
        'http://127.0.0.1:8000/api/tickets/',
        data: formData,
        // نکته: اگر اندپوینت شما نیاز به احراز هویت دارد، هدر زیر را فعال کنید:
        // options: Options(headers: {'Authorization': 'Bearer YOUR_TOKEN'}),
      );

      // جنگو به صورت پیش‌فرض برای متد Create وضعیت 201 برمی‌گرداند
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تیکت شما با موفقیت ثبت شد.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // بازگشت به صفحه قبل
      }
    } catch (e) {
      debugPrint('Ticket Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در ارسال تیکت. لطفا دوباره تلاش کنید.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'DevFlow',
        style: TextStyle(
          color: primaryOrange,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تیکت پشتیبانی جدید',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'مشکل خود را در زیر شرح دهید. تیم پشتیبانی ما ظرف ۲۴ ساعت پاسخ خواهد داد.',
          style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('موضوع'),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('پیام'),
                  Text(
                    'پشتیبانی از MARKDOWN',
                    style: TextStyle(
                      color: textMuted.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMessageField(),
              const SizedBox(height: 24),
              _buildFileUploadArea(),
              const SizedBox(height: 8),
              Text(
                'حداکثر اندازه فایل: 10MB',
                style: TextStyle(
                  color: textMuted.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  primaryOrange.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubject,
          hint: Text(
            'انتخاب نوع مشکل...',
            style: TextStyle(color: textMuted, fontSize: 14),
          ),
          dropdownColor: surfaceColor,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white54,
          ),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: _subjects
              .map(
                (subject) => DropdownMenuItem<String>(
                  value: subject['value'],
                  child: Text(subject['label']!),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedSubject = value),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _messageController,
            maxLines: 7,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'لطفاً مشکل خود را با جزئیات شرح دهید...',
              hintStyle: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Row(
              children: [
                _buildActionIcon(Icons.code_rounded),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.attach_file_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: Colors.white54, size: 16),
    );
  }

  Widget _buildFileUploadArea() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: darkBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: textMuted, size: 32),
            const SizedBox(height: 12),
            if (_selectedFile != null)
              Text(
                'فایل انتخاب شد: ${_selectedFile!.path.split('/').last}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              )
            else
              RichText(
                text: TextSpan(
                  style: TextStyle(color: textMuted, fontSize: 14),
                  children: const [
                    TextSpan(text: 'فایل‌ها را بکشید و رها کنید یا '),
                    TextSpan(
                      text: 'مرور کنید',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'لغو',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitTicket,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  children: [
                    Text(
                      'ارسال تیکت',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send_rounded, size: 16),
                  ],
                ),
        ),
      ],
    );
  }
}
