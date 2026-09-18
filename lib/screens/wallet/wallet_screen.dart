import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF7FCFA);
  static const Color borderColor = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE7F8F4);
  static const Color orange = Color(0xFFFFA928);

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkTeal,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                child: Column(
                  children: [
                    _buildWalletHero(context),
                    const SizedBox(height: 14),
                    _buildQuickActions(context),
                    const SizedBox(height: 16),
                    _buildPromoCard(context),
                    const SizedBox(height: 22),
                    _buildSectionHeader(
                      title: 'Recent Transactions',
                      action: 'View All',
                      onTap: () => _showMessage(
                        context,
                        'All transactions will be connected later.',
                      ),
                    ),
                    const SizedBox(height: 11),
                    _buildTransactionCard(),
                    const SizedBox(height: 22),
                    _buildSectionHeader(title: 'Wallet Benefits'),
                    const SizedBox(height: 11),
                    _buildBenefitsCard(),
                    const SizedBox(height: 16),
                    _buildSecureNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 12),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
            white: true,
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Freegi Wallet',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Payments made easier',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _headerButton(
            icon: Icons.info_outline_rounded,
            onTap: () => _showMessage(
              context,
              'Freegi Wallet is currently a demo wallet. Real payments are not enabled.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    bool white = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: white ? Colors.white : lightMint,
            borderRadius: BorderRadius.circular(13),
            border: white ? Border.all(color: borderColor) : null,
          ),
          child: Icon(icon, color: white ? darkText : teal, size: 19),
        ),
      ),
    );
  }

  Widget _buildWalletHero(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 238,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF075C50), Color(0xFF078474), Color(0xFF00AFA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: .20),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            Positioned(
              right: -42,
              top: -50,
              child: Container(
                width: 165,
                height: 165,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -55,
              bottom: -90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .045),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Decorative premium wallet / coins illustration made entirely
            // with Flutter, so no additional image asset is required.
            Positioned(
              right: 17,
              top: 55,
              child: _walletIllustration(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Color(0xFFD4F1ED),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Freegi Wallet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'DEMO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 29),
                  const Text(
                    '₹0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Use your balance for faster checkout',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .76),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => _showMessage(
                        context,
                        'Add Money is unavailable in this demo build.',
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Add Money',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletIllustration() {
    return SizedBox(
      width: 126,
      height: 126,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 2,
            bottom: 17,
            child: Transform.rotate(
              angle: -.08,
              child: Container(
                width: 94,
                height: 66,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF113E39), Color(0xFF1D5E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .18),
                      blurRadius: 13,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 37,
                    height: 27,
                    margin: const EdgeInsets.only(right: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A8D76),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.circle,
                        color: Color(0xFFFFD05B),
                        size: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(right: 17, top: 10, child: _coin(32)),
          Positioned(right: 48, top: 24, child: _coin(27)),
          Positioned(right: 4, top: 43, child: _coin(23)),
          const Positioned(
            left: 12,
            top: 20,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFE39B),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coin(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE07A), Color(0xFFFFA928)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFEBAE), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '₹',
          style: TextStyle(
            color: const Color(0xFF9B6300),
            fontSize: size * .46,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            icon: Icons.receipt_long_rounded,
            title: 'Transactions',
            onTap: () => _showMessage(
              context,
              'No wallet transactions yet.',
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _actionCard(
            icon: Icons.local_offer_rounded,
            title: 'Offers',
            onTap: () => _showMessage(
              context,
              'Wallet offers & rewards will appear here when available.',
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _actionCard(
            icon: Icons.help_outline_rounded,
            title: 'Help',
            onTap: () => _showMessage(
              context,
              'Wallet payments are not enabled in this demo build.',
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _actionCard(
            icon: Icons.credit_card_rounded,
            title: 'UPI/Cards',
            onTap: () => _showMessage(
              context,
              'UPI and card payments are not enabled in this demo build.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: lightMint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: teal, size: 18),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkText,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return InkWell(
      onTap: () => _showMessage(
        context,
        'Exclusive Freegi wallet benefits will appear here.',
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 12, 12, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7DF), Color(0xFFFFFBF1)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFE8AC)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEDB8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_rounded,
                color: Color(0xFFE69400),
                size: 24,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet offers & rewards',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Exclusive Freegi wallet benefits will appear here.',
                    style: TextStyle(
                      color: subText,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFE69400),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? action,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: const TextStyle(
                color: teal,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: teal,
              size: 27,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'No transactions yet',
            style: TextStyle(
              color: darkText,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your Freegi Wallet activity will appear here once wallet payments are available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subText,
              fontSize: 9.3,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _benefitItem(
            icon: Icons.flash_on_rounded,
            title: 'Faster Checkout',
            subtitle: 'Designed for a faster checkout experience when wallet payments are enabled.',
          ),
          const SizedBox(height: 15),
          _benefitItem(
            icon: Icons.replay_circle_filled_rounded,
            title: 'Quick Refunds',
            subtitle:
                'Wallet refund support can be added with a future payment integration.',
          ),
          const SizedBox(height: 15),
          _benefitItem(
            icon: Icons.local_offer_rounded,
            title: 'Exclusive Offers',
            subtitle: 'Wallet-specific offers and rewards can appear here when available.',
          ),
        ],
      ),
    );
  }

  Widget _benefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: const BoxDecoration(
            color: lightMint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: teal, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: subText,
                  fontSize: 8.8,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecureNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: teal, size: 23),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo wallet only. Real money, UPI and card payments are not enabled in this build.',
              style: TextStyle(
                color: subText,
                fontSize: 9.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
