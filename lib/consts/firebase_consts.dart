import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
// A live getter, not a one-time snapshot — `auth.currentUser` can be
// null at import time (before a persisted session restores) and would
// otherwise stay null forever for returning signed-in users.
User? get currentUser => auth.currentUser;

//collections
const usersCollection = 'users';
const productsCollection = "products";
const cartCollection = "cart";
const chatsCollection = "chats";
const messagesCollection = "messages";

const ordersCollection = "orders";
const walletTransactionsCollection = "wallet_transactions";
const addressesCollection = "addresses";
const cardsCollection = "cards";
const offersCollection = "offers";
const reviewsCollection = "reviews";
