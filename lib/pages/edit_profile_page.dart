import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/login/login_text_field.dart';
import 'package:ForUMHUB/widgets/login/login_button.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/file_service.dart';
import 'package:ForUMHUB/utils/course_constants.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserService _userService = UserService();
  final FileService _fileService = FileService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedCourse;
  String? _userId;
  String? _photoUrl;
  bool _isLoading = true;
  bool _isUploading = false;

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
          _nameController.text = userData?['name'] ?? '';
          _bioController.text = userData?['bio'] ?? '';
          _selectedCourse = userData?['course'];
          _photoUrl = userData?['photoUrl'];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_userId == null) return;
    final File? imageFile = await _fileService.pickImage();
    if (imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final String? downloadUrl = await _fileService.uploadImage(imageFile);
      if (downloadUrl != null) {
        await _userService.updateUserProfile(_userId!, {'photoUrl': downloadUrl});
        setState(() { _photoUrl = downloadUrl; });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo uploaded successfully!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Edit Profile'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileImageEdit(),
            const SizedBox(height: 32),
            LoginTextField(controller: _nameController, hintText: 'Full Name', icon: Icons.person_outline, isPassword: false),
            const SizedBox(height: 16),
            _buildCourseDropdown(),
            const SizedBox(height: 16),
            LoginTextField(controller: _bioController, hintText: 'Bio', icon: Icons.info_outline, isPassword: false),
            const SizedBox(height: 32),
            LoginButton(onPressed: _handleSave, label: 'SAVE CHANGES', color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), border: Border.all(color: const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCourse,
          hint: const Text('Select course'),
          isExpanded: true,
          menuMaxHeight: 300,
          items: CourseConstants.allCourses.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) => setState(() => _selectedCourse = v),
        ),
      ),
    );
  }

  Widget _buildProfileImageEdit() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3)),
            child: ClipOval(
              child: _isUploading 
                ? const Center(child: CircularProgressIndicator())
                : _photoUrl != null 
                  ? Image.network(_photoUrl!, key: ValueKey(_photoUrl), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 70, color: Colors.grey))
                  : const Icon(Icons.person, size: 70, color: Colors.grey),
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    await _userService.updateUserProfile(_userId!, {'name': _nameController.text.trim(), 'bio': _bioController.text.trim(), 'course': _selectedCourse});
    if (mounted) Navigator.pop(context);
  }
}
