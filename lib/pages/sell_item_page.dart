import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/file_service.dart';

class SellItemPage extends StatefulWidget {
  const SellItemPage({super.key});

  @override
  State<SellItemPage> createState() => _SellItemPageState();
}

class _SellItemPageState extends State<SellItemPage> {
  final MarketService _marketService = MarketService();
  final UserService _userService = UserService();
  final FileService _fileService = FileService();
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Electronics';
  String selectedCondition = 'New';
  String? _userId;
  String? _userName;
  String? _userPhotoUrl;
  String? _itemImageUrl;
  bool _isUploading = false;

  // Standardized categories
  final List<String> marketCategories = ['Electronics', 'Books', 'Clothing', 'Food', 'Other'];

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
      if (mounted) setState(() { _userName = userData?['name'] ?? 'User'; _userPhotoUrl = userData?['photoUrl']; });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final File? imageFile = await _fileService.pickImage();
    if (imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final String? url = await _fileService.uploadImage(imageFile);
      if (url != null) setState(() => _itemImageUrl = url);
    } catch (e) { debugPrint('Upload failed: $e'); } finally { if (mounted) setState(() => _isUploading = false); }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: brandOrange, elevation: 0,
        title: const Text('Sell an Item', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildPhotoBox(brandOrange),
            const SizedBox(height: 32),
            _buildInputField('Product Title', titleController, 'What are you selling?'),
            const SizedBox(height: 20),
            _buildInputField('Price', priceController, '0.00', keyboardType: TextInputType.number, prefix: '₱ '),
            const SizedBox(height: 20),
            _buildSelectionRow('Category', selectedCategory, () => _showCategoryPicker(), brandOrange),
            const SizedBox(height: 12),
            _buildSelectionRow('Condition', selectedCondition, () => _showConditionPicker(), brandOrange),
            const SizedBox(height: 20),
            _buildInputField('Description', descriptionController, 'Describe your item in detail...', maxLines: 5),
            const SizedBox(height: 40),
            _buildPostButton(brandOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox(Color color) {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2), width: 2)),
        child: _isUploading ? const Center(child: CircularProgressIndicator()) : _itemImageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(_itemImageUrl!, fit: BoxFit.cover)) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: color, size: 32), const SizedBox(height: 8), Text('Add Photo', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? prefix}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)), const SizedBox(height: 8), TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, decoration: InputDecoration(hintText: hint, prefixText: prefix, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!))))]);
  }

  Widget _buildSelectionRow(String label, String value, VoidCallback onTap, Color color) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)), child: Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)), const Spacer(), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey)])));
  }

  Widget _buildPostButton(Color color) {
    return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _handleSubmit, style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 4, shadowColor: color.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('POST ITEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2))));
  }

  void _showCategoryPicker() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (c) => Container(padding: const EdgeInsets.symmetric(vertical: 20), child: Column(mainAxisSize: MainAxisSize.min, children: marketCategories.map((cat) => ListTile(title: Text(cat, textAlign: TextAlign.center), onTap: () { setState(() => selectedCategory = cat); Navigator.pop(c); })).toList())));
  }

  void _showConditionPicker() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (c) => Column(mainAxisSize: MainAxisSize.min, children: ['New', 'Used - Like New', 'Used - Good', 'Used - Fair'].map((con) => ListTile(title: Text(con, textAlign: TextAlign.center), onTap: () { setState(() => selectedCondition = con); Navigator.pop(c); })).toList()));
  }

  Future<void> _handleSubmit() async {
    if (titleController.text.trim().isEmpty || priceController.text.trim().isEmpty) return;
    try {
      await _marketService.addProduct(titleController.text.trim(), priceController.text.trim(), selectedCategory, "${selectedCondition} - ${descriptionController.text.trim()}", _userId!, _userName!, imageUrl: _itemImageUrl, sellerPhotoUrl: _userPhotoUrl);
      if (mounted) Navigator.pop(context);
    } catch (e) { debugPrint('Error: $e'); }
  }
}
