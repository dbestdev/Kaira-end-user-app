import 'package:flutter/material.dart';

class AllReviewsPage extends StatefulWidget {
  final Map<String, dynamic> artisan;

  const AllReviewsPage({super.key, required this.artisan});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  int? _selectedRating; // null => All, otherwise 5..1

  List<Map<String, dynamic>> get _reviews =>
      (widget.artisan['reviews'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      _dummyReviews;

  Map<int, int> _ratingCounts() {
    final Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in _reviews) {
      final rating = (r['rating'] is num)
          ? (r['rating'] as num).toInt()
          : int.tryParse(r['rating']?.toString() ?? '') ?? 5;
      counts[rating.clamp(1, 5)] = (counts[rating.clamp(1, 5)] ?? 0) + 1;
    }
    return counts;
  }

  double _averageRating() {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold<num>(0, (acc, r) {
      final rating = (r['rating'] is num)
          ? (r['rating'] as num).toDouble()
          : double.tryParse(r['rating']?.toString() ?? '') ?? 5.0;
      return acc + rating;
    });
    return (sum / _reviews.length).toDouble();
  }

  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedRating == null) return _reviews;
    return _reviews
        .where(
          (r) =>
              ((r['rating'] is num)
                  ? (r['rating'] as num).toInt()
                  : int.tryParse(r['rating']?.toString() ?? '') ?? 5) ==
              _selectedRating,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final counts = _ratingCounts();
    final avg = _averageRating();
    final total = _reviews.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Reviews · ${widget.artisan['businessName'] ?? 'Artisan'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSummary(avg, total, counts),
          _buildFilters(counts),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredReviews.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredReviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = _filteredReviews[index];
                      return _buildReviewCard(review);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(double avg, int total, Map<int, int> counts) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Average rating
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < avg.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total reviews',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i; // 5 to 1
                final count = counts[star] ?? 0;
                final fraction = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$star',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 10,
                            color: const Color(0xFF2196F3),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(Map<int, int> counts) {
    Widget chip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF2196F3) : Colors.grey.shade800,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: selected ? const Color(0xFF2196F3) : Colors.grey.shade300,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          chip(
            label: 'All (${_reviews.length})',
            selected: _selectedRating == null,
            onTap: () => setState(() => _selectedRating = null),
          ),
          const SizedBox(width: 8),
          ...List.generate(5, (i) {
            final star = 5 - i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: chip(
                label: '$star★ (${counts[star] ?? 0})',
                selected: _selectedRating == star,
                onTap: () => setState(() => _selectedRating = star),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['author']?.toString() ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        final rating = (review['rating'] as num?)?.toInt() ?? 5;
                        return Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review['date']?.toString() ?? '',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment']?.toString() ?? 'Great service!',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.reviews,
                color: Color(0xFF2196F3),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No reviews to show',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedRating == null
                  ? 'There are no reviews yet.'
                  : 'No $_selectedRating★ reviews yet.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

const List<Map<String, dynamic>> _dummyReviews = [
  {
    'author': 'Adeola A.',
    'rating': 5,
    'date': '2 days ago',
    'comment':
        'Exceptional work! Arrived on time and completed the job perfectly.',
  },
  {
    'author': 'Michael B.',
    'rating': 4,
    'date': '1 week ago',
    'comment': 'Very professional and courteous. Will hire again.',
  },
  {
    'author': 'Chiamaka O.',
    'rating': 5,
    'date': '3 weeks ago',
    'comment': 'Great attention to detail and quick turnaround.',
  },
];
