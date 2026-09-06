import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/practice_model.dart'; // ایمپورت مدل

class PracticeEditorScreen extends StatefulWidget {
  final int exerciseId;

  const PracticeEditorScreen({super.key, this.exerciseId = 1});

  @override
  State<PracticeEditorScreen> createState() => _PracticeEditorScreenState();
}

class _PracticeEditorScreenState extends State<PracticeEditorScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeRunning = false;
  bool _isLoading = true; // وضعیت لودینگ اطلاعات تمرین

  PracticeModel? _exerciseData; // مدل دیتای تمرین
  List<Widget> _consoleOutput = [];

  // رنگ‌های تم
  final Color darkBg = const Color(0xFF12151C);
  final Color surfaceColor = const Color(0xFF1A1D24);
  final Color consoleBg = const Color(0xFF161920);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF5C6370);

  @override
  void initState() {
    super.initState();
    _fetchExerciseDetails();
  }

  // --- دریافت اطلاعات تمرین و کدهای اولیه از سرور ---
  Future<void> _fetchExerciseDetails() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://10.0.2.2:8000/api/practices/${widget.exerciseId}/',
      );

      if (response.statusCode == 200) {
        setState(() {
          _exerciseData = PracticeModel.fromJson(response.data);
          _codeController.text = _exerciseData!.starterCode;
          _consoleOutput = [
            Text(
              'آماده برای اجرای کد...',
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      _loadMockData(); // در صورت قطع بودن بک‌اند
    }
  }

  void _loadMockData() {
    setState(() {
      _exerciseData = PracticeModel(
        id: widget.exerciseId,
        title: 'solution.js',
        language: 'JS',
        starterCode: '''/**
 * Definition for a binary tree node.
 * function TreeNode(val, left, right) {
 *     this.val = (val===undefined ? 0 : val)
 *     this.left = (left===undefined ? null : left)
 *     this.right = (right===undefined ? null : right)
 * }
 */
/**
 * @param {TreeNode} root
 * @return {TreeNode}
 */
var invertTree = function(root) {
    if (root === null) {
        return null;
    }
    
    // Swap left and right
    const temp = root.left;
    root.left = root.right;
    root.right = temp;
    
    invertTree(root.left);
    invertTree(root.right);
    
    return root;
};

// Test cases running...''',
      );
      _codeController.text = _exerciseData!.starterCode;
      _consoleOutput = [
        Text(
          'آماده برای اجرای کد...',
          style: TextStyle(
            color: textMuted,
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

  // --- شبیه‌سازی و ارسال کد به بک‌اند ---
  Future<void> _runCode() async {
    setState(() {
      _isCodeRunning = true;
      _consoleOutput = [
        const Text(
          '> node solution.js',
          style: TextStyle(
            color: Color(0xFF64FFDA),
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'در حال اجرای تست‌ها...',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ];
    });

    try {
      final dio = Dio();
      await dio.post(
        'http://10.0.2.2:8000/api/practices/submissions/',
        data: {
          'exercise': widget.exerciseId,
          'submitted_code': _codeController.text,
        },
      );

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _consoleOutput.addAll([
          const SizedBox(height: 8),
          _buildTestResult('مورد تست ۱ با موفقیت انجام شد', '3ms'),
          _buildTestResult('مورد تست ۲ با موفقیت انجام شد', '1ms'),
          _buildTestResult('مورد تست ۳ با موفقیت انجام شد', '1ms'),
          const SizedBox(height: 12),
          const Text(
            'وضعیت: پذیرفته شده',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]);
      });
    } catch (e) {
      setState(() {
        _consoleOutput.addAll([
          const SizedBox(height: 8),
          const Text(
            'خطا در ارتباط با سرور یا اجرای کد!',
            style: TextStyle(color: Colors.redAccent, fontSize: 13),
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
        backgroundColor: darkBg,
        appBar: _buildAppBar(),
        // نوار پایین (BottomNavigationBar) حذف شد!
        body: _isLoading || _exerciseData == null
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
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

  // --- کامپوننت‌های ماژولار ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      title: const Center(
        child: Text(
          'دوفلو',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
        onPressed: () {},
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: const AssetImage('assets/images/avatar.jpg'),
            backgroundColor: surfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEditorSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
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
                              color: textMuted,
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
        color: consoleBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                Row(
                  children: [
                    const Text(
                      'خروجی کنسول',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
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

  Widget _buildTestResult(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF64FFDA),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64FFDA),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($time)',
            style: const TextStyle(
              color: Color(0xFF64FFDA),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
