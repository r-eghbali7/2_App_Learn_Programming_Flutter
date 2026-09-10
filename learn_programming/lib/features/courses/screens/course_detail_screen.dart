// lib/features/courses/screens/course_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/network/api_client.dart';
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
  int? _activeLessonId;

  final Color darkBg = const Color(0xFF0F172A);
  final Color surfaceColor = const Color(0xFF1E293B);
  final Color primaryOrange = const Color(0xFFF97316);
  final Color textMuted = const Color(0xFF94A3B8);

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['بررسی کلی', 'سرفصل‌ها', 'یادداشت'];

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  void _initializeVideo(String videoUrl) {
    String validUrl = videoUrl.isNotEmpty
        ? videoUrl
        : 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(validUrl));
    _videoController!
        .initialize()
        .then((_) {
          setState(() => _isVideoInitialized = true);
          _videoController!.play();
        })
        .catchError((e) {
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
      final response = await ApiClient().dio.get(
        'courses/list/${widget.courseId}/',
      );
      if (response.statusCode == 200) {
        setState(() {
          courseData = CourseDetailModel.fromJson(response.data);
          isLoading = false;
        });

        if (courseData!.lessons.isNotEmpty) {
          final firstLesson = courseData!.lessons[0];
          _activeLessonId = firstLesson.id;
          _initializeVideo(firstLesson.videoUrl);
          _fetchLessonNote(firstLesson.id);
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchLessonNote(int lessonId) async {
    try {
      final response = await ApiClient().dio.get(
        'courses/lesson/$lessonId/note/',
      );
      if (response.statusCode == 200) {
        _noteController.text = response.data['text'] ?? '';
      }
    } catch (_) {
      _noteController.clear();
    }
  }

  Future<void> _saveNote() async {
    if (_activeLessonId == null || _noteController.text.trim().isEmpty) return;
    setState(() => isSavingNote = true);
    try {
      await ApiClient().dio.post(
        'courses/lesson/$_activeLessonId/note/',
        data: {'text': _noteController.text},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('یادداشت با موفقیت ذخیره شد'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در ذخیره یادداشت'),
          backgroundColor: Colors.red,
        ),
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
        appBar: AppBar(
          backgroundColor: darkBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'مدرس: ',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                courseData!.instructor,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'پیشرفت: ${courseData!.progressPercentage}%',
                                style: TextStyle(
                                  color: primaryOrange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildCustomTabs(),
                          const SizedBox(height: 24),
                          if (_selectedTabIndex == 2) _buildNotesSection(),
                          if (_selectedTabIndex == 1 ||
                              _selectedTabIndex == 0) ...[
                            const Text(
                              'جلسات دوره',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPlaylist(),
                          ],
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
        width: double.infinity,
        height: 220,
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: primaryOrange)),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _videoController!.value.isPlaying
              ? _videoController!.pause()
              : _videoController!.play();
        });
      },
      child: Container(
        width: double.infinity,
        height: 220,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            if (!_videoController!.value.isPlaying)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: VideoProgressColors(
                  playedColor: primaryOrange,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_tabs.length, (index) {
        bool isActive = _selectedTabIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedTabIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isActive ? primaryOrange : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              _tabs[index],
              style: TextStyle(
                color: isActive ? primaryOrange : textMuted,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'یادداشت این جلسه',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: isSavingNote ? null : _saveNote,
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
                child: isSavingNote
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'ذخیره',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'نکات این جلسه را اینجا بنویسید...',
              hintStyle: TextStyle(color: textMuted),
              filled: true,
              fillColor: darkBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
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
        final bool isSelected = _activeLessonId == lesson.id;

        return InkWell(
          onTap: () {
            setState(() => _activeLessonId = lesson.id);
            _initializeVideo(lesson.videoUrl);
            _fetchLessonNote(lesson.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryOrange.withValues(alpha: 0.15)
                  : surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryOrange : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: isSelected ? primaryOrange : textMuted,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lesson.order}. ${lesson.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.isCompleted ? 'تکمیل شده' : 'مشاهده نشده',
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
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
