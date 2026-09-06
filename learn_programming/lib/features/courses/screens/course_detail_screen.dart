import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import '../models/course_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool isLoading = true;
  CourseDetailModel? courseData;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  final TextEditingController _noteController = TextEditingController();
  bool isSavingNote = false;

  final Color darkBg = const Color(0xFF0F172A);
  final Color surfaceColor = const Color(0xFF1E293B);
  final Color primaryOrange = const Color(0xFFF97316);
  final Color textMuted = const Color(0xFF94A3B8);

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['بررسی کلی', 'سرفصل‌ها', 'منابع آموزشی', 'پرسش'];

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  // مقداردهی ویدیو پلیر بر اساس لینک درس
  void _initializeVideo(String videoUrl) {
    // اصلاح لینک‌های غیرامن یا نمونه در صورت نیاز
    String validUrl = videoUrl.isNotEmpty ? videoUrl : 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
    
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(validUrl));
    
    _videoController!.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
      });
    }).catchError((e) {
      debugPrint("Video Error: $e");
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final dio = Dio();
      // استفاده از 127.0.0.1 برای کروم
      final response = await dio.get(
        'http://127.0.0.1:8000/api/courses/list/${widget.courseId}/',
      );
      if (response.statusCode == 200) {
        setState(() {
          courseData = CourseDetailModel.fromJson(response.data);
          isLoading = false;
        });

        // اگر درسی وجود داشت، ویدیوی اولین درس را به عنوان پیش‌فرض لود کن
        if (courseData!.lessons.isNotEmpty) {
          _initializeVideo(courseData!.lessons[0].videoUrl);
        }
      }
    } catch (e) {
      debugPrint('Course Detail Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) return;
    setState(() => isSavingNote = true);
    try {
      final dio = Dio();
      await dio.post(
        'http://127.0.0.1:8000/api/courses/lesson/1/note/',
        data: {'text': _noteController.text},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('یادداشت با موفقیت ذخیره شد'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ذخیره یادداشت'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSavingNote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(backgroundColor: darkBg, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
        body: isLoading || courseData == null
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVideoPlayer(),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseData!.title,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text('مدرس: ', style: TextStyle(color: textMuted, fontSize: 13)),
                              Text(courseData!.instructor, style: const TextStyle(color: Colors.white, fontSize: 13)),
                              const SizedBox(width: 16),
                              Text('پیشرفت: ${courseData!.progressPercentage}%', style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (courseData!.description != null) ...[
                            Text(courseData!.description ?? '', style: TextStyle(color: textMuted, fontSize: 13, height: 1.6)),
                            const SizedBox(height: 24),
                          ],
                          _buildCustomTabs(),
                          const SizedBox(height: 24),
                          _buildNotesSection(),
                          const SizedBox(height: 32),
                          const Text('لیست پخش دوره', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildPlaylist(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        width: double.infinity, height: 220, color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: primaryOrange)),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
        });
      },
      child: Container(
        width: double.infinity, height: 220, color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),
            if (!_videoController!.value.isPlaying)
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
              ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: VideoProgressIndicator(_videoController!, allowScrubbing: true, padding: EdgeInsets.zero, colors: VideoProgressColors(playedColor: primaryOrange, bufferedColor: Colors.white38, backgroundColor: Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_tabs.length, (index) {
            bool isActive = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_tabs[index], style: TextStyle(color: isActive ? primaryOrange : textMuted, fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }),
        ),
        Stack(
          children: [
            Container(height: 2, width: double.infinity, color: surfaceColor),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: (_selectedTabIndex * (MediaQuery.of(context).size.width - 40) / 4) + 10,
              child: Container(height: 2, width: 40, color: primaryOrange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [Icon(Icons.edit_note_rounded, color: Colors.white, size: 24), SizedBox(width: 8), Text('یادداشت‌های من', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
              InkWell(
                onTap: isSavingNote ? null : _saveNote,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryOrange.withValues(alpha: 0.3))),
                  child: isSavingNote ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : Text('ذخیره یادداشت', style: TextStyle(color: primaryOrange, fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 100, padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: darkBg, borderRadius: BorderRadius.circular(12)),
            child: TextField(controller: _noteController, maxLines: null, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: InputDecoration(hintText: 'نکات کلیدی این بخش را یادداشت کنید...', hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.5), fontSize: 13), border: InputBorder.none)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylist() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courseData!.lessons.length,
      itemBuilder: (context, index) {
        final lesson = courseData!.lessons[index];
        
        return InkWell(
          onTap: () {
            // با کلیک روی هر درس، ویدیو پلیر روی آن سوییچ می‌شود
            _initializeVideo(lesson.videoUrl);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.play_arrow_rounded, color: primaryOrange, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${lesson.order}. ${lesson.title}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(lesson.isCompleted ? 'تکمیل شده' : 'آماده پخش', style: TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}