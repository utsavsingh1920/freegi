import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/freegi_order.dart';
import '../../services/order_storage.dart';
import '../orders/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<FreegiOrderItem> cartItems;

  final int itemTotal;
  final int discount;
  final int deliveryFee;
  final int platformFee;
  final int totalAmount;

  const CheckoutScreen({
    super.key,
    this.cartItems = const [],
    this.itemTotal = 0,
    this.discount = 0,
    this.deliveryFee = 0,
    this.platformFee = 5,
    this.totalAmount = 0,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF8FCFA);
  static const Color borderColor =
      Color(0xFFE1EBE9);

  String selectedPayment = 'UPI';

  String _addressType = 'Home';
  String _deliveryAddress = '';
  String _landmark = '';
  String _area = '';
  String _city = '';
  String _state = '';
  String _postalCode = '';

  bool _loadingAddress = true;
  bool _isPlacingOrder = false;

  final List<Map<String, dynamic>>
      paymentMethods = const [
    {
      'id': 'UPI',
      'title': 'UPI',
      'subtitle': 'Google Pay, PhonePe, Paytm',
      'icon':
          Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'CARD',
      'title': 'Debit / Credit Card',
      'subtitle': 'Visa, Mastercard, RuPay',
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'COD',
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when your order arrives',
      'icon': Icons.payments_outlined,
    },
    {
      'id': 'WALLET',
      'title': 'Wallet / App Balance',
      'subtitle': 'Use your Freegi wallet',
      'icon':
          Icons.account_balance_wallet_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveryAddress();
  }

  // ============================================================
  // AMOUNTS
  // ============================================================

  int get itemTotal => widget.itemTotal;

  int get discount => widget.discount;

  int get deliveryFee => widget.deliveryFee;

  int get platformFee => widget.platformFee;

  int get calculatedTotal {
    return itemTotal -
        discount +
        deliveryFee +
        platformFee;
  }

  int get total {
    if (widget.totalAmount > 0) {
      return widget.totalAmount;
    }

    return calculatedTotal;
  }

  int get totalQuantity {
    return widget.cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  // ============================================================
  // LOAD SAVED DELIVERY ADDRESS
  // ============================================================

  Future<void> _loadDeliveryAddress() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final addressType =
          (prefs.getString(
                    'deliveryAddressType',
                  ) ??
                  'Home')
              .trim();

      final address =
          (prefs.getString(
                    'deliveryAddress',
                  ) ??
                  '')
              .trim();

      final landmark =
          (prefs.getString(
                    'deliveryLandmark',
                  ) ??
                  '')
              .trim();

      final area =
          (prefs.getString(
                    'deliveryArea',
                  ) ??
                  '')
              .trim();

      final city =
          (prefs.getString(
                    'deliveryCity',
                  ) ??
                  '')
              .trim();

      final state =
          (prefs.getString(
                    'deliveryState',
                  ) ??
                  '')
              .trim();

      final postalCode =
          (prefs.getString(
                    'deliveryPostalCode',
                  ) ??
                  '')
              .trim();

      if (!mounted) {
        return;
      }

      setState(() {
        _addressType =
            addressType.isEmpty
                ? 'Home'
                : addressType;

        _deliveryAddress = address;
        _landmark = landmark;
        _area = area;
        _city = city;
        _state = state;
        _postalCode = postalCode;

        _loadingAddress = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingAddress = false;
      });
    }
  }

  String get _addressMainLine {
    if (_deliveryAddress.isNotEmpty) {
      return _deliveryAddress;
    }

    final parts = <String>[
      if (_area.isNotEmpty) _area,
      if (_city.isNotEmpty) _city,
      if (_state.isNotEmpty) _state,
    ];

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return 'Delivery address not available';
  }

  String get _addressSecondaryLine {
    final parts = <String>[];

    if (_landmark.isNotEmpty &&
        !_deliveryAddress
            .toLowerCase()
            .contains(
              _landmark.toLowerCase(),
            )) {
      parts.add(_landmark);
    }

    if (_city.isNotEmpty &&
        !_deliveryAddress
            .toLowerCase()
            .contains(
              _city.toLowerCase(),
            )) {
      parts.add(_city);
    }

    if (_state.isNotEmpty &&
        !_deliveryAddress
            .toLowerCase()
            .contains(
              _state.toLowerCase(),
            )) {
      parts.add(_state);
    }

    if (_postalCode.isNotEmpty &&
        !_deliveryAddress.contains(
          _postalCode,
        )) {
      parts.add(_postalCode);
    }

    if (parts.isEmpty) {
      return 'Delivery address';
    }

    return parts.join(', ');
  }

  IconData get _addressIcon {
    switch (_addressType.toLowerCase()) {
      case 'work':
      case 'office':
        return Icons.business_rounded;

      case 'other':
        return Icons.location_on_rounded;

      case 'home':
      default:
        return Icons.home_rounded;
    }
  }

  // ============================================================
  // UNIQUE ORDER ID
  // ============================================================

  String _generateOrderId() {
    final now = DateTime.now();

    final year =
        now.year.toString().substring(2);

    final month =
        now.month.toString().padLeft(2, '0');

    final day =
        now.day.toString().padLeft(2, '0');

    final uniquePart =
        (now.microsecondsSinceEpoch % 100000)
            .toString()
            .padLeft(5, '0');

    return '#FRG$year$month$day$uniquePart';
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) {
      return;
    }

    if (widget.cartItems.isEmpty) {
      _showMessage(
        'Your cart is empty.',
      );
      return;
    }

    if (_loadingAddress) {
      _showMessage(
        'Please wait while we load your delivery address.',
      );
      return;
    }

    if (_deliveryAddress.isEmpty &&
        _area.isEmpty &&
        _city.isEmpty) {
      _showMessage(
        'Please add a delivery address before placing your order.',
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final String orderId =
          _generateOrderId();

      final FreegiOrder order =
          FreegiOrder(
        orderId: orderId,

        items: List<FreegiOrderItem>.from(
          widget.cartItems,
        ),

        itemTotal: itemTotal,
        discount: discount,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
        totalAmount: total,

        paymentMethod: selectedPayment,

        addressType: _addressType,
        deliveryAddress:
            _deliveryAddress.isNotEmpty
                ? _deliveryAddress
                : _addressMainLine,
        landmark: _landmark,
        area: _area,
        city: _city,
        state: _state,
        postalCode: _postalCode,

        deliverySlot: '25 - 35 minutes',

        status: 'Order Confirmed',
        type: 'active',

        placedAt: DateTime.now(),
      );

      await OrderStorage.saveOrder(
        order,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderSuccessScreen(
            orderId: order.orderId,
            totalAmount:
                order.totalAmount,
            paymentMethod:
                order.paymentMethod,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlacingOrder = false;
      });

      _showMessage(
        'Unable to place your order. Please try again.',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 2, 30, 8),
              child: Row(
                children: [
                  _checkoutProgressStep(1, 'Address', true),
                  _checkoutProgressLine(true),
                  _checkoutProgressStep(2, 'Payment', true),
                  _checkoutProgressLine(false),
                  _checkoutProgressStep(3, 'Review', false),
                ],
              ),
            ),

            Expanded(
              child:
                  SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  6,
                  18,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildStepTitle(
                      number: 1,
                      title:
                          'Delivery Address',
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _buildAddressCard(),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildStepTitle(
                      number: 2,
                      title:
                          'Payment Method',
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _buildPaymentCard(),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildStepTitle(
                      number: 3,
                      title:
                          'Order Summary',
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _buildOrderSummary(),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildSecurePaymentNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomBar(),
    );
  }

  Widget _checkoutProgressStep(
    int number,
    String label,
    bool active,
  ) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? teal : const Color(0xFFDDE5E3),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF82908D),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? darkText : const Color(0xFF8E9997),
              fontSize: 9.5,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkoutProgressLine(bool active) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF8DE0CE)
              : const Color(0xFFE4EAE8),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap:
                _isPlacingOrder
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                        );
                      },
            borderRadius:
                BorderRadius.circular(13),
            child: Container(
              width: 41,
              height: 41,
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                color: darkText,
                size: 18,
              ),
            ),
          ),

          const Spacer(),

          const Column(
            children: [
              Text(
                'Checkout',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Complete your order',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          Container(
            width: 41,
            height: 41,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFE5F8F4,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: teal,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP TITLE
  // ============================================================

  Widget _buildStepTitle({
    required int number,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration:
              const BoxDecoration(
            color: teal,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADDRESS CARD
  // ============================================================

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: _loadingAddress
          ? const SizedBox(
              height: 52,
              child: Center(
                child:
                    SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: teal,
                  ),
                ),
              ),
            )
          : Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration:
                      const BoxDecoration(
                    color: Color(
                      0xFFE5F8F4,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    _addressIcon,
                    color: teal,
                    size: 22,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        _addressType,
                        style:
                            const TextStyle(
                          color:
                              darkText,
                          fontSize: 13,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        _addressMainLine,
                        maxLines: 3,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              subText,
                          fontSize:
                              11.5,
                          height: 1.4,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        _addressSecondaryLine,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color: Color(
                            0xFF9AA5A3,
                          ),
                          fontSize: 10,
                          height: 1.35,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                TextButton(
                  onPressed:
                      _isPlacingOrder
                          ? null
                          : () {
                              _showMessage(
                                'Saved Addresses will be connected later.',
                              );
                            },
                  child: const Text(
                    'Change',
                    style:
                        TextStyle(
                      color: teal,
                      fontSize: 11,
                      fontWeight:
                          FontWeight
                              .w900,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Row(
              children: [
                const Text(
                  'Select a payment method',
                  style: TextStyle(
                    color: subText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F8F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: teal,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '100% Secure',
                        style: TextStyle(
                          color: darkTeal,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(
          paymentMethods.length,
          (index) {
            final payment =
                paymentMethods[index];

            final bool selected =
                selectedPayment ==
                    payment['id'];

            return Column(
              children: [
                InkWell(
                  onTap:
                      _isPlacingOrder
                          ? null
                          : () {
                              setState(
                                () {
                                  selectedPayment =
                                      payment['id']
                                          as String;
                                },
                              );
                            },
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFFF0FBF8,
                            )
                          : Colors
                              .transparent,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration:
                              BoxDecoration(
                            shape: BoxShape
                                .circle,
                            border:
                                Border.all(
                              color: selected
                                  ? teal
                                  : const Color(
                                      0xFFB8C3C1,
                                    ),
                              width: 2,
                            ),
                          ),
                          child:
                              Center(
                            child:
                                AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds:
                                    180,
                              ),
                              width:
                                  selected
                                      ? 11
                                      : 0,
                              height:
                                  selected
                                      ? 11
                                      : 0,
                              decoration:
                                  const BoxDecoration(
                                color: teal,
                                shape: BoxShape
                                    .circle,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Container(
                          width: 39,
                          height: 39,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF2F7F6,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              11,
                            ),
                          ),
                          child: Icon(
                            payment['icon']
                                as IconData,
                            color: selected
                                ? teal
                                : darkText,
                            size: 20,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                payment[
                                        'title']
                                    as String,
                                style:
                                    TextStyle(
                                  color: selected
                                      ? darkTeal
                                      : darkText,
                                  fontSize:
                                      12.5,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                payment[
                                        'subtitle']
                                    as String,
                                style:
                                    const TextStyle(
                                  color:
                                      subText,
                                  fontSize:
                                      9.5,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (selected)
                          const Icon(
                            Icons
                                .check_circle_rounded,
                            color: teal,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),

                if (index !=
                    paymentMethods.length -
                        1)
                  const Divider(
                    height: 1,
                    color: Color(
                      0xFFF0F3F2,
                    ),
                  ),
              ],
            );
          },
        ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _buildOrderSummary() {
    final int displayItemCount =
        totalQuantity > 0
            ? totalQuantity
            : widget.cartItems.length;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _summaryRow(
            'Items ($displayItemCount)',
            '₹$itemTotal',
          ),

          if (discount > 0) ...[
            const SizedBox(
              height: 12,
            ),
            _summaryRow(
              'Discount',
              '-₹$discount',
              valueColor:
                  const Color(
                0xFF268B60,
              ),
            ),
          ],

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Delivery Fee',
            deliveryFee == 0
                ? 'FREE'
                : '₹$deliveryFee',
            valueColor:
                deliveryFee == 0
                    ? const Color(
                        0xFF268B60,
                      )
                    : null,
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            'Platform Fee',
            '₹$platformFee',
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Divider(
              height: 1,
              color: Color(
                0xFFE5ECEA,
              ),
            ),
          ),

          _summaryRow(
            'Total',
            '₹$total',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold
                  ? darkText
                  : subText,
              fontSize:
                  bold ? 14 : 12,
              fontWeight: bold
                  ? FontWeight.w900
                  : FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            color:
                valueColor ?? darkText,
            fontSize:
                bold ? 16 : 12,
            fontWeight: bold
                ? FontWeight.w900
                : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECURE PAYMENT NOTE
  // ============================================================

  Widget _buildSecurePaymentNote() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFFE7F8F4),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: teal,
            size: 24,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Your payment details are secure and encrypted.\nWe never store your card or UPI details.',
              style: TextStyle(
                color: subText,
                fontSize: 10.5,
                height: 1.4,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        9,
        18,
        11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color:
                Colors.grey.withValues(
              alpha: 0.13,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 16,
            offset:
                const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style:
                      TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '₹$total',
                  style:
                      const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(
              width: 18,
            ),

            Expanded(
              child: SizedBox(
                height: 54,
                child:
                    ElevatedButton(
                  onPressed:
                      _isPlacingOrder
                          ? null
                          : _placeOrder,
                  style:
                      ElevatedButton
                          .styleFrom(
                    elevation: 0,
                    backgroundColor:
                        teal,
                    disabledBackgroundColor:
                        teal.withValues(
                      alpha: 0.65,
                    ),
                    foregroundColor:
                        Colors.white,
                    disabledForegroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),
                  ),
                  child:
                      _isPlacingOrder
                          ? const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                SizedBox(
                                  width:
                                      18,
                                  height:
                                      18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.2,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                      Colors
                                          .white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Placing Order...',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        14,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  'Place Order',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        15,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  size: 19,
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}