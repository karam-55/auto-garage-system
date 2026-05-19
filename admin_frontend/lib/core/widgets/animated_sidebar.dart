import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/role.dart';

class AnimatedSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onLocaleToggle;
  final ThemeMode themeMode;

  const AnimatedSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isExpanded = true,
    this.onToggle,
    this.onThemeToggle,
    this.onLocaleToggle,
    required this.themeMode,
  });

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  String _companyName = 'Garage Go';
  String? _companyLogoUrl;

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
    _loadCompanySettings();
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

  Future<void> _loadCompanySettings() async {
    try {
      // Get API base URL from environment or use default
      final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://auto-garage-system-backend.onrender.com');
      final response = await http.get(Uri.parse('$baseUrl/api/company/settings'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _companyName = data['companyName'] ?? 'Garage Go';
            _companyLogoUrl = data['companyLogoUrl'];
          });
        }
      }
    } catch (e) {
      // Use default values on error
      print('Failed to load company settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          width: widget.isExpanded ? 260 : 80,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                        _companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'لوحة التحكم',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _companyLogoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      _companyLogoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.directions_car_rounded,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDestinations() {
    return Consumer(
      builder: (context, ref, child) {
        final userRoleString = ref.watch(userRoleProvider);
        final userRole = userRoleString != null ? RoleExtension.fromString(userRoleString) : null;
        
        final allDestinations = [
          _SidebarDestination(
            icon: Icons.dashboard_rounded,
            label: 'لوحة القيادة',
            index: 0,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.dashboard_rounded,
            label: 'نظرة عامة',
            index: 1,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.calendar_today_rounded,
            label: 'الحجوزات',
            index: 2,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.flash_on_rounded,
            label: 'حجز لعميل مسجل مسبقا',
            index: 3,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.people_rounded,
            label: 'العملاء',
            index: 4,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.directions_car_rounded,
            label: 'السيارات',
            index: 5,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.build_rounded,
            label: 'الخدمات',
            index: 6,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.work_rounded,
            label: 'الموظفين',
            index: 7,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.bar_chart_rounded,
            label: 'التقارير',
            index: 8,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.inventory_2_rounded,
            label: 'المخزون',
            index: 9,
            requiredRoles: null, // للجميع
          ),
          _SidebarDestination(
            icon: Icons.account_balance_rounded,
            label: 'دليل الحسابات',
            index: 10,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.receipt_long_rounded,
            label: 'القيود اليومية',
            index: 11,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.assessment_rounded,
            label: 'التقارير المالية',
            index: 12,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
            children: [
              _SidebarDestination(
                icon: Icons.balance_rounded,
                label: 'ميزان المراجعة',
                index: 13,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
              _SidebarDestination(
                icon: Icons.trending_up_rounded,
                label: 'قائمة الدخل',
                index: 14,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
              _SidebarDestination(
                icon: Icons.account_balance_wallet_rounded,
                label: 'الميزانية العمومية',
                index: 15,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
              _SidebarDestination(
                icon: Icons.menu_book_rounded,
                label: 'دفتر الأستاذ العام',
                index: 16,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
              _SidebarDestination(
                icon: Icons.account_balance_rounded,
                label: 'التدفقات النقدية',
                index: 17,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
              _SidebarDestination(
                icon: Icons.show_chart_rounded,
                label: 'نقطة التعادل',
                index: 18,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
              _SidebarDestination(
                icon: Icons.trending_up_rounded,
                label: 'تقرير المتجارة',
                index: 19,
                requiredRoles: [Role.owner, Role.manager, Role.accountant],
              ),
            ],
          ),
          _SidebarDestination(
            icon: Icons.settings_rounded,
            label: 'إعدادات الرواتب',
            index: 20,
            requiredRoles: [Role.owner, Role.manager, Role.hrManager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.receipt_long_rounded,
            label: 'كشوف الرواتب',
            index: 21,
            requiredRoles: [Role.owner, Role.manager, Role.hrManager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.description_rounded,
            label: 'تقرير الرواتب',
            index: 22,
            requiredRoles: [Role.owner, Role.manager, Role.hrManager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.people_rounded,
            label: 'الموردين',
            index: 23,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.receipt_long_rounded,
            label: 'فواتير الشراء',
            index: 24,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.account_balance_wallet_rounded,
            label: 'المصاريف',
            index: 25,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.account_balance_rounded,
            label: 'الحسابات البنكية',
            index: 26,
            requiredRoles: [Role.owner, Role.manager, Role.accountant],
          ),
          _SidebarDestination(
            icon: Icons.settings_rounded,
            label: 'إعدادات النظام',
            index: 27,
            requiredRoles: [Role.owner],
          ),
          _SidebarDestination(
            icon: Icons.lock_rounded,
            label: 'كلمة المرور',
            index: 28,
            requiredRoles: null, // للجميع
          ),
        ];

        // إضافة وحدات ERP بناءً على صلاحيات الدور
        final erpDestinations = <_SidebarDestination>[];
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerSales || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.shopping_cart_rounded,
            label: 'أوامر الشراء',
            index: 29,
            requiredRoles: [Role.owner, Role.manager, Role.managerSales, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerSales || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.description_rounded,
            label: 'عروض الأسعار',
            index: 30,
            requiredRoles: [Role.owner, Role.manager, Role.managerSales, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerSales || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.receipt_long_rounded,
            label: 'أوامر البيع',
            index: 31,
            requiredRoles: [Role.owner, Role.manager, Role.managerSales, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerWarehouse || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.warehouse_rounded,
            label: 'المستودعات',
            index: 32,
            requiredRoles: [Role.owner, Role.manager, Role.managerWarehouse, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerWarehouse || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.swap_horiz_rounded,
            label: 'نقل المخزون',
            index: 33,
            requiredRoles: [Role.owner, Role.manager, Role.managerWarehouse, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerWarehouse || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.list_alt_rounded,
            label: 'قوائم المواد',
            index: 34,
            requiredRoles: [Role.owner, Role.manager, Role.managerWarehouse, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerWarehouse || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.build_circle_rounded,
            label: 'أوامر الإنتاج',
            index: 35,
            requiredRoles: [Role.owner, Role.manager, Role.managerWarehouse, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerSales || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.people_outline_rounded,
            label: 'العملاء المحتملين',
            index: 36,
            requiredRoles: [Role.owner, Role.manager, Role.managerSales, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.hrManager || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.description_rounded,
            label: 'عقود الموظفين',
            index: 37,
            requiredRoles: [Role.owner, Role.manager, Role.hrManager, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.hrManager || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.event_busy_rounded,
            label: 'طلبات الإجازة',
            index: 38,
            requiredRoles: [Role.owner, Role.manager, Role.hrManager, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.account_balance_rounded,
            label: 'الأصول الثابتة',
            index: 39,
            requiredRoles: [Role.owner, Role.accountant],
          ));
        }
        
        if (userRole == Role.owner || userRole == Role.manager || userRole == Role.managerSales || userRole == Role.accountant) {
          erpDestinations.add(_SidebarDestination(
            icon: Icons.build_rounded,
            label: 'عقود الصيانة',
            index: 40,
            requiredRoles: [Role.owner, Role.manager, Role.managerSales, Role.accountant],
          ));
        }

        final destinations = [...allDestinations, ...erpDestinations];

        // تصفية العناصر التي يسمح بها دور المستخدم
        final filtered = destinations.where((dest) {
          if (dest.requiredRoles == null) return true;
          if (userRole == null) return false;
          return dest.requiredRoles!.contains(userRole);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _AnimatedDestinationItem(
              destination: filtered[index],
              isSelected: widget.selectedIndex == filtered[index].index,
              isExpanded: widget.isExpanded,
              expandAnimation: _expandAnimation,
              onTap: () => widget.onDestinationSelected(filtered[index].index),
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
            );
          },
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.onThemeToggle != null) ...[
            _AnimatedDestinationItem(
              destination: _SidebarDestination(
                icon: widget.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                label: widget.themeMode == ThemeMode.dark ? 'الوضع الفاتح' : 'الوضع الداكن',
                index: -2,
              ),
              isSelected: false,
              isExpanded: widget.isExpanded,
              expandAnimation: _expandAnimation,
              onTap: widget.onThemeToggle ?? () {},
            ),
            const SizedBox(height: 8),
          ],
          if (widget.onLocaleToggle != null) ...[
            _AnimatedDestinationItem(
              destination: _SidebarDestination(
                icon: Icons.language_rounded,
                label: 'اللغة',
                index: -3,
              ),
              isSelected: false,
              isExpanded: widget.isExpanded,
              expandAnimation: _expandAnimation,
              onTap: widget.onLocaleToggle ?? () {},
            ),
            const SizedBox(height: 8),
          ],
          _AnimatedDestinationItem(
            destination: _SidebarDestination(
              icon: Icons.logout_rounded,
              label: 'تسجيل الخروج',
              index: -1,
            ),
            isSelected: false,
            isExpanded: widget.isExpanded,
            expandAnimation: _expandAnimation,
            onTap: () {
              widget.onDestinationSelected(-1);
            },
            isDanger: true,
          ),
        ],
      ),
    );
  }
}

class _SidebarDestination {
  final IconData icon;
  final String label;
  final int index;
  final List<_SidebarDestination>? children;
  final List<Role>? requiredRoles;

  _SidebarDestination({
    required this.icon,
    required this.label,
    required this.index,
    this.children,
    this.requiredRoles,
  });
}

class _AnimatedDestinationItem extends StatefulWidget {
  final _SidebarDestination destination;
  final bool isSelected;
  final bool isExpanded;
  final Animation<double> expandAnimation;
  final VoidCallback onTap;
  final bool isDanger;
  final int? selectedIndex;
  final Function(int)? onDestinationSelected;

  const _AnimatedDestinationItem({
    required this.destination,
    required this.isSelected,
    required this.isExpanded,
    required this.expandAnimation,
    required this.onTap,
    this.isDanger = false,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  @override
  State<_AnimatedDestinationItem> createState() => _AnimatedDestinationItemState();
}

class _AnimatedDestinationItemState extends State<_AnimatedDestinationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.destination.children != null
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : _handleTap,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
                  child: Opacity(
                    opacity: _controller.isAnimating ? _opacityAnimation.value : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? (widget.isDanger
                                ? Colors.red.withValues(alpha: 0.15)
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15))
                            : (_isHovered
                                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isSelected
                              ? (widget.isDanger
                                  ? Colors.red.withValues(alpha: 0.4)
                                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4))
                              : (_isHovered
                                  ? Theme.of(context).dividerColor.withValues(alpha: 0.5)
                                  : Colors.transparent),
                          width: widget.isSelected || _isHovered ? 1.5 : 1,
                        ),
                        boxShadow: _isHovered && !widget.isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
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
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                            if (widget.destination.children != null)
                              Icon(
                                _isExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                          ],
                        ],
                     ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.destination.children != null && _isExpanded)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: widget.destination.children!.map((child) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _AnimatedDestinationItem(
                    destination: child,
                    isSelected: widget.selectedIndex == child.index,
                    isExpanded: widget.isExpanded,
                    expandAnimation: widget.expandAnimation,
                    onTap: () {
                      if (widget.onDestinationSelected != null) {
                        widget.onDestinationSelected!(child.index);
                      }
                    },
                    selectedIndex: widget.selectedIndex,
                    onDestinationSelected: widget.onDestinationSelected,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
