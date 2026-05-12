import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const AnimatedSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          width: widget.isExpanded ? 260 : 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1),
              Expanded(
                child: _buildDestinations(),
              ),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 80,
      child: Row(
        children: [
          _buildLogo(),
          if (widget.isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: FadeTransition(
                opacity: _expandAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.2, 0),
                    end: Offset.zero,
                  ).animate(_expandAnimation),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Garage Go',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'لوحة التحكم',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * math.pi * 2,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinations() {
    final destinations = [
      _SidebarDestination(
        icon: Icons.dashboard_rounded,
        label: 'نظرة عامة',
        index: 0,
      ),
      _SidebarDestination(
        icon: Icons.calendar_today_rounded,
        label: 'الحجوزات',
        index: 1,
      ),
      _SidebarDestination(
        icon: Icons.people_rounded,
        label: 'العملاء',
        index: 2,
      ),
      _SidebarDestination(
        icon: Icons.directions_car_rounded,
        label: 'السيارات',
        index: 3,
      ),
      _SidebarDestination(
        icon: Icons.build_rounded,
        label: 'الخدمات',
        index: 4,
      ),
      _SidebarDestination(
        icon: Icons.work_rounded,
        label: 'الموظفين',
        index: 5,
      ),
      _SidebarDestination(
        icon: Icons.bar_chart_rounded,
        label: 'التقارير',
        index: 6,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        return _AnimatedDestinationItem(
          destination: destinations[index],
          isSelected: widget.selectedIndex == index,
          isExpanded: widget.isExpanded,
          expandAnimation: _expandAnimation,
          onTap: () => widget.onDestinationSelected(index),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: _AnimatedDestinationItem(
        destination: _SidebarDestination(
          icon: Icons.logout_rounded,
          label: 'تسجيل الخروج',
          index: -1,
        ),
        isSelected: false,
        isExpanded: widget.isExpanded,
        expandAnimation: _expandAnimation,
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/');
        },
        isDanger: true,
      ),
    );
  }
}

class _SidebarDestination {
  final IconData icon;
  final String label;
  final int index;

  _SidebarDestination({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class _AnimatedDestinationItem extends StatefulWidget {
  final _SidebarDestination destination;
  final bool isSelected;
  final bool isExpanded;
  final Animation<double> expandAnimation;
  final VoidCallback onTap;
  final bool isDanger;

  const _AnimatedDestinationItem({
    required this.destination,
    required this.isSelected,
    required this.isExpanded,
    required this.expandAnimation,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_AnimatedDestinationItem> createState() => _AnimatedDestinationItemState();
}

class _AnimatedDestinationItemState extends State<_AnimatedDestinationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? (widget.isDanger
                          ? Colors.red.withOpacity(0.1)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1))
                      : (_isHovered
                          ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? (widget.isDanger
                            ? Colors.red.withOpacity(0.3)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.3))
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.destination.icon,
                      size: 24,
                      color: widget.isSelected
                          ? (widget.isDanger
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    if (widget.isExpanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeTransition(
                          opacity: widget.expandAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.2, 0),
                              end: Offset.zero,
                            ).animate(widget.expandAnimation),
                            child: Text(
                              widget.destination.label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: widget.isSelected
                                        ? (widget.isDanger
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.primary)
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
