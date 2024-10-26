import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/store.dart';

class ExcelHelper {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  /// Export stores to Excel file
  static Future<String?> exportStores(List<Store> stores) async {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();

      // Get or create the sheet for stores
      Sheet sheetObject = excel['Stores'];

      // Define headers
      final headers = [
        'Store Name',
        'Business Type',
        'Address',
        'Contact Person',
        'Phone Number',
        'Email',
        'Visit Date',
        'Business Hours',
        'Website',
        'Partnership Potential',
        'Notes',
        'Follow-up Date',
        'Latitude',
        'Longitude',
        'Photo Path',
        'Created At',
        'Updated At'
      ];

      // Add headers
      for (var i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: i,
          rowIndex: 0,
        ));
        cell.value = headers[i];

        // Style header cells
        cell.cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // Add data rows
      for (var i = 0; i < stores.length; i++) {
        final store = stores[i];
        final row = i + 1;  // +1 because row 0 is headers

        final cells = [
          store.storeName,
          store.businessType,
          store.address,
          store.contactPerson,
          store.phoneNumber,
          store.email ?? '',
          _dateFormatter.format(store.visitDate),
          store.businessHours,
          store.website ?? '',
          '${store.partnershipPotential}/5',
          store.notes ?? '',
          store.followUpDate != null ? _dateFormatter.format(store.followUpDate!) : '',
          store.latitude.toString(),
          store.longitude.toString(),
          store.photoPath ?? '',
          _dateFormatter.format(store.createdAt),
          _dateFormatter.format(store.updatedAt),
        ];

        // Add cells
        for (var j = 0; j < cells.length; j++) {
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(
            columnIndex: j,
            rowIndex: row,
          ));
          cell.value = cells[j];
        }
      }

      // Add summary
      final summaryRow = stores.length + 2;  // +2 for header and gap

      // Calculate summary data
      final averageRating = stores.isEmpty ? 0.0 :
      stores.map((s) => s.partnershipPotential).reduce((a, b) => a + b) / stores.length;

      final upcomingFollowUps = stores.where((s) =>
      s.followUpDate != null &&
          s.followUpDate!.isAfter(DateTime.now())
      ).length;

      // Add summary rows
      final summaryData = [
        ['Total Stores:', stores.length.toString()],
        ['Average Partnership Potential:', averageRating.toStringAsFixed(1)],
        ['Upcoming Follow-ups:', upcomingFollowUps.toString()],
        ['Export Date:', _dateFormatter.format(DateTime.now())],
      ];

      // Add summary data
      for (var i = 0; i < summaryData.length; i++) {
        var labelCell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: summaryRow + i,
        ));
        labelCell.value = summaryData[i][0];
        labelCell.cellStyle = CellStyle(bold: true);

        var valueCell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: summaryRow + i,
        ));
        valueCell.value = summaryData[i][1];
      }

      // Create the output file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'store_visits_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Save the Excel file
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  /// Export filtered stores to Excel
  static Future<String?> exportFilteredStores(
      List<Store> stores, {
        DateTime? startDate,
        DateTime? endDate,
        int? minRating,
        String? businessType,
      }) async {
    try {
      // Filter stores based on criteria
      var filteredStores = stores.where((store) {
        bool passesFilter = true;

        if (startDate != null) {
          passesFilter = passesFilter && store.visitDate.isAfter(startDate);
        }

        if (endDate != null) {
          passesFilter = passesFilter && store.visitDate.isBefore(endDate);
        }

        if (minRating != null) {
          passesFilter = passesFilter && store.partnershipPotential >= minRating;
        }

        if (businessType != null) {
          passesFilter = passesFilter &&
              store.businessType.toLowerCase() == businessType.toLowerCase();
        }

        return passesFilter;
      }).toList();

      // Export filtered stores
      return await exportStores(filteredStores);
    } catch (e) {
      debugPrint('Error exporting filtered stores: $e');
      return null;
    }
  }

  /// Get Excel file statistics
  static Future<Map<String, dynamic>> getExcelStats(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.sheets[excel.getDefaultSheet()];

      if (sheet == null) return {};

      int rowCount = sheet.maxRows;
      int fileSize = await file.length();

      return {
        'rowCount': rowCount,
        'fileSize': fileSize,
        'filePath': filePath,
        'fileName': file.path.split('/').last,
        'createdAt': (await file.stat()).modified,
      };
    } catch (e) {
      debugPrint('Error getting Excel stats: $e');
      return {};
    }
  }
}