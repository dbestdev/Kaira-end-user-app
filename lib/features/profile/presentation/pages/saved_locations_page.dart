import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/models/saved_location_model.dart';
import '../../../../core/services/saved_locations_service.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/config/api_keys.dart';

class SavedLocationsPage extends StatefulWidget {
  const SavedLocationsPage({super.key});

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<SavedLocationsPage> {
  List<SavedLocationModel> _savedLocations = [];
  bool _isLoading = true;
  String? _error;

  final SavedLocationsService _savedLocationsService = SavedLocationsService();
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final locations = await _savedLocationsService.getSavedLocations();
      setState(() {
        _savedLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Locations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildContent()),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showAddLocationOptions,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_location, size: 24),
        label: const Text(
          'Add Location',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_savedLocations.isEmpty) {
      return _buildEmptyState();
    }

    return _buildLocationsList();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Location cards shimmer
          ...List.generate(3, (index) => _buildShimmerLocationCard()),
        ],
      ),
    );
  }

  Widget _buildShimmerLocationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon shimmer
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            // Content shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Menu shimmer
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 48,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Saved Locations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your frequently used addresses for quick and easy service booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _showAddLocationOptions,
                icon: const Icon(Icons.add_location, size: 20),
                label: const Text(
                  'Add Your First Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Error Loading Locations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _loadSavedLocations,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Saved Locations (${_savedLocations.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedLocations.length,
          itemBuilder: (context, index) {
            final location = _savedLocations[index];
            return _buildLocationCard(location);
          },
        ),
      ],
    );
  }

  Widget _buildLocationCard(SavedLocationModel location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLocationDetails(location),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: location.isDefault
                        ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    location.isDefault ? Icons.home : Icons.location_on,
                    color: location.isDefault
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (location.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          location.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleLocationAction(value, location),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.home, size: 20),
                          SizedBox(width: 8),
                          Text('Set as Default'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 20),
                          SizedBox(width: 8),
                          Text('Copy Address'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLocationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.search,
              title: 'Search Places',
              subtitle: 'Find and add any address',
              onTap: () {
                Navigator.pop(context);
                _showGooglePlacesSearch();
              },
            ),
            _buildOptionTile(
              icon: Icons.my_location,
              title: 'Use Current Location',
              subtitle: 'Add your current position',
              onTap: () {
                Navigator.pop(context);
                _useCurrentLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2196F3)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _showGooglePlacesSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _GooglePlacesSearchPage(onPlaceSelected: _addLocationFromPlace),
      ),
    );
  }

  void _useCurrentLocation() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
          ),
        ),
      );

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Navigator.pop(context); // Close loading dialog

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        _showLocationNameDialog(
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        _showErrorSnackBar('Could not get address for current location');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Error getting current location: $e');
    }
  }

  void _addLocationFromPlace(GooglePlace place) async {
    print(
      '_addLocationFromPlace called with: ${place.placeId} - ${place.name}',
    );

    // If coordinates are not available, fetch them
    if (place.latitude == 0.0 && place.longitude == 0.0) {
      try {
        print('Fetching place details for placeId: ${place.placeId}');

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
        );

        // Fetch place details to get coordinates
        final placeDetails = await _googlePlacesService.getPlaceDetails(
          place.placeId,
        );

        print(
          'Place details fetched: ${placeDetails.latitude}, ${placeDetails.longitude}',
        );

        Navigator.pop(context); // Close loading dialog

        _showLocationNameDialog(
          address: placeDetails.address,
          latitude: placeDetails.latitude,
          longitude: placeDetails.longitude,
          placeId: placeDetails.placeId,
        );
      } catch (e) {
        print('Error fetching place details: $e');
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar('Error getting place details: $e');
      }
    } else {
      print(
        'Using provided coordinates: ${place.latitude}, ${place.longitude}',
      );
      _showLocationNameDialog(
        address: place.address,
        latitude: place.latitude,
        longitude: place.longitude,
        placeId: place.placeId,
      );
    }
  }

  void _addLocationFromData({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? placeId,
  }) async {
    try {
      await _savedLocationsService.addSavedLocation(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        placeId: placeId,
      );

      _showSuccessSnackBar(
        '🎉 Location saved successfully! Check your notifications and email for confirmation.',
      );
      _loadSavedLocations(); // Refresh the list
    } catch (e) {
      _showErrorSnackBar('Error saving location: $e');
    }
  }

  void _addLocationFromCallback(
    String name,
    String address,
    double latitude,
    double longitude,
    String? description,
    String? placeId,
  ) {
    _addLocationFromData(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description,
      placeId: placeId,
    );
  }

  void _showLocationDetails(SavedLocationModel location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${location.address}'),
            if (location.description != null)
              Text('Description: ${location.description}'),
            Text('Coordinates: ${location.latitude}, ${location.longitude}'),
            Text('Added: ${location.timeAgo}'),
            if (location.isDefault) const Text('Status: Default Location'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLocationNameDialog({
    required String address,
    required double latitude,
    required double longitude,
    String? placeId,
  }) {
    showDialog(
      context: context,
      builder: (context) => _LocationNameDialog(
        address: address,
        latitude: latitude,
        longitude: longitude,
        placeId: placeId,
        onSave: _addLocationFromCallback,
      ),
    );
  }

  void _handleLocationAction(String action, SavedLocationModel location) {
    switch (action) {
      case 'set_default':
        _setAsDefault(location);
        break;
      case 'edit':
        _showEditLocationDialog(location);
        break;
      case 'copy':
        _copyAddress(location);
        break;
      case 'delete':
        _showDeleteConfirmation(location);
        break;
    }
  }

  void _setAsDefault(SavedLocationModel location) async {
    try {
      print('Setting location as default: ${location.id} - ${location.name}');
      await _savedLocationsService.setDefaultLocation(location.id);
      print('Successfully set location as default');
      _showSuccessSnackBar('Default location updated!');
      _loadSavedLocations(); // Refresh the list
    } catch (e) {
      print('Error setting default location: $e');
      _showErrorSnackBar('Error setting default location: $e');
    }
  }

  void _showEditLocationDialog(SavedLocationModel location) {
    showDialog(
      context: context,
      builder: (context) => _LocationNameDialog(
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
        placeId: location.placeId,
        initialName: location.name,
        initialDescription: location.description,
        onSave: (name, address, latitude, longitude, description, placeId) {
          _updateLocation(
            location.id,
            name,
            address,
            latitude,
            longitude,
            description,
            placeId,
          );
        },
      ),
    );
  }

  void _updateLocation(
    String id,
    String name,
    String address,
    double latitude,
    double longitude,
    String? description,
    String? placeId,
  ) async {
    try {
      await _savedLocationsService.updateSavedLocation(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        placeId: placeId,
      );
      _showSuccessSnackBar('Location updated successfully!');
      _loadSavedLocations(); // Refresh the list
    } catch (e) {
      _showErrorSnackBar('Error updating location: $e');
    }
  }

  void _copyAddress(SavedLocationModel location) {
    Clipboard.setData(ClipboardData(text: location.address));
    _showSuccessSnackBar('Address copied to clipboard!');
  }

  void _showDeleteConfirmation(SavedLocationModel location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _savedLocationsService.deleteSavedLocation(location.id);
                _showSuccessSnackBar(
                  '🗑️ Location deleted successfully! Check your notifications and email for confirmation.',
                );
                _loadSavedLocations(); // Refresh the list
              } catch (e) {
                _showErrorSnackBar('Error deleting location: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _GooglePlacesSearchPage extends StatefulWidget {
  final Function(GooglePlace) onPlaceSelected;

  const _GooglePlacesSearchPage({required this.onPlaceSelected});

  @override
  State<_GooglePlacesSearchPage> createState() =>
      _GooglePlacesSearchPageState();
}

class _GooglePlacesSearchPageState extends State<_GooglePlacesSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _disposed = false;

  @override
  void dispose() {
    if (!_disposed) {
      _searchController.dispose();
      _disposed = true;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Places',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GooglePlacesAutoCompleteTextFormField(
        textEditingController: _searchController,
        config: GoogleApiConfig(
          apiKey: ApiKeys.googlePlacesApiKey,
          countries: ['ng'], // Nigeria
          fetchPlaceDetailsWithCoordinates: true,
          debounceTime: 400,
        ),
        onSuggestionClicked: (prediction) {
          // Handle suggestion click - show location name dialog
          _handlePlaceSelection(prediction);
        },
        decoration: InputDecoration(
          hintText: 'Search for places, addresses...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.search, color: const Color(0xFF2196F3), size: 24),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return SizedBox(height: 400, child: _buildEmptyState());
  }

  void _handlePlaceSelection(dynamic prediction) {
    try {
      print('Place selected: ${prediction.toString()}');

      // Create a GooglePlace from the prediction
      final googlePlace = GooglePlace(
        placeId: prediction.placeId ?? '',
        name:
            prediction.structuredFormatting?.mainText ??
            prediction.description ??
            '',
        address: prediction.description ?? '',
        latitude: 0.0, // Will be fetched when needed
        longitude: 0.0, // Will be fetched when needed
      );

      print(
        'Created GooglePlace: ${googlePlace.placeId} - ${googlePlace.name}',
      );

      // Call the callback to handle the selection
      widget.onPlaceSelected(googlePlace);
      Navigator.pop(context);
    } catch (e) {
      print('Error handling place selection: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting place: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3).withValues(alpha: 0.1),
                  const Color(0xFF1976D2).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF2196F3),
              size: 64,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Search for Places',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Type to find restaurants, landmarks, addresses, and more',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: const Color(0xFF2196F3),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Try searching for "Lagos" or "Victoria Island"',
                    style: TextStyle(
                      color: const Color(0xFF2196F3),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationNameDialog extends StatefulWidget {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? initialName;
  final String? initialDescription;
  final Function(
    String name,
    String address,
    double latitude,
    double longitude,
    String? description,
    String? placeId,
  )
  onSave;

  const _LocationNameDialog({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.initialName,
    this.initialDescription,
    required this.onSave,
  });

  @override
  State<_LocationNameDialog> createState() => _LocationNameDialogState();
}

class _LocationNameDialogState extends State<_LocationNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
  }

  @override
  void dispose() {
    if (!_disposed) {
      _nameController.dispose();
      _descriptionController.dispose();
      _disposed = true;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Location'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Location Name *',
                hintText: 'e.g., Home, Office, Gym',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.address,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add a note about this location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        widget.address,
        widget.latitude,
        widget.longitude,
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        widget.placeId,
      );
      Navigator.pop(context);
    }
  }
}
