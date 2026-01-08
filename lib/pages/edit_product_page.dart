import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:ForUMHUB/services/file_service.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final MarketService _marketService = MarketService();
  final FileService _fileService = FileService();
  
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  
  String _selectedCategory = '';
  String _selectedCondition = 'New';
  String? _newImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(text: widget.product.price);
    _selectedCategory = widget.product.category;
    _newImageUrl = widget.product.imageUrl;

    // Parse existing condition from details string
    final detailsParts = widget.product.details.split(' - ');
    _selectedCondition = detailsParts.isNotEmpty ? detailsParts[0] : 'New';
    _descriptionController = TextEditingController(
      text: detailsParts.length > 1 ? detailsParts[1] : widget.product.details
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
    final File? imageFile = await _fileService.pickImage();
    if (imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final String? url = await _fileService.uploadImage(imageFile);
      if (url != null) setState(() => _newImageUrl = url);
    } catch (e) {
      debugPrint('Upload Error: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _updateProduct() async {
    if (_titleController.text.trim().isEmpty || _priceController.text.trim().isEmpty) return;

    try {
      await _marketService.updateProduct(widget.product.id, {
        'title': _titleController.text.trim(),
        'price': _priceController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': _newImageUrl,
        'details': "${_selectedCondition} - ${_descriptionController.text.trim()}",
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated!')));
      }
    } catch (e) {
      debugPrint('Update error: $e');
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
        title: const Text('Edit Listing', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildPhotoBox(brandOrange),
            const SizedBox(height: 32),
            _buildInputField('Product Title', _titleController, 'What are you selling?'),
            const SizedBox(height: 20),
            _buildInputField('Price', _priceController, '0.00', keyboardType: TextInputType.number, prefix: '₱ '),
            const SizedBox(height: 20),
            _buildSelectionRow('Category', _selectedCategory, () => _showCategoryPicker(), brandOrange),
            const SizedBox(height: 12),
            _buildSelectionRow('Condition', _selectedCondition, () => _showConditionPicker(), brandOrange),
            const SizedBox(height: 20),
            _buildInputField('Description', _descriptionController, 'Describe your item...', maxLines: 5),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandOrange,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox(Color color) {
    return GestureDetector(
      onTap: _pickNewImage,
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: _isUploading 
          ? const Center(child: CircularProgressIndicator()) 
          : _newImageUrl != null 
            ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(_newImageUrl!, fit: BoxFit.cover)) 
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: color, size: 32),
                  const SizedBox(height: 8),
                  const Text('Change Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionRow(String label, String value, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
            const Spacer(),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final cats = ['Electronics', 'Books', 'Clothing', 'Food', 'Other'];
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), 
      builder: (c) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20), 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: cats.map((cat) => ListTile(
            title: Text(cat, textAlign: TextAlign.center), 
            onTap: () { 
              setState(() => _selectedCategory = cat); 
              Navigator.pop(c); 
            }
          )).toList()
        )
      )
    );
  }

  void _showConditionPicker() {
    final cons = ['New', 'Used - Like New', 'Used - Good', 'Used - Fair'];
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), 
      builder: (c) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20), 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: cons.map((con) => ListTile(
            title: Text(con, textAlign: TextAlign.center), 
            onTap: () { 
              setState(() => _selectedCondition = con); 
              Navigator.pop(c); 
            }
          )).toList()
        )
      )
    );
  }
}
