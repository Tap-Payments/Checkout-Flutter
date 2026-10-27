// A form with every input of the Tap web demo, grouped like its steps (SDK / User / Card / Order /
// Transaction). Every change is saved immediately; "Show configuration JSON" displays exactly what
// Start Checkout will pass to the plugin. Same rows as the Settings screens of the native example apps.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'checkout_settings.dart';
import 'countries.dart';
import 'home_screen.dart' show formatAmount;
import 'json_screen.dart';
import 'local_keys.dart';
import 'widgets.dart';

/// A value offered by a choice row: [value] goes into the configuration, [title] is shown to the user.
class Option {
  const Option(this.value, [String? title]) : title = title ?? value;

  final String value;
  final String title;
}

class Options {
  static List<Option> _plain(List<String> values) => values.map(Option.new).toList();

  static const _currencyCodes = ['KWD', 'BHD', 'SAR', 'AED', 'OMR', 'EGP', 'GBP', 'USD', 'EUR'];
  static final currencies = _plain(_currencyCodes);
  static final supportedCurrencies = _plain(['ALL', 'AUTO', ..._currencyCodes]);
  static final paymentTypes = _plain(['ALL', 'WEB', 'CARD', 'DEVICE']);
  static final paymentMethods = _plain([
    'ALL', 'AMERICAN_EXPRESS', 'APPLE_PAY', 'BENEFIT', 'BENEFITPAY', 'CAREEMPAY', 'FAWRY', 'GOOGLE_PAY', 'KNET', //
    'MADA', 'MASTERCARD', 'MEEZA', 'OMANNET', 'PAYPAL', 'POST_PAY', 'NAPS', 'STC_PAY', 'TABBY', 'VISA',
  ]);

  /// "dynamic" makes the Android SDK use the device language; "auto" leaves the key out.
  static const languages = [Option('auto'), Option('en'), Option('ar'), Option('dynamic', 'dynamic (Android)')];
  static final regions = _plain(['LOCAL', 'REGIONAL', 'GLOBAL']);
  static final supportedPaymentTypes = _plain([
    'CARD', 'DEVICE_WALLET', 'EXPRESS_CHECKOUT_WALLET', 'PASS_THRU_WALLET', 'STORED_VALUE_WALLET', 'CASH_WALLET', 'BNPL', //
  ]);
  static final schemes = _plain(['BENEFIT', 'VISA', 'AMEX', 'MASTERCARD', 'MADA', 'MEEZA', 'OMANNET']);

  /// ISO 3166-1 alpha-2 codes, titled with the country name.
  static final countryOptions = [for (final (code, name) in countries) Option(code, '$code - $name')];

  static final fundingSources = _plain(['all', 'credit', 'debit']);
  static final saveCardOptions = _plain(['all', 'merchant', 'tap', 'none']);
  static const discountTypes = [Option('F', 'Fixed amount'), Option('P', 'Percentage')];
  static const modes = [Option('charge', 'Charge'), Option('authorize', 'Authorize')];

  /// "dynamic" makes the Android SDK follow the device's light/dark mode; "auto" leaves the key out.
  static const themes = [
    Option('light'), Option('dark'), Option('light_mono'), Option('dark_colored'), //
    Option('dynamic', 'dynamic (Android)'), Option('auto'),
  ];
  static final checkoutModes = _plain(['popup', 'page']);
  static final authorizeTypes = _plain(['CAPTURE', 'VOID']);
  static final agreementTypes = _plain(['SCHEDULED', 'UNSCHEDULED']);
  static final amountVariabilities = _plain(['FIXED', 'VARIABLE']);
  static final numbersOfPayments = _plain(['Defined', 'Undefined']);
  static const airline = [Option('', 'Not set (sent empty)'), Option('yes', 'Yes'), Option('no', 'No')];
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CheckoutSettings? _settings;
  List<SavedKey> _savedKeys = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await CheckoutSettings.load();
    final savedKeys = await LocalKeys.all();
    if (mounted) {
      setState(() {
        _settings = settings;
        _savedKeys = savedKeys;
      });
    }
  }

  /// Applies a change, saves it and redraws the form (rows can show, hide or change the total).
  void _change(void Function(CheckoutSettings settings) update) {
    final settings = _settings!;
    setState(() => update(settings));
    settings.save();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  ..._sdkSection(settings),
                  ..._userSection(settings),
                  ..._cardSection(settings),
                  ..._orderSection(settings),
                  ..._transactionSection(settings),
                  ..._section('Tools', [
                    _button('Show configuration JSON', () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ConfigurationJsonScreen(configuration: settings.makeConfiguration()),
                      ));
                    }),
                    _button('Reset to defaults', _confirmReset, destructive: true),
                  ]),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmReset() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to defaults?'),
        content: const Text('All settings go back to the web demo defaults.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );
    if (reset != true) return;
    await CheckoutSettings.reset();
    await _load();
  }

  // Sections

  List<Widget> _sdkSection(CheckoutSettings s) {
    final rows = <Widget>[];
    // Saved Keys appears only when assets/keys.local.json has keys (debug builds).
    if (_savedKeys.isNotEmpty) {
      final current = _savedKeys.indexWhere((k) => k.publicKey == s.publicKey && k.merchantId == s.merchantId);
      rows.add(_choice(
        'Saved Keys',
        [const Option('', 'Custom'), for (final (i, key) in _savedKeys.indexed) Option('$i', key.name)],
        current >= 0 ? '$current' : '',
        (picked) {
          final index = int.tryParse(picked);
          if (index == null) return;
          s.publicKey = _savedKeys[index].publicKey;
          s.merchantId = _savedKeys[index].merchantId;
        },
      ));
    }
    rows.addAll([
      _text('Public Key', s.publicKey, (v) => s.publicKey = v),
      _text('Merchant Id', s.merchantId, (v) => s.merchantId = v),
      _multi('Supported Currencies', Options.supportedCurrencies, s.supportedCurrencies, (v) => s.supportedCurrencies = v),
      _choice('Payment Type', Options.paymentTypes, s.paymentType, (v) => s.paymentType = v),
      _multi('Supported Payment Methods', Options.paymentMethods, s.supportedPaymentMethods,
          (v) => s.supportedPaymentMethods = v),
      _choice('Selected Currency', Options.currencies, s.selectedCurrency, (v) => s.selectedCurrency = v),
      _choice('Language', Options.languages, s.language, (v) => s.language = v),
      _multi('Supported Regions', Options.regions, s.supportedRegions, (v) => s.supportedRegions = v),
      _multi('Supported Countries', Options.countryOptions, s.supportedCountries, (v) => s.supportedCountries = v),
      _multi('Supported Payment Types', Options.supportedPaymentTypes, s.supportedPaymentTypes,
          (v) => s.supportedPaymentTypes = v),
      _multi('Supported Schemes', Options.schemes, s.supportedSchemes, (v) => s.supportedSchemes = v),
      _toggle('Apple Pay Available On Client', s.isApplePayAvailableOnClient, (v) => s.isApplePayAvailableOnClient = v),
    ]);
    return _section(
      'SDK Configuration',
      rows,
      footer: 'Defaults to the key in keys.dart. Under each public key there can be several merchant ids; '
          'use the one that belongs to it.',
    );
  }

  List<Widget> _userSection(CheckoutSettings s) => _section('User Configuration', [
        _text('Customer ID', s.customerId, (v) => s.customerId = v),
        _text('First Name', s.firstName, (v) => s.firstName = v),
        _text('Last Name', s.lastName, (v) => s.lastName = v),
        _text('Customer E-mail', s.email, (v) => s.email = v, keyboard: TextInputType.emailAddress),
        _text('Customer Country Code', s.countryCode, (v) => s.countryCode = v, keyboard: TextInputType.number),
        _text('Customer phone number', s.phoneNumber, (v) => s.phoneNumber = v, keyboard: TextInputType.phone),
      ]);

  List<Widget> _cardSection(CheckoutSettings s) => _section('Card Configuration', [
        _toggle('Show Brands', s.showBrands, (v) => s.showBrands = v),
        _toggle('Show Loading State', s.showLoadingState, (v) => s.showLoadingState = v),
        _toggle('Collect Card Holder Name', s.collectHolderName, (v) => s.collectHolderName = v),
        _text('PreLoad CardName', s.preLoadCardName, (v) => s.preLoadCardName = v),
        _toggle('CardName Editable', s.cardNameEditable, (v) => s.cardNameEditable = v),
        _choice('Card Funding Source', Options.fundingSources, s.cardFundingSource, (v) => s.cardFundingSource = v),
        _choice('Save Card Options', Options.saveCardOptions, s.saveCardOption, (v) => s.saveCardOption = v),
        _toggle('Force LTR', s.forceLtr, (v) => s.forceLtr = v),
        _toggle('Card Scanner', s.cardScanner, (v) => s.cardScanner = v),
        _toggle('Card NFC (Android only)', s.cardNFC, (v) => s.cardNFC = v),
      ]);

  List<Widget> _orderSection(CheckoutSettings s) => _section(
        'Order Configuration',
        [
          _text('Order ID', s.orderId, (v) => s.orderId = v),
          _choice('Order discount type', Options.discountTypes, s.discountType, (v) => s.discountType = v),
          _decimal('Order discount value', s.discountValue, (v) => s.discountValue = v),
          for (final (index, item) in s.items.indexed) ...[
            _text('Order ${index + 1} Name', item.name, (v) => item.name = v),
            _text('Order ${index + 1} Description', item.description, (v) => item.description = v),
            _integer('Order ${index + 1} Quantity', item.quantity, (v) => item.quantity = v),
            _decimal('Order ${index + 1} Amount', item.amount, (v) => item.amount = v),
            if (s.items.length > 1)
              _button('Remove item ${index + 1}', () => _change((s) => s.items.removeAt(index)), destructive: true),
          ],
          _button('Add New Item', () => _change((s) => s.items.add(OrderItem()))),
          _info('Total to pay', '${formatAmount(s.totalAmount)} ${s.selectedCurrency}'),
        ],
        footer: 'Total = items minus the discount (1 if the result is 0 or less).',
      );

  List<Widget> _transactionSection(CheckoutSettings s) => _section('Transaction Configuration', [
        _choice('Transaction Mode', Options.modes, s.mode, (v) => s.mode = v),
        if (s.mode == 'authorize') ...[
          _choice('Authorize Type', Options.authorizeTypes, s.authorizeType, (v) => s.authorizeType = v),
          _integer('Authorize Time (hours)', s.authorizeTime, (v) => s.authorizeTime = v),
        ],
        _choice('Theme', Options.themes, s.theme, (v) => s.theme = v),
        _choice('Checkout Mode', Options.checkoutModes, s.checkoutMode, (v) => s.checkoutMode = v),
        _toggle('3D Secure', s.threeDSecure, (v) => s.threeDSecure = v),
        _toggle('Save Card', s.saveCard, (v) => s.saveCard = v),
        _text('Redirect URL', s.redirectUrl, (v) => s.redirectUrl = v, keyboard: TextInputType.url),
        _text('Hashstring', s.hashString, (v) => s.hashString = v),
        _toggle('Agreed payment', s.agreedPayment, (v) => s.agreedPayment = v),
        if (s.agreedPayment) ...[
          _choice('Agreement Type', Options.agreementTypes, s.agreementType, (v) => s.agreementType = v),
          if (s.agreementType != 'UNSCHEDULED') ...[
            _choice('Amount Variability', Options.amountVariabilities, s.amountVariability,
                (v) => s.amountVariability = v),
            _choice('Number of payments', Options.numbersOfPayments, s.numberOfPayments,
                (v) => s.numberOfPayments = v),
            if (s.numberOfPayments == 'Defined') _integer('Count', s.paymentCount, (v) => s.paymentCount = v),
          ],
          _text('Subscription Name', s.subscriptionName, (v) => s.subscriptionName = v),
          _text('Subscription Description', s.subscriptionDescription, (v) => s.subscriptionDescription = v),
          _text('Billing Agreement', s.billingAgreement, (v) => s.billingAgreement = v),
        ],
        _choice('Airline', Options.airline, s.airline, (v) => s.airline = v),
        if (s.airline == 'yes')
          _text('Booking Reference Number', s.bookingReference, (v) => s.bookingReference = v),
      ]);

  // Row builders

  List<Widget> _section(String title, List<Widget> rows, {String? footer}) {
    final palette = Palette.of(context);
    return [
      SectionHeader(title),
      CardBox(
        radius: 12,
        child: Column(
          children: [
            for (final (index, row) in rows.indexed) ...[
              if (index > 0) const Divider(indent: 16),
              row,
            ],
          ],
        ),
      ),
      if (footer != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Text(footer, style: TextStyle(fontSize: 13, color: palette.secondaryLabel)),
        ),
      const SizedBox(height: 24),
    ];
  }

  Widget _row(String title, {String? value, Widget? trailing, VoidCallback? onTap, Color? titleColor}) {
    final palette = Palette.of(context);
    return InkWell(
      key: Key('setting.$title'),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            // Values and chevrons line up on the right edge, like a grouped table on iOS.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // The title gets the room it needs (up to 60%); the value is truncated, like iOS does.
              Flexible(
                flex: 3,
                child: Text(title, style: TextStyle(fontSize: 16, color: titleColor)),
              ),
              if (value != null || trailing != null)
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (value != null) ...[
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: palette.secondaryLabel),
                          ),
                        ),
                      ],
                      if (trailing != null) ...[const SizedBox(width: 6), trailing],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _chevron => Icon(Icons.chevron_right, size: 20, color: Palette.of(context).gray);

  Widget _text(String title, String value, void Function(String) set, {TextInputType? keyboard}) => _row(
        title,
        value: value.isEmpty ? 'Not set' : value,
        trailing: _chevron,
        onTap: () async {
          final text = await _editText(title, value, keyboard);
          if (text != null) _change((_) => set(text));
        },
      );

  Widget _decimal(String title, double value, void Function(double) set) => _text(
        title,
        formatAmount(value),
        (input) {
          final number = double.tryParse(input);
          if (number != null) set(number);
        },
        keyboard: const TextInputType.numberWithOptions(decimal: true),
      );

  Widget _integer(String title, int value, void Function(int) set) => _text(
        title,
        '$value',
        (input) {
          final number = int.tryParse(input);
          if (number != null) set(number);
        },
        keyboard: TextInputType.number,
      );

  Widget _toggle(String title, bool value, void Function(bool) set) => _row(
        title,
        trailing: Switch.adaptive(value: value, onChanged: (v) => _change((_) => set(v))),
        onTap: () => _change((_) => set(!value)),
      );

  Widget _choice(String title, List<Option> options, String value, void Function(String) set) => _row(
        title,
        value: options.where((o) => o.value == value).firstOrNull?.title ?? value,
        trailing: _chevron,
        onTap: () async {
          final picked = await _pick(title, options, {value}, multiple: false);
          if (picked != null) _change((_) => set(picked.first));
        },
      );

  Widget _multi(String title, List<Option> options, List<String> value, void Function(List<String>) set) => _row(
        title,
        value: value.isEmpty ? 'None' : value.join(', '),
        trailing: _chevron,
        onTap: () async {
          final picked = await _pick(title, options, value.toSet(), multiple: true);
          // Keep the order of the options list rather than the order of the taps.
          if (picked != null) _change((_) => set([for (final o in options) if (picked.contains(o.value)) o.value]));
        },
      );

  Widget _info(String title, String value) => _row(title, value: value);

  Widget _button(String title, VoidCallback action, {bool destructive = false}) {
    final palette = Palette.of(context);
    return _row(title, onTap: action, titleColor: destructive ? palette.red : palette.blue);
  }

  // Editors

  Future<String?> _editText(String title, String value, TextInputType? keyboard) => showDialog<String>(
        context: context,
        builder: (context) => _TextDialog(title: title, value: value, keyboard: keyboard),
      );

  /// A sheet listing [options]; single choice closes on tap, multiple choice closes with Done.
  Future<Set<String>?> _pick(String title, List<Option> options, Set<String> selected, {required bool multiple}) {
    final chosen = {...selected};
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Palette.of(context).background,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: options.length > 8 ? 0.7 : 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                    if (multiple)
                      TextButton(onPressed: () => Navigator.pop(context, chosen), child: const Text('Done')),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    CardBox(
                      radius: 12,
                      child: Column(
                        children: [
                          for (final (index, option) in options.indexed) ...[
                            if (index > 0) const Divider(indent: 16),
                            _row(
                              option.title,
                              trailing: chosen.contains(option.value)
                                  ? Icon(Icons.check, size: 20, color: Palette.of(context).blue)
                                  : const SizedBox(width: 20),
                              onTap: () {
                                if (!multiple) {
                                  Navigator.pop(context, {option.value});
                                  return;
                                }
                                setSheetState(() {
                                  if (!chosen.remove(option.value)) chosen.add(option.value);
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edits one text row. Owns its controller, which must outlive the dialog's closing animation.
class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.value, this.keyboard});

  final String title;
  final String value;
  final TextInputType? keyboard;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          key: const Key('settingField'),
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboard,
          inputFormatters: widget.keyboard == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
          onSubmitted: (text) => Navigator.pop(context, text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('OK')),
        ],
      );
}
