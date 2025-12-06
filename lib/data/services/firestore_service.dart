import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/category.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/withdrawal.dart';
import '../models/company.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionCategories = 'categories';
  final String _collectionUsers = 'users';
  final String _collectionTransactions = 'transactions';
  final String _collectionWithdrawals = 'withdrawals';
  final String _collectionCompany = 'company';

  // --- Categories ---
  Stream<List<Category>> getCategoriesStream() {
    return _firestore.collection(_collectionCategories).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category.fromJson(data);
      }).toList();
    });
  }

  Future<void> addCategory(Category category) async {
    await _firestore
        .collection(_collectionCategories)
        .doc(category.id)
        .set(category.toJson());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore
        .collection(_collectionCategories)
        .doc(category.id)
        .update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(_collectionCategories).doc(id).delete();
  }

  // --- Users ---
  Stream<List<User>> getUsersStream({String? role}) {
    Query query = _firestore.collection(_collectionUsers);
    if (role != null) {
      query = query.where('role', isEqualTo: role);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addUser(User user) async {
    await _firestore
        .collection(_collectionUsers)
        .doc(user.id)
        .set(user.toJson());
  }

  Future<void> updateUser(User user) async {
    await _firestore
        .collection(_collectionUsers)
        .doc(user.id)
        .update(user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _firestore.collection(_collectionUsers).doc(id).delete();
  }

  // --- Transactions ---
  Stream<List<Transaction>> getTransactionsStream() {
    return _firestore
        .collection(_collectionTransactions)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Transaction.fromJson(doc.data());
          }).toList();
        });
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _firestore
        .collection(_collectionTransactions)
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  Future<void> updateTransactionStatus(String id, String status) async {
    await _firestore.collection(_collectionTransactions).doc(id).update({
      'status': status,
    });
  }

  // --- Withdrawals ---
  Stream<List<Withdrawal>> getWithdrawalsStream() {
    return _firestore
        .collection(_collectionWithdrawals)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Withdrawal.fromJson(doc.data());
          }).toList();
        });
  }

  Future<void> addWithdrawal(Withdrawal withdrawal) async {
    await _firestore
        .collection(_collectionWithdrawals)
        .doc(withdrawal.id)
        .set(withdrawal.toJson());
  }

  Future<void> updateWithdrawalStatus(String id, String status) async {
    await _firestore.collection(_collectionWithdrawals).doc(id).update({
      'status': status,
    });
  }

  // --- Company Profile ---
  Stream<Company?> getCompanyStream() {
    return _firestore.collection(_collectionCompany).limit(1).snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) return null;
      return Company.fromJson(snapshot.docs.first.data());
    });
  }

  Future<void> updateCompany(Company company) async {
    // Assuming single document for company profile
    final query = await _firestore
        .collection(_collectionCompany)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      await _firestore
          .collection(_collectionCompany)
          .doc(company.id)
          .set(company.toJson());
    } else {
      await _firestore
          .collection(_collectionCompany)
          .doc(query.docs.first.id)
          .update(company.toJson());
    }
  }
}
