import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Fixed import
import 'dart:convert';
import '../models/store.dart';
import '../utils/storage_helper.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  final String _storesKey = 'stores_data';

  List<Store> get stores => [..._stores];

  StoreProvider() {
    _loadStores();
  }

  // Load stores from SharedPreferences
  Future<void> _loadStores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storesJson = prefs.getString(_storesKey);

      if (storesJson != null) {
        final List<dynamic> decodedData = json.decode(storesJson);
        _stores = decodedData.map((item) => Store.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stores: $e');
      _stores = [];
      notifyListeners();
    }
  }

  // Save stores to SharedPreferences
  Future<void> _saveStores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storesJson = json.encode(_stores.map((store) => store.toJson()).toList());
      await prefs.setString(_storesKey, storesJson);
    } catch (e) {
      debugPrint('Error saving stores: $e');
    }
  }

  // Add a new store
  Future<void> addStore(Store store) async {
    try {
      final newStore = Store(
        id: DateTime.now().toString(), // Generate a unique ID
        storeName: store.storeName,
        businessType: store.businessType,
        photoPath: store.photoPath,
        latitude: store.latitude,
        longitude: store.longitude,
        address: store.address,
        contactPerson: store.contactPerson,
        phoneNumber: store.phoneNumber,
        email: store.email,
        visitDate: store.visitDate,
        businessHours: store.businessHours,
        website: store.website,
        notes: store.notes,
        followUpDate: store.followUpDate,
        partnershipPotential: store.partnershipPotential,
      );

      _stores.add(newStore);
      notifyListeners();
      await _saveStores();
    } catch (e) {
      debugPrint('Error adding store: $e');
    }
  }

  // Update existing store
  Future<void> updateStore(Store store) async {
    try {
      final index = _stores.indexWhere((s) => s.id == store.id);
      if (index >= 0) {
        _stores[index] = store;
        notifyListeners();
        await _saveStores();
      }
    } catch (e) {
      debugPrint('Error updating store: $e');
    }
  }

  // Delete store
  Future<void> deleteStore(String id) async {
    try {
      // Find store to get photo path before deletion
      final store = _stores.firstWhere((store) => store.id == id);

      // Delete photo if exists
      if (store.photoPath != null) {
        await StorageHelper.deleteFile(store.photoPath!);
      }

      _stores.removeWhere((store) => store.id == id);
      notifyListeners();
      await _saveStores();
    } catch (e) {
      debugPrint('Error deleting store: $e');
    }
  }

  // Get store by ID
  Store? getStore(String id) {
    try {
      return _stores.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get stores by business type
  List<Store> getStoresByType(String businessType) {
    return _stores.where((store) =>
    store.businessType.toLowerCase() == businessType.toLowerCase()
    ).toList();
  }

  // Get stores by partnership potential
  List<Store> getStoresByPotential(int potential) {
    return _stores.where((store) =>
    store.partnershipPotential == potential
    ).toList();
  }

  // Get stores needing follow-up
  List<Store> getStoresNeedingFollowUp() {
    final now = DateTime.now();
    return _stores.where((store) =>
    store.followUpDate != null &&
        store.followUpDate!.isBefore(now)
    ).toList();
  }

  // Get stores visited within date range
  List<Store> getStoresVisitedBetween(DateTime start, DateTime end) {
    return _stores.where((store) =>
    store.visitDate.isAfter(start) &&
        store.visitDate.isBefore(end)
    ).toList();
  }

  // Clear all stores
  Future<void> clearAllStores() async {
    try {
      // Delete all photos
      for (var store in _stores) {
        if (store.photoPath != null) {
          await StorageHelper.deleteFile(store.photoPath!);
        }
      }

      _stores.clear();
      notifyListeners();
      await _saveStores();
    } catch (e) {
      debugPrint('Error clearing stores: $e');
    }
  }

  // Export stores to JSON
  Future<String?> exportToJson() async {
    try {
      final exportData = json.encode(_stores.map((store) => store.toJson()).toList());
      return exportData;
    } catch (e) {
      debugPrint('Error exporting stores: $e');
      return null;
    }
  }

  // Import stores from JSON
  Future<bool> importFromJson(String jsonData) async {
    try {
      final List<dynamic> decodedData = json.decode(jsonData);
      _stores = decodedData.map((item) => Store.fromJson(item)).toList();
      notifyListeners();
      await _saveStores();
      return true;
    } catch (e) {
      debugPrint('Error importing stores: $e');
      return false;
    }
  }

  // Search stores
  List<Store> searchStores(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _stores.where((store) {
      return store.storeName.toLowerCase().contains(lowercaseQuery) ||
          store.businessType.toLowerCase().contains(lowercaseQuery) ||
          store.address.toLowerCase().contains(lowercaseQuery) ||
          store.contactPerson.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}