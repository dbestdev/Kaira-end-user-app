import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/widgets/favorite_toggle_button.dart';

class ServiceCategoryPage extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const ServiceCategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<ServiceCategoryPage> createState() => _ServiceCategoryPageState();
}

class _ServiceCategoryPageState extends State<ServiceCategoryPage> {
  final Set<Marker> _artisanMarkers = {};
  bool _showMap = true;
  String _sortBy = 'rating'; // rating, price, distance

  // Sample artisan data for the specific category
  late final List<Map<String, dynamic>> _artisans;

  @override
  void initState() {
    super.initState();
    _initializeArtisans();
    _addArtisanMarkers();
  }

  void _initializeArtisans() {
    // Generate sample data based on category
    _artisans = _generateArtisansForCategory(widget.categoryName);
  }

  List<Map<String, dynamic>> _generateArtisansForCategory(String category) {
    switch (category) {
      case 'Plumbing':
        return [
          {
            'id': '1',
            'name': 'John\'s Plumbing',
            'rating': 4.8,
            'reviews': 127,
            'location': const LatLng(40.7128, -74.0060), // New York City
            'services': [
              'Pipe Repair',
              'Drain Cleaning',
              'Water Heater',
              'Faucet Installation',
            ],
            'hourlyRate': 45.0,
            'available': true,
            'experience': '8 years',
            'certified': true,
          },
          {
            'id': '2',
            'name': 'Quick Fix Plumbing',
            'rating': 4.6,
            'reviews': 89,
            'location': const LatLng(40.7140, -74.0065), // Nearby NYC
            'services': ['Emergency Repairs', 'Leak Detection', 'Sewer Line'],
            'hourlyRate': 50.0,
            'available': true,
            'experience': '5 years',
            'certified': true,
          },
          {
            'id': '3',
            'name': 'Master Plumbers Co.',
            'rating': 4.9,
            'reviews': 203,
            'location': const LatLng(40.7135, -74.0055), // Nearby NYC
            'services': [
              'Commercial Plumbing',
              'New Construction',
              'Renovations',
            ],
            'hourlyRate': 65.0,
            'available': false,
            'experience': '15 years',
            'certified': true,
          },
        ];
      case 'Electrical':
        return [
          {
            'id': '4',
            'name': 'Mike\'s Electrical',
            'rating': 4.9,
            'reviews': 156,
            'location': const LatLng(40.7145, -74.0070), // Nearby NYC
            'services': [
              'Wiring',
              'Installation',
              'Repair',
              'Safety Inspections',
            ],
            'hourlyRate': 55.0,
            'available': true,
            'experience': '10 years',
            'certified': true,
          },
          {
            'id': '5',
            'name': 'Spark Electric',
            'rating': 4.7,
            'reviews': 98,
            'location': const LatLng(40.7150, -74.0060), // Nearby NYC
            'services': ['Residential', 'Commercial', 'Emergency Service'],
            'hourlyRate': 48.0,
            'available': true,
            'experience': '6 years',
            'certified': true,
          },
        ];
      case 'Cleaning':
        return [
          {
            'id': '6',
            'name': 'Clean Pro Services',
            'rating': 4.7,
            'reviews': 203,
            'location': const LatLng(40.7130, -74.0050), // Nearby NYC
            'services': [
              'House Cleaning',
              'Deep Cleaning',
              'Move-in/out',
              'Office Cleaning',
            ],
            'hourlyRate': 35.0,
            'available': false,
            'experience': '7 years',
            'certified': false,
          },
          {
            'id': '7',
            'name': 'Sparkle & Shine',
            'rating': 4.8,
            'reviews': 145,
            'location': const LatLng(40.7135, -74.0045), // Nearby NYC
            'services': [
              'Regular Cleaning',
              'Deep Cleaning',
              'Carpet Cleaning',
            ],
            'hourlyRate': 32.0,
            'available': true,
            'experience': '4 years',
            'certified': false,
          },
        ];
      default:
        return [
          {
            'id': '8',
            'name': 'General Services',
            'rating': 4.5,
            'reviews': 67,
            'location': const LatLng(40.7140, -74.0040), // Nearby NYC
            'services': ['General Repairs', 'Maintenance', 'Installation'],
            'hourlyRate': 40.0,
            'available': true,
            'experience': '3 years',
            'certified': false,
          },
        ];
    }
  }

  void _addArtisanMarkers() {
    for (final artisan in _artisans) {
      _artisanMarkers.add(
        Marker(
          markerId: MarkerId(artisan['id']),
          position: artisan['location'],
          infoWindow: InfoWindow(
            title: artisan['name'],
            snippet: '${widget.categoryName} • \$${artisan['hourlyRate']}/hr',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(widget.categoryColor),
          ),
        ),
      );
    }
  }

  double _getMarkerHue(Color color) {
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.brown) return BitmapDescriptor.hueRed;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    if (color == Colors.cyan) return BitmapDescriptor.hueCyan;
    return BitmapDescriptor.hueAzure;
  }

  List<Map<String, dynamic>> _getSortedArtisans() {
    List<Map<String, dynamic>> sorted = List.from(_artisans);

    switch (_sortBy) {
      case 'rating':
        sorted.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
        );
        break;
      case 'price':
        sorted.sort(
          (a, b) =>
              (a['hourlyRate'] as double).compareTo(b['hourlyRate'] as double),
        );
        break;
      case 'distance':
        // TODO: Implement distance-based sorting
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Header
          _buildCategoryHeader(),

          // Sort Options
          _buildSortOptions(),

          // Map or List View
          Expanded(child: _showMap ? _buildMapView() : _buildListView()),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.categoryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.categoryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.categoryIcon,
              color: widget.categoryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.categoryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_artisans.length} artisans available',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.categoryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Sort by: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          _buildSortChip('rating', 'Rating'),
          const SizedBox(width: 8),
          _buildSortChip('price', 'Price'),
          const SizedBox(width: 8),
          _buildSortChip('distance', 'Distance'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: widget.categoryColor.withValues(alpha: 0.2),
      checkmarkColor: widget.categoryColor,
      labelStyle: TextStyle(
        color: isSelected ? widget.categoryColor : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: isSelected ? widget.categoryColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(40.7128, -74.0060), // New York City center
            zoom: 16.0, // Closer zoom to see markers clearly
          ),
          onMapCreated: (GoogleMapController controller) {
            // Map controller created
          },
          markers: _artisanMarkers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
        ),
      ),
    );
  }

  Widget _buildListView() {
    final sortedArtisans = _getSortedArtisans();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedArtisans.length,
      itemBuilder: (context, index) {
        final artisan = sortedArtisans[index];
        return _buildArtisanCard(artisan);
      },
    );
  }

  Widget _buildArtisanCard(Map<String, dynamic> artisan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Artisan Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.categoryIcon,
                    color: widget.categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Artisan Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artisan['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${artisan['experience']} experience',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (artisan['certified']) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                            Text(
                              'Certified',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Heart icon for favorites
                FavoriteToggleButton(
                  artisanId: artisan['id']?.toString() ?? '',
                  artisanName: artisan['name']?.toString() ?? 'Artisan',
                  size: 28.0,
                  activeColor: Colors.red,
                  inactiveColor: Colors.grey.shade400,
                ),

                // Rating
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          artisan['rating'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '(${artisan['reviews']} reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Services
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (artisan['services'] as List<String>).map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Bottom Row
            Row(
              children: [
                Text(
                  '\$${artisan['hourlyRate']}/hr',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.categoryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: artisan['available']
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    artisan['available'] ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 12,
                      color: artisan['available']
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to artisan profile
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.categoryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
