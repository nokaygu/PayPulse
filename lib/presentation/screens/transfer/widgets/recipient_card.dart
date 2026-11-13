import 'package:flutter/material.dart';

import '../../../../domain/entities/safe_recipient_entity.dart';

/// Kayıtlı güvenli alıcı satır kartı (`StatelessWidget`).
class RecipientCard extends StatelessWidget {
  final SafeRecipientEntity recipient;
  final VoidCallback onTap;

  const RecipientCard({
    super.key,
    required this.recipient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = recipient.maskedName.isNotEmpty
        ? recipient.maskedName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : 'PP';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD1FAE5),
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF065F46),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          recipient.maskedName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          recipient.iban,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

