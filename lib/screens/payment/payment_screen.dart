// import 'package:flutter/material.dart';
// import 'package:finance_tracker/data/services/payment_service.dart';
// import 'package:finance_tracker/screens/payment/widgets/stored_card_item.dart';
// import 'package:finance_tracker/screens/payment/widgets/add_card_modal.dart';
// import 'package:finance_tracker/screens/payment/widgets/pay_now_button.dart';
// import 'package:finance_tracker/screens/payment/widgets/no_saved_cards.dart';
// import 'package:finance_tracker/screens/payment/widgets/add_card_button.dart';
// import 'package:finance_tracker/utils/constants.dart';

// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({Key? key}) : super(key: key);

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   final PaymentService _paymentService = PaymentService();
//   String? _selectedMethod;
//   bool _isProcessingPayment = false;

//   Future<void> _processPayment() async {
//     if (_selectedMethod == null) {
//       _showSnackBar('Please select a payment method');
//       return;
//     }

//     setState(() => _isProcessingPayment = true);

//     try {
//       // Simulate payment processing delay
//       await Future.delayed(const Duration(seconds: 2));

//       // In a real app, you would call your payment service here
//       // await _paymentService.processPayment(_selectedMethod!);

//       _showSuccessDialog();
//       await playSuccessSound();
//     } catch (e) {
//       await playFailureSound();
//       _showSnackBar('Payment failed: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessingPayment = false);
//       }
//     }
//   }

//   final player = AudioPlayer();

//   Future<void> playSuccessSound() async {
//     await player.play(('sounds/success.mp3'));
//   }

//   Future<void> playFailureSound() async {
//     await player.play(('sounds/fail.mp3'));
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Payment Successful'),
//             content: const Text(
//               'Your transaction has been completed successfully.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showAddCardDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white, // Use a light color
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: AddCardModal(paymentService: _paymentService),
//           ),
//         );
//       },
//     ).then((_) {
//       // Refresh cards list after adding a new card
//       setState(() {});
//     });
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.black,
//       appBar: AppBar(
//         title: const Text(
//           "Payment Methods",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.darkGrey, AppColors.darkGrey],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               const Text(
//                 'Select Payment Method',
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: StreamBuilder(
//                   stream: _paymentService.getStoredCards(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           color: AppColors.primary,
//                         ),
//                       );
//                     }

//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Text(
//                           'Error loading cards: ${snapshot.error}',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       );
//                     }

//                     final cards = snapshot.data?.docs ?? [];
//                     if (cards.isEmpty) {
//                       return NoSavedCardsWidget(onAddCard: _showAddCardDialog);
//                     }

//                     return RefreshIndicator(
//                       color: AppColors.primary,
//                       onRefresh: () async => setState(() {}),
//                       child: ListView.separated(
//                         itemCount: cards.length,
//                         separatorBuilder:
//                             (_, __) =>
//                                 const Divider(color: Colors.white24, height: 1),
//                         itemBuilder: (context, index) {
//                           final card = cards[index];
//                           return StoredCardItem(
//                             card: card,
//                             paymentService: _paymentService,
//                             isSelected: _selectedMethod == card.id,
//                             onSelect:
//                                 () => setState(() => _selectedMethod = card.id),
//                             onDelete:
//                                 () => setState(() {
//                                   if (_selectedMethod == card.id) {
//                                     _selectedMethod = null;
//                                   }
//                                 }),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//               AddCardButton(onPressed: _showAddCardDialog),
//               const SizedBox(height: 12),
//               PayNowButton(
//                 selectedMethod: _selectedMethod,
//                 onPay: _processPayment,
//                 isLoading: _isProcessingPayment,
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "add_card_fab",
//         backgroundColor: AppColors.primary,
//         onPressed: _showAddCardDialog,
//         child: const Icon(Icons.add, size: 30),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:finance_tracker/data/services/payment_service.dart';
import 'package:finance_tracker/screens/payment/widgets/stored_card_item.dart';
import 'package:finance_tracker/screens/payment/widgets/add_card_modal.dart';
import 'package:finance_tracker/screens/payment/widgets/pay_now_button.dart';
import 'package:finance_tracker/screens/payment/widgets/no_saved_cards.dart';
import 'package:finance_tracker/screens/payment/widgets/add_card_button.dart';
import 'package:finance_tracker/utils/constants.dart';
import 'package:audioplayers/audioplayers.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  String? _selectedMethod;
  bool _isProcessingPayment = false;

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSuccessSound() async {
    await _player.play(AssetSource('sounds/success.mp3'));
  }

  Future<void> playFailureSound() async {
    await _player.play(AssetSource('sounds/fail.mp3'));
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) {
      _showSnackBar('Please select a payment method');
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      await playSuccessSound();
      _showSuccessDialog();
    } catch (e) {
      await playFailureSound();
      _showSnackBar('Payment failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: const Text(
              'Your transaction has been completed successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AddCardModal(paymentService: _paymentService),
          ),
        );
      },
    ).then((_) => setState(() {}));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          "Payment Methods",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkGrey, AppColors.darkGrey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select Payment Method',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder(
                  stream: _paymentService.getStoredCards(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading cards: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final cards = snapshot.data?.docs ?? [];
                    if (cards.isEmpty) {
                      return NoSavedCardsWidget(onAddCard: _showAddCardDialog);
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => setState(() {}),
                      child: ListView.separated(
                        itemCount: cards.length,
                        separatorBuilder:
                            (_, __) =>
                                const Divider(color: Colors.white24, height: 1),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return StoredCardItem(
                            card: card,
                            paymentService: _paymentService,
                            isSelected: _selectedMethod == card.id,
                            onSelect:
                                () => setState(() => _selectedMethod = card.id),
                            onDelete: () {
                              if (_selectedMethod == card.id) {
                                setState(() => _selectedMethod = null);
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              AddCardButton(onPressed: _showAddCardDialog),
              const SizedBox(height: 12),
              PayNowButton(
                selectedMethod: _selectedMethod,
                onPay: _processPayment,
                isLoading: _isProcessingPayment,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_card_fab",
        backgroundColor: AppColors.primary,
        onPressed: _showAddCardDialog,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
