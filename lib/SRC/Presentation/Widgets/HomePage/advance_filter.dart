import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Domain/models/vehicle_details_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/carBrandList.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/vehicle_details_page.dart';
import 'package:motorsbay1/exports.dart';

class AdvanceFilter extends StatefulWidget {
  const AdvanceFilter({super.key});

  @override
  State<AdvanceFilter> createState() => _AdvanceFilterState();
}

class _AdvanceFilterState extends State<AdvanceFilter> {
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  String? _selectedCity;
  int? _minModelYear;
  int? _maxModelYear;

  List<QueryDocumentSnapshot> _allAds = [];
  List<QueryDocumentSnapshot> _filteredAds = [];

  final List<String> _cities = ["Islamabad", "Lahore", "Karachi", "Peshawar", "Quetta"];
  final List<int> _modelYears = List.generate(30, (index) => DateTime.now().year - index);

  Stream<QuerySnapshot> _getAdsStream() {
    return FirebaseFirestore.instance.collectionGroup("user_cars").snapshots();
  }

  List<QueryDocumentSnapshot> _applyAdvancedFilters(List<QueryDocumentSnapshot> ads) {
    return ads.where((ad) {
      var price = double.tryParse(ad["price"] ?? "0") ?? 0;
      var modelYear = int.tryParse(ad["modelYear"] ?? "0") ?? 0;
      var city = ad["city"] ?? "";

      bool priceFilter = price >= _minPrice && price <= _maxPrice;
      bool modelYearFilter = (_minModelYear == null || modelYear >= _minModelYear!) &&
          (_maxModelYear == null || modelYear <= _maxModelYear!);
      bool cityFilter = _selectedCity == null || city.toLowerCase() == _selectedCity!.toLowerCase();

      return priceFilter && modelYearFilter && cityFilter;
    }).toList();
  }

  void _applyFilters() {
    setState(() {
      _filteredAds = _applyAdvancedFilters(_allAds);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    final snapshot = await FirebaseFirestore.instance.collectionGroup("user_cars").get();
    setState(() {
      _allAds = snapshot.docs;
      _filteredAds = _allAds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Advanced Filters"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Min Price",
                        hintText: "0",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _minPrice = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Max Price",
                        hintText: "1000000",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = double.tryParse(value) ?? double.infinity;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Min Model Year",
                  border: OutlineInputBorder(),
                ),
                items: _modelYears.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _minModelYear = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Max Model Year",
                  border: OutlineInputBorder(),
                ),
                items: _modelYears.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _maxModelYear = value;
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select City",
                  border: OutlineInputBorder(),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _applyFilters,
                child: Text("Apply Filters"),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getAdsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading ads"));
                    }

                    List<QueryDocumentSnapshot> allAds = snapshot.data?.docs ?? [];
                    List<QueryDocumentSnapshot> filteredAds = _applyAdvancedFilters(allAds);

                    return filteredAds.isEmpty
                        ? Center(child: Text("No ads available"))
                        : ListView.builder(
                      itemCount: filteredAds.length,
                      itemBuilder: (context, index) {
                        String carId = filteredAds[index].id;
                        var ad = filteredAds[index].data() as Map<String, dynamic>;
                        String imagePath = ad['imageUrls'] != null && ad['imageUrls'].isNotEmpty
                            ? ad['imageUrls'][0] // Assuming the first image in the list
                            : '';


                        final vehicleDetailsModel = VehicleDetailsModel(
                          imageUrls: imagePath != '' ? ad['imageUrls'] : [],
                          status: ad['status'] ?? '',
                          listingType: ad['listingType'] ?? '',
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
                          modelYear: ad['modelYear'] ?? '',
                        );



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
                        ).onTapped(onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleDetailsPage(
                                vehicleDetailsModel: vehicleDetailsModel,
                                carId: carId,
                              ),
                            ),
                          );
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
