import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/file_service.dart';
import 'package:ForUMHUB/utils/course_constants.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final FileService _fileService = FileService();
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  
  String selectedCategory = 'General';
  String? selectedCourse;
  String? _userId;
  String? _userName;
  String? _photoUrl;
  
  List<String> _postImages = [];
  bool _isUploading = false;

  final List<String> postCategories = ['Campus Life', 'Event', 'Announcements', 'Questions', 'General'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _userService.getCurrentUser();
    if (user != null) {
      setState(() => _userId = user.uid);
      final userData = await _userService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userName = userData?['name'] ?? 'User';
          _photoUrl = userData?['photoUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final File? imageFile = await _fileService.pickImage();
    if (imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final String? url = await _fileService.uploadImage(imageFile);
      if (url != null) setState(() => _postImages.add(url));
    } catch (e) {
      debugPrint('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: brandOrange,
        elevation: 0,
        title: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Title of your post", border: InputBorder.none),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailsController,
              maxLines: 8,
              decoration: const InputDecoration(hintText: 'Write more details...', border: InputBorder.none),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            if (_postImages.isNotEmpty) _buildImagePreview(),
            const SizedBox(height: 32),
            _buildSelectionTile('Category', selectedCategory, () => _showCategoryPicker(), brandOrange),
            const SizedBox(height: 12),
            _buildSelectionTile('Course', selectedCourse ?? 'Optional', () => _showCoursePicker(), brandOrange),
            const SizedBox(height: 32),
            _buildAddPhotoButton(brandOrange),
            const SizedBox(height: 40),
            _buildPostButton(brandOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(children: [
      Container(
        width: 45, height: 45,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
        child: ClipOval(
          child: _photoUrl != null 
            ? Image.network(_photoUrl!, fit: BoxFit.cover) 
            : const Icon(Icons.person, color: Colors.grey),
        ),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_userName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const Text('Public Post', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    ]);
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _postImages.length,
        itemBuilder: (c, i) => Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 110, height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: NetworkImage(_postImages[i]), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 4, right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _postImages.removeAt(i)),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTile(String label, String value, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Flexible(child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton(Color color) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.3), width: 1.5), borderRadius: BorderRadius.circular(15), color: color.withOpacity(0.05)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: color, size: 22),
            const SizedBox(width: 12),
            Text('Add Photos/Videos', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            if (_isUploading) const Padding(padding: EdgeInsets.only(left: 12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _handlePost,
        style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 4, shadowColor: color.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (c) => Container(padding: const EdgeInsets.symmetric(vertical: 20), child: Column(mainAxisSize: MainAxisSize.min, children: postCategories.map((cat) => ListTile(title: Text(cat, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)), onTap: () { setState(() => selectedCategory = cat); Navigator.pop(c); })).toList())));
  }

  void _showCoursePicker() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (c) => Container(height: 450, padding: const EdgeInsets.symmetric(vertical: 20), child: ListView(children: CourseConstants.allCourses.map((crs) => ListTile(title: Text(crs, style: const TextStyle(fontSize: 14)), onTap: () { setState(() => selectedCourse = crs); Navigator.pop(c); })).toList())));
  }

  Future<void> _handlePost() async {
    if (titleController.text.trim().isEmpty) return;
    try {
      await _postService.addPost(titleController.text.trim(), detailsController.text.trim(), _userName!, selectedCategory, _userId!, _postImages, authorPhotoUrl: _photoUrl, course: selectedCourse);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
