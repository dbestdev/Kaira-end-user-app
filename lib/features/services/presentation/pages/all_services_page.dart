import 'package:flutter/material.dart';
import 'service_category_page.dart';

class AllServicesPage extends StatefulWidget {
  const AllServicesPage({super.key});

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = _popularServices();
    final filteredServices = _searchQuery.isEmpty
        ? services
        : services.where((service) {
            return service.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                service.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'All Services',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade500),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Results or Empty State
          Expanded(
            child: filteredServices.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final s = filteredServices[index];
                        return _ServiceTile(
                          title: s.title,
                          icon: s.icon,
                          color: s.color,
                          description: s.description,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceCategoryPage(
                                  categoryName: s.title,
                                  categoryIcon: s.icon,
                                  categoryColor: s.color,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  List<_Service> _popularServices() {
    return const [
      _Service(
        'Plumbing',
        Icons.plumbing,
        Colors.blue,
        'Fix leaks, install fixtures',
      ),
      _Service(
        'Electrical',
        Icons.electrical_services,
        Colors.orange,
        'Wiring & repairs',
      ),
      _Service(
        'Cleaning',
        Icons.cleaning_services,
        Colors.green,
        'Home & office',
      ),
      _Service(
        'Carpentry',
        Icons.handyman,
        Colors.brown,
        'Furniture & repairs',
      ),
      _Service('Painting', Icons.brush, Colors.purple, 'Interior & exterior'),
      _Service('Gardening', Icons.eco, Colors.teal, 'Landscaping & care'),
      _Service('AC Repair', Icons.ac_unit, Colors.cyan, 'Cooling systems'),
      _Service('Appliance', Icons.kitchen, Colors.indigo, 'Install & repair'),
      _Service('Roofing', Icons.roofing, Colors.red, 'Repair & installation'),
      _Service('Flooring', Icons.layers, Colors.amber, 'Tiles, wood & carpet'),
      _Service('Locksmith', Icons.lock, Colors.blueGrey, 'Keys & security'),
      _Service('Welding', Icons.hardware, Colors.grey, 'Metal work & repair'),
      _Service(
        'Auto Repair',
        Icons.car_repair,
        Colors.deepOrange,
        'Vehicle maintenance',
      ),
      _Service(
        'Solar Install',
        Icons.solar_power,
        Colors.yellow,
        'Solar panel setup',
      ),
      _Service(
        'Pool Service',
        Icons.pool,
        Colors.lightBlue,
        'Maintenance & repair',
      ),
      _Service('Pest Control', Icons.bug_report, Colors.green, 'Extermination'),
      _Service('HVAC', Icons.thermostat, Colors.blue, 'Heating & ventilation'),
      _Service(
        'Masonry',
        Icons.construction,
        Colors.brown,
        'Stone & brick work',
      ),
      _Service(
        'Interior Design',
        Icons.design_services,
        Colors.pink,
        'Home styling',
      ),
      _Service(
        'Photography',
        Icons.camera_alt,
        Colors.purple,
        'Event & portrait',
      ),
      _Service('Catering', Icons.restaurant, Colors.orange, 'Food & events'),
      _Service('Security', Icons.security, Colors.red, 'Systems & monitoring'),
      _Service(
        'Moving',
        Icons.local_shipping,
        Colors.indigo,
        'Relocation services',
      ),
      _Service(
        'Laundry',
        Icons.local_laundry_service,
        Colors.lightBlue,
        'Wash & dry cleaning',
      ),
    ];
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Service {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _Service(this.title, this.icon, this.color, this.description);
}
