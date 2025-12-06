import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../models/nasabah.dart';
import '../models/driver.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/withdrawal.dart';
import '../models/company.dart';

/// Service for loading and managing JSON data
class JsonService {
  JsonService._();
  static final JsonService instance = JsonService._();

  // Cached data
  List<User>? _admins;
  List<Driver>? _drivers;
  List<Nasabah>? _nasabahs;
  Company? _company;
  List<Category>? _categories;
  List<Transaction>? _transactions;
  List<Withdrawal>? _withdrawals;

  /// Initialize all data
  Future<void> initialize() async {
    await Future.wait([
      loadAdmins(),
      loadDrivers(),
      loadNasabahs(),
      loadCompany(),
      loadCategories(),
      loadTransactions(),
      loadWithdrawals(),
    ]);
  }

  /// Load admin users
  Future<List<User>> loadAdmins() async {
    if (_admins != null) return _admins!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/admin.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _admins = jsonData.map((json) => User.fromJson(json)).toList();
    return _admins!;
  }

  /// Load drivers
  Future<List<Driver>> loadDrivers() async {
    if (_drivers != null) return _drivers!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/driver.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _drivers = jsonData.map((json) => Driver.fromJson(json)).toList();
    return _drivers!;
  }

  /// Load nasabahs
  Future<List<Nasabah>> loadNasabahs() async {
    if (_nasabahs != null) return _nasabahs!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/nasabah.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _nasabahs = jsonData.map((json) => Nasabah.fromJson(json)).toList();
    return _nasabahs!;
  }

  /// Alias for loadNasabahs
  Future<List<Nasabah>> loadNasabah() => loadNasabahs();

  /// Load company profile
  Future<Company> loadCompany() async {
    if (_company != null) return _company!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/company.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _company = Company.fromJson(jsonData[0]);
    return _company!;
  }

  /// Load categories
  Future<List<Category>> loadCategories() async {
    if (_categories != null) return _categories!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/categories.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _categories = jsonData.map((json) => Category.fromJson(json)).toList();
    return _categories!;
  }

  /// Add new category
  void addCategory(Category category) {
    if (_categories == null) {
      _categories = [];
    }
    _categories!.add(category);
  }

  /// Load transactions
  Future<List<Transaction>> loadTransactions() async {
    if (_transactions != null) return _transactions!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/transactions.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _transactions = jsonData.map((json) => Transaction.fromJson(json)).toList();
    return _transactions!;
  }

  /// Load withdrawals
  Future<List<Withdrawal>> loadWithdrawals() async {
    if (_withdrawals != null) return _withdrawals!;

    final String jsonString = await rootBundle.loadString(
      'assets/jsons/withdrawals.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _withdrawals = jsonData.map((json) => Withdrawal.fromJson(json)).toList();
    return _withdrawals!;
  }

  /// Authenticate user
  Future<dynamic> authenticate(
    String username,
    String password,
    String role,
  ) async {
    if (role == 'admin') {
      final admins = await loadAdmins();
      return admins.firstWhere(
        (user) => user.username == username && user.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );
    } else if (role == 'driver') {
      final drivers = await loadDrivers();
      return drivers.firstWhere(
        (user) => user.username == username && user.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );
    } else if (role == 'nasabah') {
      final nasabahs = await loadNasabahs();
      return nasabahs.firstWhere(
        (user) => user.username == username && user.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );
    }
    throw Exception('Invalid role');
  }

  /// Get nasabah by ID
  Future<Nasabah?> getNasabahById(String id) async {
    final nasabahs = await loadNasabahs();
    try {
      return nasabahs.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get driver by ID
  Future<Driver?> getDriverById(String id) async {
    final drivers = await loadDrivers();
    try {
      return drivers.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(String id) async {
    final categories = await loadCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get transactions by nasabah ID
  Future<List<Transaction>> getTransactionsByNasabahId(String nasabahId) async {
    final transactions = await loadTransactions();
    return transactions.where((t) => t.nasabahId == nasabahId).toList();
  }

  /// Get transactions by driver ID
  Future<List<Transaction>> getTransactionsByDriverId(String driverId) async {
    final transactions = await loadTransactions();
    return transactions.where((t) => t.driverId == driverId).toList();
  }

  /// Get withdrawals by nasabah ID
  Future<List<Withdrawal>> getWithdrawalsByNasabahId(String nasabahId) async {
    final withdrawals = await loadWithdrawals();
    return withdrawals.where((w) => w.nasabahId == nasabahId).toList();
  }

  /// Clear cache (useful for testing or data refresh)
  void clearCache() {
    _admins = null;
    _drivers = null;
    _nasabahs = null;
    _company = null;
    _categories = null;
    _transactions = null;
    _withdrawals = null;
  }
}
