import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/home_controller.dart';

class CartController extends GetxController {
  var totalP = 0.obs;

  //text controllers for shipping details (legacy free-text form, no
  //longer shown once a saved address is selected — kept only so
  //nothing else referencing them breaks)
  var addressController = TextEditingController();
  var cityController = TextEditingController();
  var stateController = TextEditingController();
  var postalcodeController = TextEditingController();
  var phoneController = TextEditingController();

  var paymentIndex = 0.obs;

  //selected saved address
  var selectedAddressLabel = ''.obs;
  var selectedAddressDetails = ''.obs;

  //shipping method
  var shippingMethodIndex = (-1).obs;
  int get shippingCost =>
      shippingMethodIndex.value >= 0 ? shippingOptionPrices[shippingMethodIndex.value] : 0;
  String get shippingMethodName =>
      shippingMethodIndex.value >= 0 ? shippingOptionNames[shippingMethodIndex.value] : '';

  //flat placeholder tax, matching the reference's own flat figure
  final taxAmount = 1000;

  int get grandTotal => totalP.value + shippingCost + taxAmount;

  late dynamic productSnapshot;
  var products = [];
  var vendors = [];

  var placingOrder = false.obs;

  calculate(data) {
    totalP.value = 0;
    for (var i = 0; i < data.length; i++) {
      totalP.value = totalP.value + int.parse(data[i]['tprice'].toString());
    }
  }

  changePaymentIndex(index){
    paymentIndex.value = index;
  }

  selectAddress({required String label, required String details}) {
    selectedAddressLabel.value = label;
    selectedAddressDetails.value = details;
  }

  selectShippingMethod(int index) {
    shippingMethodIndex.value = index;
  }

  String _generateOrderCode() {
    return "OFC${DateTime.now().millisecondsSinceEpoch}";
  }

  placeMyOrder({required orderPaymentMethod}) async {
    placingOrder(true);
    await getProductDetails();
    await firestore.collection(ordersCollection).doc().set({
      'order_code': _generateOrderCode(),
      'order_date': FieldValue.serverTimestamp(),
      'order_by': currentUser!.uid,
      'order_by_name': Get.find<HomeController>().username,
      'order_by_email': currentUser!.email,
      'order_by_address': selectedAddressDetails.value,
      'order_by_state': '',
      'order_by_city': '',
      'order_by_phone': '',
      'order_by_postalcode': '',
      'shipping_method': shippingMethodName,
      'shipping_cost': shippingCost,
      'tax_amount': taxAmount,
      'payment_method': orderPaymentMethod,
      'order_placed': true,
      'order_confirmed': false,
      'order_delivered':false,
      'order_on_delivery': false,
      'total_amount': grandTotal,
      'orders': FieldValue.arrayUnion(products),
      'vendors': FieldValue.arrayUnion(vendors),
    });
    placingOrder(false);
  }

  getProductDetails(){
    products.clear();
    vendors.clear();
    for (var i = 0; i < productSnapshot.length; i++){
      products.add({
        'color': productSnapshot[i]['color'],
        'img': productSnapshot[i]['img'],
        'vendor_id': productSnapshot[i]['vendor_id'],
        'product_id': productSnapshot[i]['product_id'],
        'tprice': productSnapshot[i]['tprice'],
        'qty': productSnapshot[i]['qty'],
        'title': productSnapshot[i]['title']
      });
      vendors.add(productSnapshot[i]['vendor_id']);
    }
  }

  clearCart() {
    for (var i = 0; i < productSnapshot.length; i++) {
      firestore.collection(cartCollection).doc(productSnapshot[i].id).delete();
    }
  }

}
