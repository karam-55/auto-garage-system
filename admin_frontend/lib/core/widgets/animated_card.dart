import 'package:flutter/material.dart';

class AnimatedDashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double? percentageChange;

  const AnimatedDashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.percentageChange,
  });

  @override
  State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<AnimatedDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHovered) {
        if (_isHovered != isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
          if (isHovered) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(_isHovered ? _scaleAnimation.value : 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(_isHovered ? 0.15 : 0.1),
                  widget.color.withOpacity(_isHovered ? 0.08 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color.withOpacity(_isHovered ? 0.4 : 0.15),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_isHovered ? 0.25 : 0.12),
                  blurRadius: _isHovered ? 24 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(_isHovered ? 0.25 : 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 28,
                          ),
                        ),
                        if (widget.percentageChange != null)
                          _buildPercentageChange(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.value,
                        key: ValueKey('value_$_isHovered'),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.color,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.title,
                        key: ValueKey('title_$_isHovered'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPercentageChange() {
    final isPositive = widget.percentageChange! >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.percentageChange!.abs()}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedServiceCard extends StatefulWidget {
  final String name;
  final String description;
  final double price;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnimatedServiceCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<AnimatedServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (isHovered) {
        if (_isHovered != isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
          if (isHovered) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _slideAnimation.value)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(_isHovered ? _scaleAnimation.value : 1.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                      : Theme.of(context).dividerColor,
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.06),
                    blurRadius: _isHovered ? 24 : 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isHovered
                              ? Row(
                                  key: const ValueKey('actions_visible'),
                                  children: [
                                    if (widget.onEdit != null)
                                      _buildActionButton(
                                        icon: Icons.edit_rounded,
                                        color: Theme.of(context).colorScheme.primary,
                                        onTap: widget.onEdit!,
                                      ),
                                    const SizedBox(width: 8),
                                    if (widget.onDelete != null)
                                      _buildActionButton(
                                        icon: Icons.delete_rounded,
                                        color: Colors.red,
                                        onTap: widget.onDelete!,
                                      ),
                                  ],
                                )
                              : const SizedBox.shrink(key: ValueKey('actions_hidden')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.price.toStringAsFixed(0)} ل.س',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}

class AnimatedCustomerTile extends StatefulWidget {
  final String name;
  final String phone;
  final String? address;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AnimatedCustomerTile({
    super.key,
    required this.name,
    required this.phone,
    this.address,
    this.onTap,
    this.onDelete,
  });

  @override
  State<AnimatedCustomerTile> createState() => _AnimatedCustomerTileState();
}

class _AnimatedCustomerTileState extends State<AnimatedCustomerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHovered) {
        if (_isHovered != isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
          if (isHovered) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _slideAnimation.value)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              transform: Matrix4.identity()..scale(_isHovered ? _scaleAnimation.value : 1.0),
              decoration: BoxDecoration(
                color: _isHovered
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).dividerColor,
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    widget.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.phone,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    if (widget.address != null)
                      Text(
                        widget.address!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isHovered && widget.onDelete != null
                      ? IconButton(
                          key: const ValueKey('delete_visible'),
                          icon: const Icon(Icons.delete_rounded),
                          color: Colors.red,
                          onPressed: widget.onDelete,
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          key: const ValueKey('delete_hidden'),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
