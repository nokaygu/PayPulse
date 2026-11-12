import 'package:flutter/material.dart';

enum ViewStatus { loading, error, empty, success }

class FourStateView extends StatelessWidget {
  const FourStateView({
    super.key,
    required this.status,
    required this.child,
    this.errorMessage = 'İşlem sırasında bir hata oluştu.',
    this.emptyMessage = 'Gösterilecek veri bulunamadı.',
    this.onRetry,
    this.retryLabel = 'Tekrar dene',
  });

  final ViewStatus status;
  final Widget child;
  final String errorMessage;
  final String emptyMessage;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ViewStatus.loading:
        return const Center(
          child: CircularProgressIndicator(key: Key('loading-state')),
        );

      case ViewStatus.error:
        return _message(
          icon: Icons.error_outline,
          text: errorMessage,
          key: const Key('error-state'),
        );

      case ViewStatus.empty:
        return _message(
          icon: Icons.inbox_outlined,
          text: emptyMessage,
          key: const Key('empty-state'),
        );

      case ViewStatus.success:
        return child;
    }
  }

  Widget _message({
    required IconData icon,
    required String text,
    required Key key,
  }) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
