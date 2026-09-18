import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  static const Color teal = Color(0xFF00AFA8);
  static const Color darkTeal = Color(0xFF08756E);
  static const Color darkGreen = Color(0xFF075C50);
  static const Color background = Color(0xFFF8FCFA);
  static const Color text = Color(0xFF172321);
  static const Color subText = Color(0xFF71807D);
  static const Color border = Color(0xFFE1EBE9);
  static const Color mint = Color(0xFFE8F8F4);
  static const Color orange = Color(0xFFFFA928);

  static const String referralCode = 'FREEGI50';

  static const String _referralsKey = 'freegi_referral_count';
  static const String _earnedKey = 'freegi_referral_earned';

  int _referrals = 0;
  int _earned = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _referrals = prefs.getInt(_referralsKey) ?? 0;
      _earned = prefs.getInt(_earnedKey) ?? 0;
      _loading = false;
    });
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

  Future<void> _copyCode() async {
    await Clipboard.setData(const ClipboardData(text: referralCode));
    if (mounted) {
      _showMessage('Referral code copied.');
    }
  }

  Future<void> _shareReferral() async {
    const message =
        'Join Freegi and make grocery shopping simple and fresh! '
        'Use my referral code FREEGI50 when you sign up.';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'Join Freegi',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to open sharing options right now.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: teal),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
                      child: Column(
                        children: [
                          _buildHero(),
                          const SizedBox(height: 18),
                          _buildStats(),
                          const SizedBox(height: 18),
                          _buildReferralCard(),
                          const SizedBox(height: 18),
                          _buildHowItWorks(),
                          const SizedBox(height: 18),
                          _buildRewardInfo(),
                          const SizedBox(height: 22),
                          _buildInviteButton(),
                          const SizedBox(height: 12),
                          const Text(
                            'Referral rewards are subject to Freegi offer terms.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9AA5A3),
                              fontSize: 8.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: text,
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Refer & Earn',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Invite friends and earn rewards',
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: teal,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, darkTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FREEGI REWARDS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Share Freegi.\nEarn together.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Invite your friends to discover a faster and fresher way to shop.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 9.6,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.redeem_rounded,
              color: Colors.white,
              size: 47,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.group_outlined,
            value: '$_referrals',
            title: 'Friends Joined',
            iconColor: teal,
            iconBg: mint,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _statCard(
            icon: Icons.account_balance_wallet_outlined,
            value: '₹$_earned',
            title: 'Total Earned',
            iconColor: orange,
            iconBg: const Color(0xFFFFF4DE),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: subText,
                    fontSize: 8.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Referral Code',
            style: TextStyle(
              color: text,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share this code with friends when they join Freegi.',
            style: TextStyle(
              color: subText,
              fontSize: 9.4,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _copyCode,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCDEEE8)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      referralCode,
                      style: TextStyle(
                        color: darkTeal,
                        fontSize: 19,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy_rounded,
                    color: teal,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'COPY',
                    style: TextStyle(
                      color: teal,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              color: text,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _step(
            number: '1',
            icon: Icons.ios_share_rounded,
            title: 'Invite a friend',
            subtitle: 'Share your Freegi referral code with friends.',
          ),
          _stepDivider(),
          _step(
            number: '2',
            icon: Icons.person_add_alt_1_rounded,
            title: 'Friend joins Freegi',
            subtitle: 'They create an account using your referral code.',
          ),
          _stepDivider(),
          _step(
            number: '3',
            icon: Icons.shopping_bag_outlined,
            title: 'They place an eligible order',
            subtitle: 'The referral is completed after the qualifying order.',
          ),
          _stepDivider(),
          _step(
            number: '4',
            icon: Icons.wallet_giftcard_rounded,
            title: 'Reward is credited',
            subtitle: 'Eligible rewards can be added to your Freegi Wallet.',
          ),
        ],
      ),
    );
  }

  Widget _step({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: mint,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: teal,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: darkTeal, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: subText,
                    fontSize: 9,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: SizedBox(
        height: 16,
        child: VerticalDivider(
          width: 1,
          thickness: 1,
          color: border,
        ),
      ),
    );
  }

  Widget _buildRewardInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE7B1)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: orange,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rewards shown here are demo/local values until the referral '
              'system is connected to your backend and wallet.',
              style: TextStyle(
                color: Color(0xFF8B6718),
                fontSize: 9.3,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _shareReferral,
        icon: const Icon(Icons.send_rounded, size: 19),
        label: const Text(
          'Invite Friends',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
