import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../currency/currency_scope.dart';
import '../models/portfolio_item_summary.dart';
import '../models/stock_quote.dart';
import '../services/portfolio_service.dart';
import '../services/stock_quote_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_section_card.dart';

class PortfolioEntryScreen extends StatefulWidget {
  const PortfolioEntryScreen({
    super.key,
    required this.stockId,
    required this.company,
    required this.ticker,
    required this.exchange,
    required this.price,
    this.initialItem,
  });

  final int stockId;
  final String company;
  final String ticker;
  final String exchange;
  final String price;
  final PortfolioItemSummary? initialItem;

  bool get isEditMode => initialItem != null;

  @override
  State<PortfolioEntryScreen> createState() => _PortfolioEntryScreenState();
}

class _PortfolioEntryScreenState extends State<PortfolioEntryScreen> {
  final PortfolioService _portfolioService = const PortfolioService();
  final StockQuoteService _stockQuoteService = const StockQuoteService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  late final TextEditingController _dailyInvestAmountController;
  late final TextEditingController _holdingQuantityController;
  late final TextEditingController _investmentStartDateController;
  late final TextEditingController _memoController;

  bool _isSaving = false;
  bool _isLoadingPrice = false;
  StockQuote? _quote;
  String? _priceError;
  DateTime? _selectedInvestmentStartDate;

  @override
  void initState() {
    super.initState();
    final initialItem = widget.initialItem;

    _dailyInvestAmountController = TextEditingController(
      text: initialItem?.dailyInvestAmount ?? '',
    );
    _holdingQuantityController = TextEditingController(
      text: initialItem?.holdingQuantity ?? '',
    );
    _investmentStartDateController = TextEditingController(
      text: initialItem?.investmentStartDate ?? '',
    );
    _memoController = TextEditingController(
      text: initialItem?.memo ?? '',
    );

    if (initialItem != null && initialItem.investmentStartDate.isNotEmpty) {
      _selectedInvestmentStartDate = DateTime.tryParse(initialItem.investmentStartDate);
    }

    _loadCurrentPrice();
  }

  @override
  void dispose() {
    _dailyInvestAmountController.dispose();
    _holdingQuantityController.dispose();
    _investmentStartDateController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyController = CurrencyScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.isEditMode ? '종목 수정' : '종목 등록'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              widget.isEditMode
                  ? '등록된 종목의 매일 모으기 금액, 보유 수량, 투자 시작일, 메모를 수정합니다.'
                  : '검색에서 선택한 종목 정보를 바탕으로 매일 모으기 설정을 등록합니다.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              child: ListenableBuilder(
                listenable: currencyController,
                builder: (context, _) {
                  return Column(
                    children: [
                      _ReadOnlyField(label: '종목명', value: widget.company),
                      const SizedBox(height: 12),
                      _ReadOnlyField(label: '티커', value: widget.ticker),
                      const SizedBox(height: 12),
                      _ReadOnlyField(label: '거래소', value: widget.exchange),
                      const SizedBox(height: 12),
                      _ReadOnlyField(
                        label: '현재가',
                        value: _buildCurrentPriceLabel(currencyController.usdToKrwRate),
                        helperText: _priceError,
                        isLoading: _isLoadingPrice,
                      ),
                      const SizedBox(height: 12),
                      _EntryField(
                        controller: _dailyInvestAmountController,
                        label: '매일 모으기 금액 (USD)',
                        hint: '예: 10.50',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';

                          if (trimmed.isEmpty) {
                            return '매일 모으기 금액을 입력해 주세요.';
                          }

                          final amount = double.tryParse(trimmed);
                          if (amount == null || amount <= 0) {
                            return '0보다 큰 달러 금액을 입력해 주세요.';
                          }

                          if (amount > 100) {
                            return '매일 모으기 금액은 최대 100달러까지만 입력할 수 있습니다.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _EntryField(
                        controller: _holdingQuantityController,
                        label: '보유 수량',
                        hint: '예: 2.38',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';

                          if (trimmed.isEmpty) {
                            return null;
                          }

                          final quantity = double.tryParse(trimmed);
                          if (quantity == null || quantity < 0) {
                            return '0 이상의 숫자를 입력해 주세요.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _DatePickerField(
                        controller: _investmentStartDateController,
                        label: '투자 시작일',
                        hint: '캘린더에서 날짜 선택',
                        onTap: _pickInvestmentStartDate,
                      ),
                      const SizedBox(height: 12),
                      _EntryField(
                        controller: _memoController,
                        label: '메모',
                        hint: '예: AI 반도체 장기 적립 중',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _savePortfolioItem,
                          child: Text(
                            _isSaving
                                ? '저장 중...'
                                : widget.isEditMode
                                    ? '수정 저장'
                                    : '포트폴리오에 저장',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCurrentPrice() async {
    setState(() {
      _isLoadingPrice = true;
      _priceError = null;
    });

    try {
      final quote = await _stockQuoteService.fetchQuote(widget.stockId);

      if (!mounted) {
        return;
      }

      setState(() {
        _quote = quote;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _priceError = '현재 가격을 불러오지 못했어요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPrice = false;
        });
      }
    }
  }

  Future<void> _pickInvestmentStartDate() async {
    final now = DateTime.now();
    final initialDate = _selectedInvestmentStartDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedInvestmentStartDate = picked;
      _investmentStartDateController.text = _dateFormat.format(picked);
    });
  }

  String _buildCurrentPriceLabel(double? usdToKrwRate) {
    final quote = _quote;
    if (quote == null) {
      return widget.price.trim().isEmpty ? '현재 가격 불러오는 중...' : widget.price;
    }

    final basePrice = CurrencyFormatter.formatDualPrice(
      usdAmount: quote.currentPrice,
      usdToKrwRate: usdToKrwRate,
    );
    final changePrefix = quote.change > 0 ? '+' : '';
    final percentPrefix = quote.percentChange > 0 ? '+' : '';

    return '$basePrice\n'
        '변동 $changePrefix${quote.change.toStringAsFixed(2)} '
        '($percentPrefix${quote.percentChange.toStringAsFixed(2)}%)';
  }

  Future<void> _savePortfolioItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _portfolioService.savePortfolioItem(
        stockId: widget.stockId,
        dailyInvestAmount: _dailyInvestAmountController.text.trim(),
        holdingQuantity: _holdingQuantityController.text.trim(),
        investmentStartDate: _investmentStartDateController.text.trim(),
        memo: _memoController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? '${widget.company} 설정을 저장했어요. 최신 지표와 뉴스도 다시 확인하고 있어요.'
                : '${widget.company} 종목을 담았어요. 가격 흐름과 핵심 지표를 바로 준비하고 있어요.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (exception) {
      if (!mounted) {
        return;
      }

      final errorMessage = exception.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage.isEmpty
                ? '포트폴리오 저장 중 문제가 생겼습니다. 다시 시도해 주세요.'
                : errorMessage,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.helperText,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final String? helperText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: MaeMojiColors.paperAccent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: MaeMojiColors.stroke),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MaeMojiColors.ink,
                    height: 1.45,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 12,
              color: MaeMojiColors.stop,
            ),
          ),
        ],
      ],
    );
  }
}

class _EntryField extends StatelessWidget {
  const _EntryField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: MaeMojiColors.paperSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MaeMojiColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: const Icon(Icons.calendar_month_rounded),
            filled: true,
            fillColor: MaeMojiColors.paperSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
          ),
        ),
      ],
    );
  }
}
