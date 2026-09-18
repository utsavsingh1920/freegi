import 'package:flutter/material.dart';
import '../orders/orders_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color bg = Color(0xFFF7FCFA);
  static const Color borderColor = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE8F8F4);
  static const Color orange = Color(0xFFFFA928);

  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  final List<Map<String, dynamic>> faqs = [
    {
      'question': 'Where is my order?',
      'answer':
          'You can track your active order from My Orders. Open the order and tap Track Order to view the latest delivery status.',
      'category': 'order',
    },
    {
      'question': 'How can I cancel my order?',
      'answer':
          'Order cancellation availability depends on the current order status. Open your order details to check whether cancellation is available.',
      'category': 'order',
    },
    {
      'question': 'What if an item is missing?',
      'answer':
          'If an item is missing from your delivered order, contact Freegi Support and provide your order ID and missing item details.',
      'category': 'order',
    },
    {
      'question': 'How do refunds work?',
      'answer':
          'Eligible refunds may be returned to your original payment method or Freegi Wallet depending on the payment and refund type.',
      'category': 'payment',
    },
    {
      'question': 'How can I use a coupon?',
      'answer':
          'Available coupons can be viewed from Offers & Coupons. Eligible coupons can be applied during checkout.',
      'category': 'offer',
    },
    {
      'question': 'How do I change my delivery address?',
      'answer':
          'You can manage delivery addresses from your Profile. Saved Addresses will allow you to add and select delivery locations.',
      'category': 'account',
    },
    {
      'question': 'How do I update my profile?',
      'answer':
          'Open Profile and use the edit option to update your account information when profile editing is enabled.',
      'category': 'account',
    },
  ];

  List<Map<String, dynamic>> get filteredFaqs {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return faqs;
    }

    return faqs.where((faq) {
      final question =
          (faq['question'] as String).toLowerCase();
      final answer =
          (faq['answer'] as String).toLowerCase();

      return question.contains(query) ||
          answer.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
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

  void _showHelpInfo({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E1DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: teal, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: subText,
                    fontSize: 10,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E1DF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Contact Freegi Support',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Choose how you would like to contact us.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                _contactOption(
                  icon: Icons.chat_rounded,
                  title: 'Chat with us',
                  subtitle: 'Start a support conversation',
                  iconColor: teal,
                  iconBg: lightMint,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      'Live chat will be connected later.',
                    );
                  },
                ),

                const SizedBox(height: 10),

                _contactOption(
                  icon: Icons.call_rounded,
                  title: 'Call support',
                  subtitle: 'Speak with our support team',
                  iconColor: const Color(0xFF3B82F6),
                  iconBg: const Color(0xFFEAF2FF),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      'Call support will be connected later.',
                    );
                  },
                ),

                const SizedBox(height: 10),

                _contactOption(
                  icon: Icons.email_rounded,
                  title: 'Email support',
                  subtitle: 'Send us your query',
                  iconColor: orange,
                  iconBg: const Color(0xFFFFF4DE),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      'Email support will be connected later.',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FCFB),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFAAB5B2),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredFaqs;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 17),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildQuickHelp(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Frequently Asked Questions'),
                  const SizedBox(height: 11),
                  if (items.isEmpty)
                    _buildEmptyState()
                  else
                    _buildFaqList(items),
                  const SizedBox(height: 22),
                  _buildContactCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkText,
                size: 18,
              ),
            ),
          ),

          const Spacer(),

          const Column(
            children: [
              Text(
                'Help & Support',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'We are here to help',
                style: TextStyle(
                  color: subText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          InkWell(
            onTap: _showContactSheet,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.headset_mic_rounded,
                color: teal,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 188,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal, teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -42,
              top: -52,
              child: Container(
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -55,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 9,
              bottom: 7,
              child: _supportAgentArtwork(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 22, 150, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FREEGI SUPPORT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.5,
                        letterSpacing: .65,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'How can we\nhelp you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.07,
                      letterSpacing: -.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Quick answers and friendly support, whenever you need it.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .76),
                      fontSize: 8.8,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
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

  Widget _supportAgentArtwork() {
    return SizedBox(
      width: 138,
      height: 158,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 116,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFFB),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(46),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 43,
            child: Container(
              width: 76,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD8BF),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .55),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 103,
            child: Container(
              width: 79,
              height: 43,
              decoration: const BoxDecoration(
                color: Color(0xFF243B38),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                  bottom: Radius.circular(16),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 43,
            bottom: 83,
            child: Icon(
              Icons.circle,
              color: Color(0xFF263A38),
              size: 6,
            ),
          ),
          const Positioned(
            right: 43,
            bottom: 83,
            child: Icon(
              Icons.circle,
              color: Color(0xFF263A38),
              size: 6,
            ),
          ),
          Positioned(
            bottom: 64,
            child: Container(
              width: 23,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFE98686),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 67,
            child: Container(
              width: 23,
              height: 47,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 5),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 67,
            child: Container(
              width: 23,
              height: 47,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 5),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 61,
            child: Container(
              width: 31,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 57,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD66B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            right: 3,
            top: 9,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFD66B),
              size: 21,
            ),
          ),
          const Positioned(
            left: 5,
            top: 35,
            child: Icon(
              Icons.chat_bubble_rounded,
              color: Color(0xFFB9F0DE),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: const TextStyle(
          color: darkText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search help topics...',
          hintStyle: const TextStyle(
            color: Color(0xFF9BA7A4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: teal,
            size: 21,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: subText,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Help'),

        const SizedBox(height: 11),

        Row(
          children: [
            Expanded(
              child: _quickHelpCard(
                icon: Icons.local_shipping_rounded,
                title: 'Track Order',
                subtitle: 'Check delivery',
                iconColor: teal,
                iconBg: lightMint,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _quickHelpCard(
                icon: Icons.currency_rupee_rounded,
                title: 'Refunds',
                subtitle: 'Payment help',
                iconColor: const Color(0xFF7A5AF8),
                iconBg: const Color(0xFFF0ECFF),
                onTap: () {
                  _showHelpInfo(
                    title: 'Refund Help',
                    message:
                        'Refund availability depends on the order and payment status. '
                        'Open My Orders to review the relevant order. Real payment and '
                        'refund processing is not enabled in this demo build.',
                    icon: Icons.currency_rupee_rounded,
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _quickHelpCard(
                icon: Icons.shopping_bag_rounded,
                title: 'Order Issue',
                subtitle: 'Missing item',
                iconColor: orange,
                iconBg: const Color(0xFFFFF4DE),
                onTap: () {
                  _showHelpInfo(
                    title: 'Order Issue',
                    message:
                        'For a missing or incorrect item, keep your order details ready '
                        'and review the order from My Orders. Direct support ticket '
                        'submission will be available when a support backend is connected.',
                    icon: Icons.shopping_bag_rounded,
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _quickHelpCard(
                icon: Icons.account_circle_rounded,
                title: 'Account',
                subtitle: 'Profile help',
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEAF2FF),
                onTap: () {
                  _showHelpInfo(
                    title: 'Account Help',
                    message:
                        'You can update profile details and manage account options from '
                        'Profile and Settings. Account support chat is not connected in '
                        'this demo build.',
                    icon: Icons.account_circle_rounded,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: subText,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: darkText,
          fontSize: 15.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildFaqList(
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      children: items.map((faq) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: _FaqItem(
            question: faq['question'] as String,
            answer: faq['answer'] as String,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: teal,
              size: 31,
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'No help topic found',
            style: TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try searching with a different keyword.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subText,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightMint,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: teal.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: teal,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Contact Freegi Support for assistance.',
                  style: TextStyle(
                    color: subText,
                    fontSize: 8.8,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          InkWell(
            onTap: _showContactSheet,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: teal,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'Contact',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkText = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color borderColor = Color(0xFFE1EBE9);
  static const Color lightMint = Color(0xFFE8F8F4);

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: expanded
                ? teal.withValues(
                    alpha: 0.22,
                  )
                : borderColor,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    color: lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: teal,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: subText,
                    size: 22,
                  ),
                ),
              ],
            ),

            if (expanded) ...[
              const SizedBox(height: 12),

              const Divider(
                height: 1,
                color: Color(0xFFEDF2F1),
              ),

              const SizedBox(height: 11),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    color: subText,
                    fontSize: 9.2,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}