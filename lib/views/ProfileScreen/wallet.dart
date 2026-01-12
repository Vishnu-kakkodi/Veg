import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/utils/responsive.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const String _apiHost = "https://api.vegiffyy.com";

  User? _user;
  bool _isLoading = true;
  String? _error;

  double _walletBalance = 0.0;
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initWallet();
  }

  Future<void> _initWallet() async {
    try {
      // 1️⃣ Load user from local storage
      final userData = UserPreferences.getUser();
      if (userData == null) {
        setState(() {
          _error = "User not logged in";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _user = userData;
      });

      // 2️⃣ Fetch wallet data from API
      await _fetchWalletData(userData.userId.toString());
    } catch (e, st) {
      debugPrint("Wallet init error: $e\n$st");
      setState(() {
        _error = "Something went wrong: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWalletData(String userId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse("$_apiHost/api/userwallet/$userId");
      debugPrint("Wallet API: $url");

      final response = await http.get(url);
      debugPrint("Wallet response: ${response.statusCode} -> ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ⚠️ Flexible parsing – adjust to match your exact API
        final wallet = data['wallet'] ?? data;

        // Balance: try different possible keys
        final balanceRaw =
            wallet['walletBalance'] ?? wallet['balance'] ?? 0;

        final balance = _toDouble(balanceRaw);

        // Transactions
        final List<dynamic> txList =
            (wallet['transactions'] ?? wallet['history'] ?? []) as List<dynamic>;

        final transactions = txList.map((e) {
          final map = e as Map<String, dynamic>;

          final amountRaw = map['amount'] ?? map['value'] ?? 0;
          final amount = _toDouble(amountRaw);

          // Type: use explicit type if exists, otherwise from sign of amount
          final typeString =
              (map['type'] ?? map['txnType'] ?? '').toString().toLowerCase();

          TransactionType type;
          if (typeString.contains('credit')) {
            type = TransactionType.credit;
          } else if (typeString.contains('debit')) {
            type = TransactionType.debit;
          } else {
            type = amount >= 0 ? TransactionType.credit : TransactionType.debit;
          }

          final createdAt =
              map['createdAt'] ?? map['date'] ?? map['time'] ?? '';

          return WalletTransaction(
            title: map['title'] ??
                map['narration'] ??
                map['description'] ??
                'Transaction',
            subtitle: map['subtitle'] ??
                map['details'] ??
                map['description'] ??
                '',
            amount: amount,
            date: _formatDate(createdAt),
            type: type,
          );
        }).toList();

        setState(() {
          _walletBalance = balance;
          _transactions = transactions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load wallet (${response.statusCode})";
          _isLoading = false;
        });
      }
    } on SocketException catch (e) {
      debugPrint("Wallet network error: $e");
      setState(() {
        _error = "Network error. Please check your connection.";
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint("Wallet fetch error: $e\n$st");
      setState(() {
        _error = "Error loading wallet: $e";
        _isLoading = false;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      if (raw is String) {
        // Try parse ISO date
        final date = DateTime.parse(raw).toLocal();
        return DateFormat('MMM d, yyyy • h:mm a').format(date);
      }
      if (raw is int) {
        // maybe milliseconds
        final date = DateTime.fromMillisecondsSinceEpoch(raw).toLocal();
        return DateFormat('MMM d, yyyy • h:mm a').format(date);
      }
    } catch (_) {}
    // Fallback: just return the raw string
    return raw.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    final double horizontalPadding = isMobile ? 16 : 24;
    final double topPadding = isMobile ? 16 : 24;
    final double maxWidth =
        isDesktop ? 900 : (isTablet ? 720 : double.infinity);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "My Wallet",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                20,
              ),
              child: _buildBody(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      children: [
        // Wallet Balance Card (from API)
        _buildWalletCard(
          theme: theme,
          walletBalance: _walletBalance,
          isMobile: isMobile,
        ),

        const SizedBox(height: 24),

        // Header: Transactions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Transaction History",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
            ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // If no transactions
        if (_transactions.isEmpty)
Expanded(
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🎨 Icon container
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.15),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 24),

        // 🧾 Title
        Text(
          "No Transactions Yet",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

      ],
    ),
  ),
)

        else
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _transactions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.4),
                ),
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  return _buildTransactionTile(
                    tx: tx,
                    theme: theme,
                    isDesktop: isDesktop,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWalletCard({
    required ThemeData theme,
    required double walletBalance,
    required bool isMobile,
  }) {
    final double verticalPadding = isMobile ? 24 : 28;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(verticalPadding),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Wallet Balance",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Available to use",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${walletBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      "INR",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Instant payments for your rides",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile({
    required WalletTransaction tx,
    required ThemeData theme,
    required bool isDesktop,
  }) {
    final isCredit = tx.type == TransactionType.credit;
    final amountColor = isCredit ? Colors.green : Colors.red;

    final double titleSize = isDesktop ? 16 : 15;
    final double amountSize = isDesktop ? 16 : 15;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (isCredit ? Colors.green : Colors.red).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Title + Subtitle + Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: titleSize,
                  ),
                ),
                if (tx.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tx.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
                if (tx.date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tx.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Amount + Type Chip
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isCredit ? '+' : '-'}₹${tx.amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: amountSize,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCredit ? "Credit" : "Debit",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum TransactionType { credit, debit }

class WalletTransaction {
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final TransactionType type;

  WalletTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}
