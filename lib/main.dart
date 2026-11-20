import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KadanBookApp());
}

// --- DATA MODELS ---
class BillTransaction {
  final String id;
  final String title;
  final double billAmount;
  final double paidAmount;
  final DateTime date;

  BillTransaction({
    required this.id,
    required this.title,
    required this.billAmount,
    required this.paidAmount,
    required this.date,
  });

  double get balance => (billAmount - paidAmount).clamp(0, double.infinity);
}

class CustomerAccount {
  final String id;
  String name;
  String phone;
  List<BillTransaction> transactions;

  CustomerAccount({
    required this.id,
    required this.name,
    required this.phone,
    required this.transactions,
  });

  double get totalBill =>
      transactions.fold(0, (sum, item) => sum + item.billAmount);

  double get totalPaid =>
      transactions.fold(0, (sum, item) => sum + item.paidAmount);

  double get balanceDue => (totalBill - totalPaid).clamp(0, double.infinity);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
  }
}

enum AppAccent { emerald, navy, slate }

const List<IconData> _avatarIcons = [
  Icons.storefront_rounded,
  Icons.person_rounded,
  Icons.business_center_rounded,
  Icons.account_balance_rounded,
];

// --- MAIN APP ROOT ---
class KadanBookApp extends StatefulWidget {
  const KadanBookApp({super.key});

  @override
  State<KadanBookApp> createState() => _KadanBookAppState();
}

class _KadanBookAppState extends State<KadanBookApp> {
  bool _isDarkMode = false;
  AppAccent _accent = AppAccent.emerald;
  String _shopName = 'Al-Ameen Traders';
  String _ownerName = 'M.K.M. Sahras';
  int _avatarIndex = 0;

  final List<CustomerAccount> _customers = [
    CustomerAccount(
      id: 'c1',
      name: 'Mohamed Rifas',
      phone: '+94 77 412 8890',
      transactions: [
        BillTransaction(
          id: 't1',
          title: 'Wholesale Rice & Sugar (50kg)',
          billAmount: 18500,
          paidAmount: 10000,
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        BillTransaction(
          id: 't2',
          title: 'Cooking Oil & Provisions',
          billAmount: 6500,
          paidAmount: 2500,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    CustomerAccount(
      id: 'c2',
      name: 'K. Senthilkumar',
      phone: '+94 71 889 3321',
      transactions: [
        BillTransaction(
          id: 't3',
          title: 'Hardware & Electrical Supplies',
          billAmount: 14200,
          paidAmount: 9200,
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    ),
    CustomerAccount(
      id: 'c3',
      name: 'Fathima Nusrath',
      phone: '+94 76 554 1902',
      transactions: [
        BillTransaction(
          id: 't4',
          title: 'Monthly Grocery Account',
          billAmount: 9800,
          paidAmount: 9800,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
  ];

  Color get _primaryColor {
    switch (_accent) {
      case AppAccent.emerald:
        return _isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0F5132);
      case AppAccent.navy:
        return _isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A);
      case AppAccent.slate:
        return _isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFF0F172A);
    }
  }

  ThemeData _buildTheme() {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;
    final bg = _isDarkMode ? const Color(0xFF111315) : const Color(0xFFF6F7F9);
    final surface = _isDarkMode ? const Color(0xFF1A1D21) : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: brightness,
        primary: _primaryColor,
        surface: surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _isDarkMode ? Colors.white : const Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KadanBook',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: WelcomeScreen(
        primaryColor: _primaryColor,
        onGetStarted: (navContext) {
          Navigator.of(navContext).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainShellScreen(
                customers: _customers,
                isDarkMode: _isDarkMode,
                accent: _accent,
                shopName: _shopName,
                ownerName: _ownerName,
                avatarIndex: _avatarIndex,
                onThemeChanged: (dark) => setState(() => _isDarkMode = dark),
                onAccentChanged: (acc) => setState(() => _accent = acc),
                onProfileUpdated: (shop, owner, avatar) => setState(() {
                  _shopName = shop;
                  _ownerName = owner;
                  _avatarIndex = avatar;
                }),
                onDataChanged: () => setState(() {}),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 1. WELCOME SCREEN ---
class WelcomeScreen extends StatefulWidget {
  final Color primaryColor;
  final void Function(BuildContext) onGetStarted;

  const WelcomeScreen({
    super.key,
    required this.primaryColor,
    required this.onGetStarted,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _CoinTrailPainter(
                  progress: _controller.value,
                  isDark: isDark,
                ),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                            Positioned(
                              right: 14,
                              top: 14,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Rs',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'KadanBook',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          color:
                              isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Simple daily credit ledger for shopkeepers.\nTrack total bills, cash received, and send instant PDF bills or SMS reminders.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _featureRow(
                        Icons.calculate_outlined,
                        'Clear Bill, Paid & Balance tracking',
                        isDark,
                      ),
                      const SizedBox(height: 14),
                      _featureRow(
                        Icons.picture_as_pdf_outlined,
                        'One-tap printable PDF statement',
                        isDark,
                      ),
                      const SizedBox(height: 14),
                      _featureRow(
                        Icons.sms_outlined,
                        'Direct customer SMS payment alerts',
                        isDark,
                      ),
                      const Spacer(flex: 3),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () => widget.onGetStarted(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.primaryColor.withAlpha(28),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: widget.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoinTrailPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _CoinTrailPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final coinPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF59E0B).withAlpha(isDark ? 36 : 42);

    final seeds = <List<double>>[
      [0.15, 0.18, 16.0, 1.0],
      [0.82, 0.12, 22.0, 0.7],
      [0.75, 0.35, 14.0, 1.3],
      [0.88, 0.58, 19.0, 0.9],
      [0.20, 0.65, 13.0, 1.1],
    ];

    for (final s in seeds) {
      final dx = s[0] * size.width +
          math.sin((progress * 2 * math.pi) * s[3]) * 18;
      final dy = ((s[1] - progress * 0.25) % 1.0) * size.height;
      canvas.drawCircle(Offset(dx, dy), s[2], coinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoinTrailPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}

// --- 2. MAIN SHELL ---
class MainShellScreen extends StatefulWidget {
  final List<CustomerAccount> customers;
  final bool isDarkMode;
  final AppAccent accent;
  final String shopName;
  final String ownerName;
  final int avatarIndex;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppAccent> onAccentChanged;
  final void Function(String, String, int) onProfileUpdated;
  final VoidCallback onDataChanged;

  const MainShellScreen({
    super.key,
    required this.customers,
    required this.isDarkMode,
    required this.accent,
    required this.shopName,
    required this.ownerName,
    required this.avatarIndex,
    required this.onThemeChanged,
    required this.onAccentChanged,
    required this.onProfileUpdated,
    required this.onDataChanged,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    final page = _tabIndex == 0
        ? LedgerDashboardScreen(
            customers: widget.customers,
            shopName: widget.shopName,
            ownerName: widget.ownerName,
            avatarIndex: widget.avatarIndex,
            onDataChanged: widget.onDataChanged,
          )
        : SettingsScreen(
            isDarkMode: widget.isDarkMode,
            accent: widget.accent,
            shopName: widget.shopName,
            ownerName: widget.ownerName,
            avatarIndex: widget.avatarIndex,
            onThemeChanged: widget.onThemeChanged,
            onAccentChanged: widget.onAccentChanged,
            onProfileUpdated: widget.onProfileUpdated,
          );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: Text('Ledger'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: page),
          ],
        ),
      );
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Ledger',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// --- 3. LEDGER DASHBOARD ---
class LedgerDashboardScreen extends StatefulWidget {
  final List<CustomerAccount> customers;
  final String shopName;
  final String ownerName;
  final int avatarIndex;
  final VoidCallback onDataChanged;

  const LedgerDashboardScreen({
    super.key,
    required this.customers,
    required this.shopName,
    required this.ownerName,
    required this.avatarIndex,
    required this.onDataChanged,
  });

  @override
  State<LedgerDashboardScreen> createState() => _LedgerDashboardScreenState();
}

class _LedgerDashboardScreenState extends State<LedgerDashboardScreen> {
  String _searchQuery = '';

  double get _grandBill =>
      widget.customers.fold(0, (s, c) => s + c.totalBill);
  double get _grandPaid =>
      widget.customers.fold(0, (s, c) => s + c.totalPaid);
  double get _grandBalance =>
      widget.customers.fold(0, (s, c) => s + c.balanceDue);

  String _formatRs(double val) {
    return 'Rs. ${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = widget.customers
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shopName),
            Text(
              'Owner: ${widget.ownerName}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: primary.withAlpha(34),
              child: Icon(
                _avatarIcons[widget.avatarIndex.clamp(0, _avatarIcons.length - 1)],
                color: primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE TO COLLECT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white.withAlpha(210),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatRs(_grandBalance),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(42),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _summaryMetric(
                              'Total Billed',
                              _formatRs(_grandBill),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: Colors.white.withAlpha(55),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: _summaryMetric(
                                'Cash Received',
                                _formatRs(_grandPaid),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search customer name or phone...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1D21) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Customer Accounts (${filtered.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...filtered.map((customer) {
                final hasDue = customer.balanceDue > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CustomerDetailScreen(
                              customer: customer,
                              shopName: widget.shopName,
                              onUpdated: () {
                                setState(() {});
                                widget.onDataChanged();
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: primary.withAlpha(30),
                                  child: Text(
                                    customer.initials,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        customer.phone,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hasDue
                                          ? _formatRs(customer.balanceDue)
                                          : 'Settled',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: hasDue
                                            ? const Color(0xFFD97706)
                                            : const Color(0xFF10B981),
                                      ),
                                    ),
                                    Text(
                                      hasDue ? 'Balance Due' : 'All Paid',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bill: ${_formatRs(customer.totalBill)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Paid: ${_formatRs(customer.totalPaid)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddBillSheet(context),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Bill Entry',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withAlpha(195),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _openAddBillSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+94 ');
    final itemCtrl = TextEditingController();
    final billCtrl = TextEditingController();
    final paidCtrl = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bill = double.tryParse(billCtrl.text) ?? 0;
            final paid = double.tryParse(paidCtrl.text) ?? 0;
            final due = (bill - paid).clamp(0, double.infinity);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Credit Bill Entry',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number (for SMS)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: itemCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bill Note / Items',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: billCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Total Bill (Rs.)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: paidCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Cash Paid (Rs.)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remaining Balance Due:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Rs. ${due.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty || bill <= 0) return;
                          final existingIndex = widget.customers.indexWhere(
                            (c) =>
                                c.name.toLowerCase() ==
                                nameCtrl.text.trim().toLowerCase(),
                          );
                          final tx = BillTransaction(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: itemCtrl.text.trim().isEmpty
                                ? 'General Bill'
                                : itemCtrl.text.trim(),
                            billAmount: bill,
                            paidAmount: paid,
                            date: DateTime.now(),
                          );

                          setState(() {
                            if (existingIndex >= 0) {
                              widget.customers[existingIndex].transactions
                                  .insert(0, tx);
                            } else {
                              widget.customers.insert(
                                0,
                                CustomerAccount(
                                  id: DateTime.now().toString(),
                                  name: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  transactions: [tx],
                                ),
                              );
                            }
                          });
                          widget.onDataChanged();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Save Entry',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- 4. CUSTOMER DETAIL ---
class CustomerDetailScreen extends StatefulWidget {
  final CustomerAccount customer;
  final String shopName;
  final VoidCallback onUpdated;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.shopName,
    required this.onUpdated,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  String _rs(double v) => 'Rs. ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final c = widget.customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.name),
        actions: [
          IconButton(
            tooltip: 'Record Cash Payment',
            icon: const Icon(Icons.payments_outlined),
            onPressed: () => _recordPaymentDialog(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statCol('Total Billed', _rs(c.totalBill), null),
                          _statCol(
                            'Cash Paid',
                            _rs(c.totalPaid),
                            const Color(0xFF10B981),
                          ),
                          _statCol(
                            'Balance Due',
                            _rs(c.balanceDue),
                            const Color(0xFFD97706),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showPdfPreview(context),
                              icon: const Icon(Icons.picture_as_pdf_outlined,
                                  size: 18),
                              label: const Text('PDF Bill'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _showSmsPreview(context),
                              icon: const Icon(Icons.sms_outlined, size: 18),
                              label: const Text('Send SMS'),
                              style: FilledButton.styleFrom(
                                backgroundColor: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Transaction History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...c.transactions.map((tx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        tx.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Bill: ${_rs(tx.billAmount)}  •  Paid: ${_rs(tx.paidAmount)}',
                      ),
                      trailing: Text(
                        tx.balance > 0 ? 'Due ${_rs(tx.balance)}' : 'Paid',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: tx.balance > 0
                              ? const Color(0xFFD97706)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCol(String label, String val, Color? color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  void _recordPaymentDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Cash Received'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount Received (Rs.)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amt = double.tryParse(ctrl.text) ?? 0;
              if (amt > 0) {
                setState(() {
                  widget.customer.transactions.insert(
                    0,
                    BillTransaction(
                      id: DateTime.now().toString(),
                      title: 'Cash Payment Received',
                      billAmount: 0,
                      paidAmount: amt,
                      date: DateTime.now(),
                    ),
                  );
                });
                widget.onUpdated();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPdfPreview(BuildContext context) {
    final c = widget.customer;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('PDF Statement Ready'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shopName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const Divider(),
            Text('Customer: ${c.name}'),
            Text('Phone: ${c.phone}'),
            const SizedBox(height: 8),
            Text('Total Billed: ${_rs(c.totalBill)}'),
            Text('Total Paid:   ${_rs(c.totalPaid)}'),
            Text(
              'Balance Due:  ${_rs(c.balanceDue)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF Bill prepared for ${c.name}')),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSmsPreview(BuildContext context) {
    final c = widget.customer;
    final msg =
        'Hello ${c.name}, your account summary at ${widget.shopName}: Total Bill ${_rs(c.totalBill)}, Paid ${_rs(c.totalPaid)}, Balance Due ${_rs(c.balanceDue)}. Thank you!';
    final ctrl = TextEditingController(text: msg);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Send SMS to ${c.phone}'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SMS Reminder ready for ${c.name} (${c.phone})'),
                ),
              );
            },
            child: const Text('Send SMS'),
          ),
        ],
      ),
    );
  }
}

// --- 5. SETTINGS & PROFILE ---
class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final AppAccent accent;
  final String shopName;
  final String ownerName;
  final int avatarIndex;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppAccent> onAccentChanged;
  final void Function(String, String, int) onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.accent,
    required this.shopName,
    required this.ownerName,
    required this.avatarIndex,
    required this.onThemeChanged,
    required this.onAccentChanged,
    required this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shopCtrl;
  late TextEditingController _ownerCtrl;
  late int _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _shopCtrl = TextEditingController(text: widget.shopName);
    _ownerCtrl = TextEditingController(text: widget.ownerName);
    _selectedAvatar = widget.avatarIndex;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shop & Owner Profile',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: List.generate(_avatarIcons.length, (i) {
                          final selected = _selectedAvatar == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () => setState(() => _selectedAvatar = i),
                              borderRadius: BorderRadius.circular(30),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    selected ? primary : primary.withAlpha(28),
                                child: Icon(
                                  _avatarIcons[i],
                                  color: selected ? Colors.white : primary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _shopCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Shop Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ownerCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Owner Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            widget.onProfileUpdated(
                              _shopCtrl.text.trim(),
                              _ownerCtrl.text.trim(),
                              _selectedAvatar,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated')),
                            );
                          },
                          child: const Text('Save Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appearance',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dark Mode'),
                        subtitle:
                            const Text('Switch between light and dark theme'),
                        value: widget.isDarkMode,
                        onChanged: widget.onThemeChanged,
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Accent Color Theme',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: [
                          ChoiceChip(
                            label: const Text('Forest Emerald'),
                            selected: widget.accent == AppAccent.emerald,
                            onSelected: (_) =>
                                widget.onAccentChanged(AppAccent.emerald),
                          ),
                          ChoiceChip(
                            label: const Text('Classic Navy'),
                            selected: widget.accent == AppAccent.navy,
                            onSelected: (_) =>
                                widget.onAccentChanged(AppAccent.navy),
                          ),
                          ChoiceChip(
                            label: const Text('Midnight Slate'),
                            selected: widget.accent == AppAccent.slate,
                            onSelected: (_) =>
                                widget.onAccentChanged(AppAccent.slate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}