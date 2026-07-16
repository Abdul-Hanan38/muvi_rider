import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../common/pickup_icon.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';

class TripUserDetailsWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripUserDetailsWidget({
    super.key,
    required this.cont,
    required this.arg,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium styling colors
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final addressTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final timeTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final showProfile =
        arg.historyData.userDetail != null && arg.historyData.isCancelled != 1;
    final stops = arg.historyData.requestStops;
    final hasStops = stops != null && stops.isNotEmpty;
    final dropAddress = arg.historyData.dropAddress;

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: cardBorder),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header
                if (showProfile) ...[
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          image: (arg.historyData.userDetail.data.profilePicture
                                  .isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(arg.historyData.userDetail
                                      .data.profilePicture),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(AppImages.defaultProfile),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyText(
                          text: arg.historyData.userDetail.data.name,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: addressTextColor,
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Timeline Route Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visual timeline vertical graphics
                    Column(
                      children: [
                        const SizedBox(height: 4),
                        // Pickup Node (Blue circle)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Vertical Connecting Line
                        Container(
                          width: 2,
                          height: hasStops || dropAddress.isNotEmpty ? 52 : 0,
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                        ),
                        // Drop Node (Red pin)
                        if (dropAddress.isNotEmpty && !hasStops)
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Address Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup Details
                          MyText(
                            text: arg.historyData.pickAddress,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: addressTextColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            text: arg.historyData.cvTripStartTime,
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: timeTextColor,
                            ),
                          ),

                          // Space between Pickup and Dropoff/Stops
                          if (hasStops || dropAddress.isNotEmpty)
                            const SizedBox(height: 24),

                          // Dropoff details (if no intermediate stops)
                          if (dropAddress.isNotEmpty && !hasStops) ...[
                            MyText(
                              text: dropAddress,
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: addressTextColor,
                                height: 1.3,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            MyText(
                              text: arg.historyData.cvCompletedAt,
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: timeTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Request Stops (Intermediate)
                if (hasStops) ...[
                  const SizedBox(height: 12),
                  ListView.builder(
                    itemCount: stops.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, i) {
                      final stopAddress = stops[i]['address'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const DropIcon(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: stopAddress,
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: addressTextColor,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    MyText(
                                      text: arg.historyData.cvCompletedAt,
                                      textStyle: TextStyle(
                                        color: timeTextColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
