// import 'package:flutter/material.dart';

// class PremiumAccessScreen extends StatelessWidget {
//   const PremiumAccessScreen({super.key});

//   // Extracting the theme color for consistency
//   final Color primaryColor = const Color(0xFF5D5FEF);
//   final Color primaryText = const Color(0xFF1A1A1A);
//   final Color secondaryText = const Color(0xFF757575);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//           color: Colors.black,
//           onPressed: () {
//             // Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           "Premium access",
//           style: TextStyle(
//             color: primaryText,
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1.0),
//           child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24.0,
//                 vertical: 15.0,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 8.h),
//                   // Main Headline
//                   Text(
//                     "Premium access",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w800,
//                       color: primaryText,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   // Sub Headline
//                   Text(
//                     "Everything you need for private marketplace sale receipts",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: secondaryText,
//                       height: 1.4.h,
//                     ),
//                   ),
//                   SizedBox(height: 6.h),
//                   // Small Note
//                   Text(
//                     "Upgrade anytime. Cancel anytime.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
//                   ),
//                   SizedBox(height: 40.h),

//                   // Section 1: Free Trial
//                   _buildSectionHeader("Free trial"),
//                   SizedBox(height: 16.h),
//                   _buildFeatureItem("30 days of trial access"),
//                   _buildFeatureItem("Create and save up to 4 receipts"),
//                   _buildFeatureItem("Export receipts as PDF"),
//                   _buildFeatureItem("Attach 1 photo or screenshot"),
//                   _buildFeatureItem("Ads may play during trial"),

//                   SizedBox(height: 32.h),

                  // // Section 2: Premium Includes
                  // _buildSectionHeader("Premium"),
                  // SizedBox(height: 16.h),
                  // _buildFeatureItem("Unlimited receipts"),
                  // _buildFeatureItem("Attach up to 5 photos per receipt"),
                  // _buildFeatureItem("Unlimited PDF exports"),
                  // _buildFeatureItem("Save buyer details"),
                  // _buildFeatureItem("Save seller details"),
                  // _buildFeatureItem("Ad-free experience"),

//                   // Extra space at bottom to ensure scrolling doesn't hide behind button
//                   SizedBox(height: 20.h),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom Sticky Button Area
//           Container(
//             padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.03),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               height: 56.h,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF291AF6),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: Text(
//                   "Start free trial",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper widget for Section Headers
//   Widget _buildSectionHeader(String text) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.w700,
//           color: primaryText,
//         ),
//       ),
//     );
//   }

//   // Helper widget for List Items with Check Icon
//   Widget _buildFeatureItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.check_circle_outline_rounded,
//             color: primaryColor,
//             size: 22,
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 color: Colors.grey[800],
//                 height: 1.2, // Aligns text nicely with the icon
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
