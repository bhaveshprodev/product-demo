import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/ui/brand_mark.dart';
import '../../../../core/ui/rating_stars.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController = TextEditingController(
    text: ApiConstants.demoUsername,
  );
  late final TextEditingController _passwordController = TextEditingController(
    text: ApiConstants.demoPassword,
  );
  late final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final state = context.read<AuthBloc>().state;
    if (state.status == AuthStatus.authenticating) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      LoginSubmitted(
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.failure,
      listener: (context, state) => HapticFeedback.mediumImpact(),
      builder: (context, state) {
        final palette = context.palette;
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.canvas,
                  Color.alphaBlend(
                    palette.highlightSoft.withValues(alpha: 0.45),
                    palette.canvas,
                  ),
                ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 960) {
                    return _buildWide(context, state);
                  }
                  return _buildNarrow(context, state);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWide(BuildContext context, AuthState state) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(flex: 56, child: _BrandPanel()),
          Expanded(
            flex: 44,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: _buildForm(context, state, card: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrow(BuildContext context, AuthState state) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 76),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.forest, AppColors.forestDeep],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -80,
                  top: -60,
                  child: _DecorativeCircle(
                    size: 220,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: -38,
                  child: _DecorativeCircle(
                    size: 110,
                    color: AppColors.clay.withValues(alpha: 0.4),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandWordmark(inverted: true),
                    const SizedBox(height: 46),
                    _Eyebrow(
                      label: 'THE DAILY EDIT · AUTUMN 2026',
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Good finds,\nless fuss.',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppColors.cream,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'A small, considered storefront for the things\nyou actually use.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.cream.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: palette.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: _buildForm(context, state, card: true),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -24),
            child: _SecurityFooter(alignCenter: true),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AuthState state, {
    required bool card,
  }) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final busy = state.status == AuthStatus.authenticating;
    final error = state.errorMessage;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!card)
              const Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: BrandWordmark(),
              ),
            Text('Welcome back', style: theme.textTheme.displaySmall),
            const SizedBox(height: 10),
            Text(
              'Sign in to browse today’s edit of useful, beautiful things.',
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.muted),
            ),
            const SizedBox(height: 28),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: error == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _ErrorBanner(message: error),
                    ),
            ),
            TextFormField(
              controller: _usernameController,
              enabled: !busy,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'emilys',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your username';
                }
                return null;
              },
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !busy,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy ? null : _submit,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: busy
                      ? const Row(
                          key: ValueKey('loading'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Signing in…'),
                          ],
                        )
                      : const Row(
                          key: ValueKey('idle'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sign in'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 19),
                          ],
                        ),
                ),
              ),
            ),
            if (!card) ...[
              const SizedBox(height: 28),
              const _SecurityFooter(),
            ],
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF245A4B), AppColors.forest, AppColors.forestDeep],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactHeight = constraints.maxHeight < 780;
          final compactWidth = constraints.maxWidth < 720;
          final headlineSize = compactWidth ? 58.0 : 78.0;

          return Stack(
            children: [
              Positioned(
                right: -120,
                top: -150,
                child: _DecorativeCircle(
                  size: 470,
                  color: Colors.white.withValues(alpha: 0.055),
                ),
              ),
              Positioned(
                left: -150,
                bottom: -210,
                child: _DecorativeCircle(
                  size: 520,
                  color: AppColors.forestDeep.withValues(alpha: 0.55),
                ),
              ),
              Positioned(
                right: 54,
                top: 190,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.clay,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 92,
                bottom: 230,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compactWidth ? 36 : 52,
                  44,
                  compactWidth ? 36 : 52,
                  44,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandWordmark(
                      inverted: true,
                      subtitle: 'CURATED EVERYDAY GOODS',
                    ),
                    const Spacer(),
                    _Eyebrow(
                      label: 'THE DAILY EDIT · AUTUMN 2026',
                      color: AppColors.cream.withValues(alpha: 0.66),
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        'A calmer way\nto shop well.',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: AppColors.cream,
                          fontSize: headlineSize,
                          height: 0.98,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 410),
                      child: Text(
                        'Thoughtfully picked objects for the everyday — '
                        'beautifully made, honestly priced, and built to last.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.cream.withValues(alpha: 0.7),
                          height: 1.65,
                        ),
                      ),
                    ),
                    if (!compactHeight) ...[
                      const Spacer(),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const RatingStars(
                              rating: 4.9,
                              size: 15,
                              showValue: false,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '“Mercato makes the everyday feel considered. '
                              'A rare thing on the internet.”',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.cream,
                                fontFamily: 'Fraunces',
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'FIELD NOTES · ISSUE 04',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    AppColors.cream.withValues(alpha: 0.5),
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 22, height: 1, color: color),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 19, color: palette.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.ink,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter({this.alignCenter = false});

  final bool alignCenter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: palette.muted,
      fontSize: 11,
      letterSpacing: 0.2,
    );

    return Align(
      alignment: alignCenter ? Alignment.center : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: palette.muted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Device-keychain secured',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
