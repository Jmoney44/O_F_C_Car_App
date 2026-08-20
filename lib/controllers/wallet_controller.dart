import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';

class WalletController extends GetxController {
  DocumentReference get _userDoc =>
      firestore.collection(usersCollection).doc(currentUser!.uid);

  Stream<num> balanceStream() {
    return _userDoc.snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return (data?['wallet_balance'] as num?) ?? 0;
    });
  }

  Stream<QuerySnapshot> transactionsStream({int? limit}) {
    var query = _userDoc
        .collection(walletTransactionsCollection)
        .orderBy('created_on', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  Future<void> topUp(num amount, {String title = "Top Up Wallet"}) async {
    await _userDoc.set({
      'wallet_balance': FieldValue.increment(amount),
    }, SetOptions(merge: true));
    await _userDoc.collection(walletTransactionsCollection).add({
      'title': title,
      'amount': amount,
      'direction': 'in',
      'created_on': FieldValue.serverTimestamp(),
    });
  }

  /// Returns false without writing anything if the balance can't cover it.
  Future<bool> debit(num amount, {required String title}) async {
    final snapshot = await _userDoc.get();
    final data = snapshot.data() as Map<String, dynamic>?;
    final currentBalance = (data?['wallet_balance'] as num?) ?? 0;
    if (currentBalance < amount) return false;

    await _userDoc.set({
      'wallet_balance': FieldValue.increment(-amount),
    }, SetOptions(merge: true));
    await _userDoc.collection(walletTransactionsCollection).add({
      'title': title,
      'amount': amount,
      'direction': 'out',
      'created_on': FieldValue.serverTimestamp(),
    });
    return true;
  }
}
