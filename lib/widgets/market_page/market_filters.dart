import 'package:flutter/material.dart';

class MarketFilters extends StatelessWidget {
  final String selectedCategory;
  final String selectedSort;
  final Function(String) onCategoryChanged;
  final Function(String) onSortChanged;

  const MarketFilters({
    super.key,
    required this.selectedCategory,
    required this.selectedSort,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDropdown(
            context,
            value: selectedCategory,
            items: ['All', 'Electronics', 'Books', 'Clothing', 'Food', 'Other'],
            onChanged: onCategoryChanged,
            color: brandOrange,
          ),
          const SizedBox(width: 12),
          _buildDropdown(
            context,
            value: selectedSort,
            items: ['Latest', 'Lowest Price', 'Highest Price'],
            onChanged: onSortChanged,
            color: brandOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, {
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Increased padding since icon is gone
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (val) => onChanged(val!),
        ),
      ),
    );
  }
}
