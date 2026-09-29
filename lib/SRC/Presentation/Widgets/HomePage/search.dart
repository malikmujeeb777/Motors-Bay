import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Domain/models/vehicle_details_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/advance_filter.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/carBrandList.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/vehicle_details_page.dart';
import 'package:motorsbay1/exports.dart';

class SearchAdsScreen extends StatefulWidget {
  const SearchAdsScreen({super.key});

  @override
  State<SearchAdsScreen> createState() => _SearchAdsScreenState();
}

class _SearchAdsScreenState extends State<SearchAdsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  // Dropdown options for sorting
  String _selectedSortOption = 'Select'; // Default sorting option
  final List<String> _sortOptions = ['Select', 'Price', 'Model Year'];

  Stream<QuerySnapshot> _getAdsStream({String searchQuery = ''}) {
    return FirebaseFirestore.instance.collectionGroup("user_cars").snapshots();
  }

  // Sorting logic
  List<QueryDocumentSnapshot> _sortAds(List<QueryDocumentSnapshot> ads) {
    switch (_selectedSortOption) {
    case 'Title':
    ads.sort((a, b) {
    var titleA = (a["title"] ?? "").toLowerCase();
    var titleB = (b["title"] ?? "").toLowerCase();
    return titleA.compareTo(titleB);
    }
    );
    break;

    case 'Price':
    ads.sort((a, b) {
    var priceA = double.tryParse(a["price"] ?? "0") ?? 0;
    var priceB = double.tryParse(b["price"] ?? "0") ?? 0;
    return priceA.compareTo(priceB);
    });
    break;
    case 'Model Year':
    ads.sort((a, b) {
    var yearA = int.tryParse(a["modelYear"] ?? "0") ?? 0;
    var yearB = int.tryParse(b["modelYear"] ?? "0") ?? 0;
    return yearA.compareTo(yearB);
    });
    break;
    default:
    // No sorting
    break;
    }
    return ads;

  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: "Search ads...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
            : Text("All Ads"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _searchFocusNode.unfocus();
                }
              });
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _searchFocusNode.unfocus();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Advance Filter").onTapped(onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const AdvanceFilter()));
            }),
            DropdownButton<String>(
              value: _selectedSortOption,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSortOption = newValue!;
                });
              },
              items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ).padHorizontal(20),
          ],
        ).padHorizontal(10),
        10.y,
        Expanded(
          child: StreamBuilder(
            stream: _getAdsStream(searchQuery: _searchQuery),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error fetching ads"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No data found"));
              }

              var ads = snapshot.data!.docs;

              var filteredAds = _searchQuery.isEmpty
                  ? ads
                  : ads.where((ad) => (ad["title"] ?? "").toLowerCase().contains(_searchQuery.toLowerCase())).toList();

              log("Filter Ads ${filteredAds.length}");
              log("Filter Ads ${filteredAds.toString()}");

              if (filteredAds.isEmpty) {
                return Center(
                  child: Text("No ads available"),
                );
              }
              // Apply sorting
              filteredAds = _sortAds(filteredAds);

              return ListView.builder(
                itemCount: filteredAds.length,
                itemBuilder: (context, index) {
                  var ad = filteredAds[index].data() as Map<String, dynamic>;
                  String imagePath = ad['imageUrls'] != null && ad['imageUrls'].isNotEmpty
                      ? ad['imageUrls'][0] // Assuming the first image in the list
                      : '';

                  final vehicleDetailsModel = VehicleDetailsModel(status: ad['status'] ?? '',
                    listingType: ad['listingType'] ?? '',
                    imageUrls: imagePath.isNotEmpty ? ad['imageUrls'] : [],
                    title: ad['title'] ?? '',
                    price: ad['price'] ?? '0',
                    description: ad['description'] ?? '',
                    kmDriven: ad['kmDriven'] ?? '',
                    transmission: ad['transmission'] ?? '',
                    assembly: ad['assembly'] ?? '',
                    fuelType: ad['fuelType'] ?? '',
                    color: ad['color'] ?? '',
                    city: ad['city'] ?? '',
                    registerIn: ad['registerIn'] ?? '',
                    condition: ad['condition'] ?? '',
                    brand: ad['brand'] ?? '',
                    subCategory: ad['subCategory'] ?? '',
                    contactNumber: ad['contactNumber'] ?? '',
                    allowWhatsApp: ad['allowWhatsApp'] ?? false,
                    createdAt: ad['createdAt'] ?? Timestamp.now(),
                    userId: ad['userId'] ?? '',
                    isSold: ad['isSold'] ?? false,
                    deviceToken: ad['deviceToken'] ?? '',
                    modelYear: ad['modelYear'] ?? '',);
                  return CarItem(
                    imagePath: imagePath,
                    carName: ad["title"] ?? "No Title",
                    price: ad["price"] ?? "0",
                    kmDriven: ad["kmDriven"] ?? "0",
                    fuelType: ad["fuelType"] ?? "petroleum",
                    color: ad["color"] ?? "",
                    modelYear: ad["modelYear"] ?? "",
                    city: ad["city"] ?? "Islamabad",
                    registerIn: ad["registerIn"] ?? "Islamabad",
                  ).onTapped(onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>VehicleDetailsPage(
                      vehicleDetailsModel: vehicleDetailsModel,

                    )));
                  });
                },
              );
            },
          ),
        ),
  ],),
    );
  }
}