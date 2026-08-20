import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';

class FirestoreServices {
  //get users data
  static getUser(uid) {
    return firestore.collection(usersCollection).where('id', isEqualTo: uid).snapshots();
  }

  //get products according to category

  static getProducts(category){
    return firestore.collection(productsCollection).where('p_category', isEqualTo: category).snapshots();
  }

  static getSubCategoryProducts(title) {
    return firestore.collection(productsCollection).where('p_subcategory', isEqualTo: title).snapshots();
  }

  //get cart
  static getCart(uid) {
    return firestore
      .collection(cartCollection)
      .where('added_by', isEqualTo: uid)
      .snapshots();
  }

  //delete document
  static deleteDocument(docId) {
    return firestore.collection(cartCollection).doc(docId).delete();
  }

  //get all chat messages
  static getChatMessages(docId) {
    return firestore
      .collection(chatsCollection)
      .doc(docId)
      .collection(messagesCollection)
      .orderBy('created_on', descending: false)
      .snapshots();
  }

  static getAllOrders() {
    return firestore.collection(ordersCollection).where('order_by', isEqualTo: currentUser!.uid).snapshots();
  }

  static getWishlists() {
    return firestore.collection(productsCollection).where('p_wishlist', arrayContains: currentUser!.uid).snapshots();
  }

  static getAllMessages() {
    return firestore.collection(chatsCollection).where('fromId', isEqualTo: currentUser!.uid).snapshots();
  }

  static getCounts() async {
    var res = await Future.wait([
      firestore.collection(cartCollection).where('added_by', isEqualTo: currentUser!.uid).get().then((value) {
        return value.docs.length;
      }),
      firestore.collection(productsCollection).where('p_wishlist', arrayContains: currentUser!.uid).get().then((value) {
        return value.docs.length;
      }),
      firestore.collection(ordersCollection).where('order_by', isEqualTo: currentUser!.uid).get().then((value) {
        return value.docs.length;
      })
    ]);
    return res;
  }

  static allproducts() {
    return firestore.collection(productsCollection).snapshots();
  }
  
  //get featured products method
  static getFeaturedProducts() {
    return firestore.collection(productsCollection).where('is_Featured', isEqualTo: true).get();
  }

  static searchProducts(title){
    return firestore.collection(productsCollection).get();
  }

  //toggle a product's wishlist membership for the current user
  static Future<void> toggleWishlist(String docId, bool isCurrentlyFav) {
    return firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': isCurrentlyFav
          ? FieldValue.arrayRemove([currentUser!.uid])
          : FieldValue.arrayUnion([currentUser!.uid])
    }, SetOptions(merge: true));
  }

  static bool isInWishlist(dynamic data) {
    final list = (data.data() as Map<String, dynamic>)['p_wishlist'];
    return list is List && list.contains(currentUser!.uid);
  }

  static CollectionReference _userAddresses() =>
      firestore.collection(usersCollection).doc(currentUser!.uid).collection(addressesCollection);

  static getAddresses() => _userAddresses().snapshots();

  static Future<void> addAddress({
    required String label,
    required String details,
    required bool isDefault,
  }) async {
    if (isDefault) {
      final existing = await _userAddresses().get();
      for (final doc in existing.docs) {
        await doc.reference.update({'isDefault': false});
      }
    }
    await _userAddresses().add({'label': label, 'details': details, 'isDefault': isDefault});
  }

  static CollectionReference _userCards() =>
      firestore.collection(usersCollection).doc(currentUser!.uid).collection(cardsCollection);

  static getCards() => _userCards().snapshots();

  static Future<void> addCard({
    required String cardName,
    required String last4,
    required String brand,
    required String expiry,
  }) {
    return _userCards().add({
      'cardName': cardName,
      'last4': last4,
      'brand': brand,
      'expiry': expiry,
    });
  }

  static Future<void> addReview({
    required String productId,
    required String comment,
    required int rating,
  }) {
    return firestore
        .collection(productsCollection)
        .doc(productId)
        .collection(reviewsCollection)
        .add({
      'user_name': currentUser?.displayName ?? currentUser?.email ?? 'User',
      'uid': currentUser!.uid,
      'rating': rating,
      'comment': comment,
      'created_on': FieldValue.serverTimestamp(),
    });
  }
}