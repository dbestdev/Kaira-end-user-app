import 'package:flutter/material.dart';
import '../services/favorite_artisans_service.dart';
import '../services/api_service.dart';

class FavoriteToggleButton extends StatefulWidget {
  final String artisanId;
  final String? artisanName;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final VoidCallback? onToggle;

  const FavoriteToggleButton({
    super.key,
    required this.artisanId,
    this.artisanName,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.onToggle,
  });

  @override
  State<FavoriteToggleButton> createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton>
    with SingleTickerProviderStateMixin {
  final FavoriteArtisansService _favoriteArtisansService =
      FavoriteArtisansService(ApiService());

  bool _isFavorite = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _favoriteArtisansService.isFavorite(
        widget.artisanId,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    } catch (e) {
      // Silently handle error - button will show as not favorite
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newFavoriteStatus = await _favoriteArtisansService.toggleFavorite(
        widget.artisanId,
      );

      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteStatus;
        });

        // Animate the button
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        // Show success message
        final message = _isFavorite
            ? 'Added ${widget.artisanName ?? 'artisan'} to favorites'
            : 'Removed ${widget.artisanName ?? 'artisan'} from favorites';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: _isFavorite ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Call the callback if provided
        widget.onToggle?.call();
      }
    } catch (e) {
      if (mounted) {
        // Handle error silently

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle favorites: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            onPressed: _isLoading ? null : _toggleFavorite,
            icon: _isLoading
                ? SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.activeColor ?? Colors.red,
                      ),
                    ),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: widget.size,
                    color: _isFavorite
                        ? (widget.activeColor ?? Colors.red)
                        : (widget.inactiveColor ?? Colors.grey),
                  ),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            splashRadius: widget.size + 8,
          ),
        );
      },
    );
  }
}
