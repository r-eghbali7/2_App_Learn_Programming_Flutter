// lib/features/practices/screens/practice_editor_screen.dart
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../models/practice_model.dart';

class PracticeEditorScreen extends StatefulWidget {
  final int exerciseId;

  const PracticeEditorScreen({super.key, this.exerciseId = 1});

  @override
  State<PracticeEditorScreen> createState() => _PracticeEditorScreenState();
}

class _PracticeEditorScreenState extends State<PracticeEditorScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeRunning = false;
  bool _isLoading = true;

  PracticeModel? _exerciseData;
  List<Widget> _consoleOutput = [];

  @override
  void initState() {
    super.initState();
    _fetchExerciseDetails();
  }

  // --- دریافت اطلاعات تمرین از سرور با ApiClient مرکزی ---
  Future<void> _fetchExerciseDetails() async {
    try {
      final response = await ApiClient().dio.get('practices/exercises/${widget.exerciseId}/');

      if (response.statusCode == 200) {
        setState(() {
          _exerciseData = PracticeModel.fromJson(response.data);
          _codeController.text = _exerciseData!.starterCode;
          _consoleOutput = [
            Text(
              'آماده برای اجرای کد...',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      _loadMockData(); // در صورت قطع بودن بک‌اند برای جلوگیری از گیر کردن لودینگ
    }
  }

  void _loadMockData() {
    setState(() {
      _exerciseData = PracticeModel(
        id: widget.exerciseId,
        title: 'solution.py',
        language: 'Python',
        starterCode: '# کدهای خود را اینجا بنویسید\nprint("Hello World")',
      );
      _codeController.text = _exerciseData!.starterCode;
      _consoleOutput = [
        Text(
          'آماده برای اجرای کد (حالت آفلاین/ماک)...',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // --- ارسال کد به بک‌اند و اجرای واقعی با Piston API ---
  Future<void> _runCode() async {
    setState(() {
      _isCodeRunning = true;
      _consoleOutput = [
        const Text(
          '> در حال ارسال و اجرای کد در سرور...',
          style: TextStyle(
            color: Color(0xFF64FFDA),
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ];
    });

    try {
      final response = await ApiClient().dio.post(
        'practices/submissions/',
        data: {
          'exercise': widget.exerciseId, // باید یک عدد صحیح (Integer) باشد نه String
          'submitted_code': _codeController.text, // متن کد
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final feedback = response.data['feedback'] ?? 'اجرا با موفقیت انجام شد.';
        final statusResult = response.data['status'] == 'passed' ? 'پذیرفته شده (Passed)' : 'خطا در اجرا (Failed)';
        final isPassed = response.data['status'] == 'passed';

        setState(() {
          _consoleOutput.addAll([
            const SizedBox(height: 8),
            Text(
              feedback,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'وضعیت: $statusResult',
              style: TextStyle(
                color: isPassed ? AppColors.successGreen : AppColors.errorRed,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]);
        });
      }
    } catch (e) {
      setState(() {
        _consoleOutput.addAll([
          const SizedBox(height: 8),
          const Text(
            'خطا در ارتباط با سرور یا اجرای کد!',
            style: TextStyle(color: AppColors.errorRed, fontSize: 13),
          ),
        ]);
      });
    } finally {
      setState(() => _isCodeRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: _buildAppBar(),
        body: _isLoading || _exerciseData == null
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(flex: 3, child: _buildEditorSection()),
                    Expanded(flex: 1, child: _buildConsoleSection()),
                  ],
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'محیط تمرین و کدنویسی',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditorSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isCodeRunning ? null : _runCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCodeRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          children: [
                            Text(
                              'اجرای کد',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.play_arrow_rounded, size: 18),
                          ],
                        ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _exerciseData!.title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _exerciseData!.language,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.black.withValues(alpha: 0.1),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 29,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2.5),
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontFamily: 'monospace',
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161920),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildMacDot(Colors.redAccent),
                    const SizedBox(width: 6),
                    _buildMacDot(Colors.orangeAccent),
                    const SizedBox(width: 6),
                    _buildMacDot(Colors.green),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'خروجی کنسول سرور',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.terminal_rounded,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _consoleOutput,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}