import 'package:url_launcher/url_launcher.dart';

/// Utility class untuk WhatsApp integration
class WhatsAppHelper {
  /// Open WhatsApp chat dengan nomor tertentu
  /// phoneNumber format: "628123456789" (tanpa +, dengan kode negara)
  static Future<void> openWhatsApp(
    String phoneNumber, {
    String? message,
  }) async {
    // Clean phone number (remove spaces, dashes, etc)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure number starts with country code (62 for Indonesia)
    String formattedNumber = cleanNumber;
    if (cleanNumber.startsWith('0')) {
      formattedNumber = '62${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('62')) {
      formattedNumber = '62$cleanNumber';
    }

    // Build WhatsApp URL
    final encodedMessage = message != null ? Uri.encodeComponent(message) : '';
    final whatsappUrl = Uri.parse(
      'https://wa.me/$formattedNumber${message != null ? '?text=$encodedMessage' : ''}',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  /// Open phone dialer
  static Future<void> openPhoneDialer(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final telUrl = Uri.parse('tel:$cleanNumber');

    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      throw 'Could not launch phone dialer';
    }
  }

  /// Open email client
  static Future<void> openEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final emailUrl = Uri(
      scheme: 'mailto',
      path: email,
      query:
          {
                if (subject != null) 'subject': subject,
                if (body != null) 'body': body,
              }.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&'),
    );

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      throw 'Could not launch email client';
    }
  }
}
