import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/store.dart';
import 'package:flutter/material.dart';

class ShareHelper {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  /// Share a single file
  static Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: subject ?? 'Shared File',
        );
      } else {
        debugPrint('File does not exist: $filePath');
      }
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  /// Share Excel export
  static Future<void> shareExcelFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Store Visits Export - $date',
          text: 'Store visits data export generated on $date',
        );
      } else {
        debugPrint('Excel file does not exist: $filePath');
      }
    } catch (e) {
      debugPrint('Error sharing Excel file: $e');
    }
  }

  /// Share multiple files
  static Future<void> shareFiles(List<String> filePaths, {String? subject}) async {
    try {
      // Verify all files exist
      final existingFiles = <XFile>[];
      for (var path in filePaths) {
        if (await File(path).exists()) {
          existingFiles.add(XFile(path));
        }
      }

      if (existingFiles.isNotEmpty) {
        await Share.shareXFiles(
          existingFiles,
          subject: subject ?? 'Shared Files',
        );
      }
    } catch (e) {
      debugPrint('Error sharing files: $e');
    }
  }

  /// Share store details as text
  static Future<void> shareStoreDetails(Store store) async {
    try {
      final visitDate = _dateFormatter.format(store.visitDate);
      final followUpDate = store.followUpDate != null
          ? _dateFormatter.format(store.followUpDate!)
          : 'Not set';

      final text = '''
Store Visit Details
------------------
Store Name: ${store.storeName}
Business Type: ${store.businessType}
Address: ${store.address}

Contact Information:
📞 ${store.contactPerson}
☎️ ${store.phoneNumber}
✉️ ${store.email ?? 'Not provided'}
🌐 ${store.website ?? 'Not provided'}

Visit Information:
📅 Visit Date: $visitDate
⏰ Business Hours: ${store.businessHours}
⭐ Partnership Potential: ${store.partnershipPotential}/5
📌 Follow-up Date: $followUpDate

Location:
📍 Coordinates: ${store.latitude}, ${store.longitude}

Additional Notes:
${store.notes ?? 'No notes provided'}
''';

      await Share.share(
        text,
        subject: 'Store Visit Details - ${store.storeName}',
      );
    } catch (e) {
      debugPrint('Error sharing store details: $e');
    }
  }

  /// Share multiple stores summary
  static Future<void> shareStoresSummary(List<Store> stores) async {
    try {
      if (stores.isEmpty) {
        debugPrint('No stores to share');
        return;
      }

      final averageRating = stores.map((s) => s.partnershipPotential).reduce((a, b) => a + b) / stores.length;
      final upcomingFollowUps = stores.where((s) =>
      s.followUpDate != null && s.followUpDate!.isAfter(DateTime.now())
      ).length;

      final text = '''
Stores Summary Report
-------------------
Total Stores: ${stores.length}
Average Partnership Potential: ${averageRating.toStringAsFixed(1)}/5
Upcoming Follow-ups: $upcomingFollowUps

Store Listing:
${stores.map((s) => '• ${s.storeName} (${s.businessType}) - ⭐${s.partnershipPotential}').join('\n')}

Report generated on ${_dateFormatter.format(DateTime.now())}
''';

      await Share.share(
        text,
        subject: 'Stores Summary Report',
      );
    } catch (e) {
      debugPrint('Error sharing stores summary: $e');
    }
  }

  /// Share store location
  static Future<void> shareStoreLocation(Store store) async {
    try {
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${store.latitude},${store.longitude}';
      final text = '''
Store Location: ${store.storeName}
Address: ${store.address}
Coordinates: ${store.latitude}, ${store.longitude}

Open in Google Maps:
$googleMapsUrl
''';

      await Share.share(
        text,
        subject: 'Store Location - ${store.storeName}',
      );
    } catch (e) {
      debugPrint('Error sharing store location: $e');
    }
  }

  /// Share store contact information
  static Future<void> shareStoreContact(Store store) async {
    try {
      final text = '''
Store Contact Information
-----------------------
Store: ${store.storeName}
Contact Person: ${store.contactPerson}
Phone: ${store.phoneNumber}
Email: ${store.email ?? 'Not provided'}
Website: ${store.website ?? 'Not provided'}
Business Hours: ${store.businessHours}
''';

      await Share.share(
        text,
        subject: 'Store Contact - ${store.storeName}',
      );
    } catch (e) {
      debugPrint('Error sharing store contact: $e');
    }
  }

  /// Share follow-up reminders
  static Future<void> shareFollowUpReminders(List<Store> stores) async {
    try {
      final followUps = stores.where((s) => s.followUpDate != null).toList()
        ..sort((a, b) => a.followUpDate!.compareTo(b.followUpDate!));

      if (followUps.isEmpty) {
        debugPrint('No follow-ups to share');
        return;
      }

      final text = '''
Follow-up Reminders
-----------------
${followUps.map((s) => '''
• ${s.storeName}
  Date: ${_dateFormatter.format(s.followUpDate!)}
  Contact: ${s.contactPerson} (${s.phoneNumber})
  Status: ${s.isFollowUpDue ? '⚠️ OVERDUE' : '✅ Upcoming'}
''').join('\n')}

Reminder generated on ${_dateFormatter.format(DateTime.now())}
''';

      await Share.share(
        text,
        subject: 'Store Follow-up Reminders',
      );
    } catch (e) {
      debugPrint('Error sharing follow-up reminders: $e');
    }
  }

  /// Share data as vCard
  static Future<void> shareAsVCard(Store store) async {
    try {
      final vcard = '''
BEGIN:VCARD
VERSION:3.0
FN:${store.storeName}
ORG:${store.businessType}
TEL:${store.phoneNumber}
EMAIL:${store.email ?? ''}
ADR:;;${store.address};;;
URL:${store.website ?? ''}
NOTE:${store.notes ?? ''}
END:VCARD
''';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${store.storeName}.vcf');
      await file.writeAsString(vcard);

      await shareFile(
        file.path,
        subject: 'Contact Card - ${store.storeName}',
      );
    } catch (e) {
      debugPrint('Error sharing vCard: $e');
    }
  }
}