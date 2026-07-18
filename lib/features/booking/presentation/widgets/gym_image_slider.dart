import 'package:flutter/material.dart';

import 'booking_theme.dart';

class GymImageSlider extends StatefulWidget {
  const GymImageSlider({super.key, required this.images});

  final List<String> images;

  @override
  State<GymImageSlider> createState() => _GymImageSliderState();
}

class _GymImageSliderState extends State<GymImageSlider> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullScreenImage(int initialIndex) {
    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (context) {
        final dialogPageController = PageController(initialPage: initialIndex);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  PageView.builder(
                    controller: dialogPageController,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: InteractiveViewer(
                          maxScale: 4.0,
                          minScale: 0.8,
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: BookingTheme.primary),
                              );
                            },
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 64,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openFullScreenImage(index),
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: BookingTheme.card,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.fitness_center,
                      color: BookingTheme.primary,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(75),
                  Colors.transparent,
                  BookingTheme.background.withAlpha(245),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? BookingTheme.primary
                        : Colors.white.withAlpha(105),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
