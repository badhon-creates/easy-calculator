import 'package:flutter/material.dart';
import 'package:easy_calculator/core/theme/app_theme.dart';
import 'package:easy_calculator/features/currency_converter/domain/models/currency.dart';

/// Searchable modal bottom sheet for selecting a currency.
class CurrencySelectionModal extends StatefulWidget {
  const CurrencySelectionModal({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.title,
  });

  final List<Currency> currencies;
  final Currency selectedCurrency;
  final String title;

  static Future<Currency?> show(
    BuildContext context, {
    required List<Currency> currencies,
    required Currency selectedCurrency,
    required String title,
  }) {
    return showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelectionModal(
        currencies: currencies,
        selectedCurrency: selectedCurrency,
        title: title,
      ),
    );
  }

  @override
  State<CurrencySelectionModal> createState() => _CurrencySelectionModalState();
}

class _CurrencySelectionModalState extends State<CurrencySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<Currency> _filteredCurrencies;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = widget.currencies;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = widget.currencies;
      } else {
        _filteredCurrencies = widget.currencies.where((c) {
          final matchesCode = c.code.toLowerCase().contains(query);
          final matchesName = c.name.toLowerCase().contains(query);
          final matchesSymbol = c.symbol.toLowerCase().contains(query);
          return matchesCode || matchesName || matchesSymbol;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.calcColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.disabledColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search currency (e.g. USD, BDT, Euro)...',
                  hintStyle: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textPrimary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: colors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2E2B2B)
                      : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: isDark
                        ? BorderSide.none
                        : BorderSide(
                            color: colors.numberButtonBorder,
                            width: 1,
                          ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Currency List
            Expanded(
              child: _filteredCurrencies.isEmpty
                  ? Center(
                      child: Text(
                        'No currencies found',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        final isSelected =
                            currency.code == widget.selectedCurrency.code;

                        return InkWell(
                          onTap: () => Navigator.of(context).pop(currency),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.operatorButton.withValues(
                                      alpha: 0.12,
                                    )
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                // Flag / avatar
                                Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF3D3A3A)
                                        : const Color(0xFFE2E8F0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    currency.flag.isNotEmpty
                                        ? currency.flag
                                        : '🌐',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Code and Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            currency.code,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          if (currency.symbol.isNotEmpty &&
                                              currency.symbol !=
                                                  currency.code) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${currency.symbol})',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currency.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Checkmark if selected
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: colors.operatorButton,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
