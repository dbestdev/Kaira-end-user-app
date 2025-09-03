import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class GuestDashboard extends StatefulWidget {
  const GuestDashboard({super.key});

  @override
  State<GuestDashboard> createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  GoogleMapController? _mapController;
  final Set<Marker> _artisanMarkers = {};
  String _selectedCategory = 'All';
  bool _showMap = true;

  // Sample artisan data for demonstration
  final List<Map<String, dynamic>> _artisans = [
    {
      'id': '1',
      'name': 'John\'s Plumbing',
      'category': 'Plumbing',
      'rating': 4.8,
      'reviews': 127,
      'location': const LatLng(40.7128, -74.0060), // New York City
      'services': ['Pipe Repair', 'Drain Cleaning', 'Water Heater'],
      'hourlyRate': 45.0,
      'available': true,
    },
    {
      'id': '2',
      'name': 'Mike\'s Electrical',
      'category': 'Electrical',
      'rating': 4.9,
      'reviews': 89,
      'location': const LatLng(40.7140, -74.0065), // Nearby NYC
      'services': ['Wiring', 'Installation', 'Repair'],
      'hourlyRate': 55.0,
      'available': true,
    },
    {
      'id': '3',
      'name': 'Clean Pro Services',
      'category': 'Cleaning',
      'rating': 4.7,
      'reviews': 203,
      'location': const LatLng(40.7135, -74.0055), // Nearby NYC
      'services': ['House Cleaning', 'Deep Cleaning', 'Move-in/out'],
      'hourlyRate': 35.0,
      'available': false,
    },
    {
      'id': '4',
      'name': 'Bob\'s Carpentry',
      'category': 'Carpentry',
      'rating': 4.6,
      'reviews': 156,
      'location': const LatLng(40.7150, -74.0070), // Nearby NYC
      'services': ['Furniture Repair', 'Custom Woodwork', 'Installation'],
      'hourlyRate': 50.0,
      'available': true,
    },
    {
      'id': '5',
      'name': 'Paint Masters',
      'category': 'Painting',
      'rating': 4.8,
      'reviews': 98,
      'location': const LatLng(40.7145, -74.0050), // Nearby NYC
      'services': [
        'Interior Painting',
        'Exterior Painting',
        'Color Consultation',
      ],
      'hourlyRate': 40.0,
      'available': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _addArtisanMarkers();
  }

  void _addArtisanMarkers() {
    for (final artisan in _artisans) {
      _artisanMarkers.add(
        Marker(
          markerId: MarkerId(artisan['id']),
          position: artisan['location'],
          infoWindow: InfoWindow(
            title: artisan['name'],
            snippet: '${artisan['category']} • \$${artisan['hourlyRate']}/hr',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(artisan['category']),
          ),
        ),
      );
    }
  }

  void _fitMarkersInView() {
    if (_artisanMarkers.isEmpty || _mapController == null) return;

    // Calculate bounds for all markers
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _artisanMarkers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    // Add padding to bounds
    const double padding = 0.01; // About 1km padding
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    // Animate camera to show all markers
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0, // Padding in pixels
      ),
    );
  }

  double _getMarkerColor(String category) {
    switch (category) {
      case 'Plumbing':
        return BitmapDescriptor.hueBlue;
      case 'Electrical':
        return BitmapDescriptor.hueOrange;
      case 'Cleaning':
        return BitmapDescriptor.hueGreen;
      case 'Carpentry':
        return BitmapDescriptor.hueRed;
      case 'Painting':
        return BitmapDescriptor.hueViolet;
      case 'HVAC':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  List<Map<String, dynamic>> _getFilteredArtisans() {
    if (_selectedCategory == 'All') {
      return _artisans;
    }
    return _artisans
        .where((artisan) => artisan['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'KAIRA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
                letterSpacing: 2.0,
              ),
            ),
            // Development mode indicator
            if (AppConstants.skipAuthentication)
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DEV',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          _buildCategoryFilter(),

          // Map or List View
          Expanded(child: _showMap ? _buildMapView() : _buildListView()),

          // Guest Mode Banner
          _buildGuestBanner(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All', true),
          ...AppConstants.serviceCategories.map(
            (category) => _buildCategoryChip(category, false),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isAll) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF2196F3),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
        ),
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
            _mapController = controller;
            // Fit all markers in view
            _fitMarkersInView();
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
    final filteredArtisans = _getFilteredArtisans();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredArtisans.length,
      itemBuilder: (context, index) {
        final artisan = filteredArtisans[index];
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
                    color: _getCategoryColor(
                      artisan['category'],
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(artisan['category']),
                    color: _getCategoryColor(artisan['category']),
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
                      Text(
                        artisan['category'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
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
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
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

  Widget _buildGuestBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(top: BorderSide(color: Colors.orange.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Guest Mode: You can browse services but need to sign in to book or contact artisans.',
              style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Plumbing':
        return Colors.blue;
      case 'Electrical':
        return Colors.orange;
      case 'Cleaning':
        return Colors.green;
      case 'Carpentry':
        return Colors.brown;
      case 'Painting':
        return Colors.purple;
      case 'HVAC':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Carpentry':
        return Icons.handyman;
      case 'Painting':
        return Icons.format_paint;
      case 'HVAC':
        return Icons.ac_unit;
      default:
        return Icons.work;
    }
  }
}
