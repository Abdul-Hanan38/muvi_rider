import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class AssignedDriversWidget extends StatefulWidget {
  final BuildContext cont;
  const AssignedDriversWidget({super.key, required this.cont});

  @override
  State<AssignedDriversWidget> createState() => _AssignedDriversWidgetState();
}

class _AssignedDriversWidgetState extends State<AssignedDriversWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
    }
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;
    final searchBgColor =
        isDark ? const Color(0xFF131E35) : const Color(0xFFF1F5F9);

    return BlocProvider.value(
      value: widget.cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          final drivers = accBloc.driverData;

          // Filter drivers list based on search query
          final filteredDrivers = drivers.where((driver) {
            return driver.name.toLowerCase().contains(_searchQuery) ||
                driver.mobile.toLowerCase().contains(_searchQuery);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: Container(
              height: size.height * 0.7,
              width: size.width,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                color: scaffoldBgColor,
              ),
              child: Column(
                children: [
                  // Pill handle at the top
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 16),
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Text(
                    AppLocalizations.of(context)!.chooseDriverAssign,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: searchBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .vehicleDetailsSearchDriversText,
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Drivers list
                  Expanded(
                    child: filteredDrivers.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .vehicleDetailsNoDrivesFoundText,
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredDrivers.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final driver = filteredDrivers[index];
                              final originalIndex = drivers.indexOf(driver);
                              final isSelected =
                                  accBloc.choosenDriverToVehicle ==
                                      originalIndex;

                              return InkWell(
                                onTap: () {
                                  accBloc.choosenDriverToVehicle =
                                      originalIndex;
                                  accBloc.add(UpdateEvent());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : borderColor,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.01),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Profile image avatar
                                      Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor.withOpacity(0.1),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: (driver.profile.isNotEmpty)
                                            ? Image.network(
                                                driver.profile,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Center(
                                                    child: Text(
                                                      _getInitials(driver.name),
                                                      style: TextStyle(
                                                        color: primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Center(
                                                child: Text(
                                                  _getInitials(driver.name),
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Name & Phone
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              driver.name,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              driver.mobile,
                                              style: TextStyle(
                                                color: subtitleColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Radio Selection Circle
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? primaryColor
                                                : isDark
                                                    ? Colors.white
                                                        .withOpacity(0.2)
                                                    : const Color(0xFFCBD5E1),
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Pinned Assign Button
                  if (accBloc.choosenDriverToVehicle != null) ...[
                    SafeArea(
                        child: CustomButton(
                            buttonName: AppLocalizations.of(context)!.assign,
                            onTap: () {
                              Navigator.pop(context);
                              accBloc.add(AssignDriverEvent(
                                driverId:
                                    drivers[accBloc.choosenDriverToVehicle!].id,
                                fleetId: accBloc.choosenFleetToAssign!,
                              ));
                            })),
                    const SizedBox(height: 10)
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
