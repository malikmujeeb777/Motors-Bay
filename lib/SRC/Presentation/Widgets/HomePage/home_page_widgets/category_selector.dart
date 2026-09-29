


import 'package:motorsbay1/SRC/Presentation/Widgets/AIChat/ai_chat_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/favourite_screen.dart';
import 'package:motorsbay1/exports.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  CategorySelector({required this.selectedCategory, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 3,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CategoryButton(label: "Cars", isSelected: selectedCategory == "Cars", onTap: onCategorySelected),
        Row(
          children: [
            IconButton(icon: Icon(Icons.favorite_border), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>FavoriteListScreen()));
            }),
            5.x,
            IconButton(icon: Icon(Icons.chat), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const AiChatScreen()));
            }),
          ],
        )
      ],
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(String) onTap;

  CategoryButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      
      onPressed: () => onTap(label),
      style: ElevatedButton.styleFrom(
        
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: BorderSide(color: Colors.blue),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(label,style: TextStyle(fontSize: 12),),
    );
  }
}