// checkout_flutter integration: build the configuration from the saved settings, start the checkout
// and log every callback. The Settings screen edits the same inputs as the Tap web demo.
//
// The screen shows what the next checkout will do (mode, amount, key), the main settings, and every
// callback as a card that expands to its full payload. Same layout as the native example apps.

import 'dart:async';
import 'dart:convert';

import 'package:checkout_flutter/checkout_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'checkout_settings.dart';
import 'json_screen.dart';
import 'settings_screen.dart';
import 'test_hooks.dart';
import 'widgets.dart';

class _Callback {
  _Callback(this.name, this.payload) : time = _clock(DateTime.now());

  final String name;
  final String time;
  final String? payload;

  static String _clock(DateTime t) =>
      [t.hour, t.minute, t.second].map((n) => n.toString().padLeft(2, '0')).join(':');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Edited in the Settings screen and persisted; reloaded whenever this screen comes back.
  CheckoutSettings _settings = CheckoutSettings();
  final List<_Callback> _callbacks = [];
  bool _loading = false;
  Timer? _loadTimeout;

  @override
  void initState() {
    super.initState();
    _reload().then((_) {
      if (TestHooks.autoStart) _startCheckout();
    });
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    final settings = await CheckoutSettings.load();
    if (mounted) setState(() => _settings = settings);
  }

  // Actions

  Future<void> _openSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await _reload();
  }

  void _showJson() {
    final configuration = TestHooks.apply(_settings.makeConfiguration());
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConfigurationJsonScreen(configuration: configuration)));
  }

  Future<void> _startCheckout() async {
    if (!_settings.hasPublicKey && !TestHooks.isActive) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Public key missing'),
          content: const Text(
            'Set your Tap sandbox public key in lib/src/keys.dart (Keys.publicKey) of the shared example, '
            'run with --dart-define=TAP_PUBLIC_KEY=pk_test_..., or enter it in Settings > SDK Configuration > Public Key.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }
    // The button shows a spinner until the checkout is ready (or fails). A checkout that never
    // loads gives the button back after two minutes, like the Android example.
    _setLoading(true);
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(minutes: 2), () {
      if (!mounted) return;
      _setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The checkout did not load. Check your connection and try again.')),
      );
    });
    // The plugin takes a plain map; makeConfiguration() builds it like the Tap web demo does.
    final started = await startCheckout(
      configurations: TestHooks.apply(_settings.makeConfiguration()),
      onReady: () {
        _setLoading(false);
        _add('onReady');
      },
      onChargeCreated: (data) => _add('onChargeCreated', data),
      onSuccess: (data) {
        _setLoading(false);
        _add('onSuccess', data);
      },
      onError: (data) {
        _setLoading(false);
        _add('onError', data);
      },
      onClose: () {
        _setLoading(false);
        _add('onClose');
      },
    );
    if (!started) {
      _setLoading(false);
      _add('onError', '{"error":"The checkout could not be started."}');
    }
  }

  void _setLoading(bool loading) {
    if (!loading) _loadTimeout?.cancel();
    if (mounted) setState(() => _loading = loading);
  }

  void _add(String name, [String? payload]) {
    debugPrint('TapCheckoutCallback ${_logLine(_Callback(name, payload))}');
    if (mounted) setState(() => _callbacks.insert(0, _Callback(name, payload)));
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Tap Checkout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _openSettings,
            child: Text('SETTINGS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: palette.blue)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // Integration tests read the plain-text log, so show it near the top instead of the cards.
                if (!TestHooks.isActive) ...[
                  _hero(),
                  const SizedBox(height: 24),
                  const SectionHeader('Configuration'),
                  _configCard(),
                  const SizedBox(height: 24),
                ],
                SectionHeader(
                  _callbacks.isEmpty ? 'Callbacks' : 'Callbacks (${_callbacks.length})',
                  trailing: _callbacks.isEmpty
                      ? null
                      : TextButton(onPressed: () => setState(_callbacks.clear), child: const Text('Clear')),
                ),
                if (TestHooks.isActive)
                  _callbackLog()
                else if (_callbacks.isEmpty)
                  CardBox(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Text(
                      'Callbacks will appear here.\nTap a callback to see its full payload.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: palette.secondaryLabel),
                    ),
                  )
                else
                  for (final callback in _callbacks) ...[
                    _CallbackCard(
                      key: ObjectKey(callback),
                      callback: callback,
                      summary: _summary(callback),
                      color: _color(callback.name, palette),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                key: const Key('startCheckout'),
                onPressed: _loading ? null : _startCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: palette.blue,
                  disabledBackgroundColor: palette.blue.withValues(alpha: 0.7),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_loading) ...[
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(child: Text(_loading ? 'Opening checkout…' : 'Start Checkout', maxLines: 1)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final palette = Palette.of(context);
    final s = _settings;
    final key = s.publicKey.trim();
    final (keyText, keyColor) = !s.hasPublicKey
        ? ('No public key', palette.red)
        : key.startsWith('pk_live_')
            ? ('Live key', palette.orange)
            : ('Sandbox key', palette.green);
    final count = s.items.length;
    final customer = '${s.firstName} ${s.lastName}'.trim();
    final white80 = Colors.white.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(gradient: Palette.heroGradient, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.mode == 'authorize' ? 'AUTHORIZE · ${s.authorizeType}' : 'CHARGE',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: white80),
                ),
              ),
              Pill(keyText, color: keyColor),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${formatAmount(s.totalAmount)} ${s.selectedCurrency}',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text('$count item${count == 1 ? '' : 's'} · $customer', style: TextStyle(fontSize: 15, color: white80)),
        ],
      ),
    );
  }

  Widget _configCard() {
    final s = _settings;
    String list(List<String> values) => values.isEmpty ? 'All' : values.join(', ');
    final rows = [
      ('Payment type', s.paymentType),
      ('Payment methods', list(s.supportedPaymentMethods)),
      ('Currencies', list(s.supportedCurrencies)),
      ('Language', s.language),
      ('Theme', s.theme),
      ('Checkout mode', s.checkoutMode),
      ('3D Secure', s.threeDSecure ? 'On' : 'Off'),
      ('Save card', s.saveCardOption),
      ('Card funding', s.cardFundingSource),
      ('Customer', '${s.email} · +${s.countryCode} ${s.phoneNumber}'),
    ];
    return CardBox(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) const Divider(),
            ValueRow(label: row.$1, value: row.$2),
          ],
          const Divider(),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(onPressed: _openSettings, child: const Text('Edit settings')),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _showJson, child: const Text('View JSON')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Plain-text log of every callback; shown instead of the cards when an integration test runs.
  Widget _callbackLog() => CardBox(
        padding: const EdgeInsets.all(12),
        child: Text(
          _callbacks.isEmpty
              ? 'Callbacks will appear here...'
              : _callbacks.map((c) => '[${c.time}] ${_logLine(c)}').join('\n\n'),
          key: const Key('callbackLog'),
          style: const TextStyle(fontSize: 13),
        ),
      );

  String _logLine(_Callback callback) => switch (callback.name) {
        'onReady' => 'onReady: Checkout is ready',
        'onClose' => 'onClose: Checkout was closed',
        _ => '${callback.name}: ${callback.payload ?? ''}',
      };

  Color _color(String name, Palette palette) => switch (name) {
        'onReady' => palette.blue,
        'onChargeCreated' => palette.purple,
        'onSuccess' => palette.green,
        'onError' => palette.red,
        _ => palette.gray,
      };

  /// One line that says what happened, read from the payload where there is one.
  String _summary(_Callback callback) {
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(callback.payload ?? '');
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {}
    String? text(String key) {
      final value = json?[key];
      if (value == null) return null;
      final string = '$value';
      return string.isEmpty ? null : string;
    }

    final String? line = switch (callback.name) {
      'onReady' => 'Checkout is ready',
      'onClose' => 'Checkout was closed',
      'onChargeCreated' => () {
          final amount = [text('amount'), text('currency')].nonNulls.join(' ');
          return [text('id'), text('status'), amount.isEmpty ? null : amount].nonNulls.join(' · ');
        }(),
      'onSuccess' => text('chargeId') == null ? null : 'Completed · ${text('chargeId')}',
      'onError' => text('message') == null
          ? null
          : (text('code') == null ? text('message') : '${text('message')} (${text('code')})'),
      _ => null,
    };
    final payload = callback.payload ?? '';
    return (line == null || line.isEmpty) ? payload.substring(0, payload.length.clamp(0, 120)) : line;
  }
}

/// 0.1 -> "0.1", 10.0 -> "10" (no trailing ".0").
String formatAmount(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

/// One callback: event name, time and a one-line summary; tap to show the full payload,
/// long press to copy it.
class _CallbackCard extends StatefulWidget {
  const _CallbackCard({super.key, required this.callback, required this.summary, required this.color});

  final _Callback callback;
  final String summary;
  final Color color;

  @override
  State<_CallbackCard> createState() => _CallbackCardState();
}

class _CallbackCardState extends State<_CallbackCard> {
  bool _expanded = false;

  String get _prettyPayload {
    final payload = widget.callback.payload ?? '';
    try {
      return prettyJson(jsonDecode(payload));
    } catch (_) {
      return payload;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final hasPayload = widget.callback.payload != null;
    return GestureDetector(
      onTap: hasPayload ? () => setState(() => _expanded = !_expanded) : null,
      onLongPress: hasPayload
          ? () {
              Clipboard.setData(ClipboardData(text: _prettyPayload));
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payload copied')));
            }
          : null,
      child: CardBox(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(widget.callback.name, color: widget.color, monospace: true),
                const Spacer(),
                Text(widget.callback.time, style: TextStyle(fontSize: 12, color: palette.secondaryLabel)),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.summary, style: const TextStyle(fontSize: 15)),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CardBox(
                        color: palette.inset,
                        radius: 8,
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(_prettyPayload, style: monospace.copyWith(fontSize: 11)),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
