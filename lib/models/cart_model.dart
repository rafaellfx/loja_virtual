import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:lojavirtual/datas/cart_product.dart';
import 'package:lojavirtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

    UserModel user;

    List<CartProduct> products = [];

    String couponCode;
    int discountPercentage = 0;

    bool isLoading = false;


    static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);


    CartModel(this.user){
      if(user.isLoggedIn()){
        _loadCartItems();
      }
    }

    void addCartItem(CartProduct cartProduct){
      products.add(cartProduct);
      Firestore.instance.collection("users").document(user.firebaseUser.uid)
          .collection("cart").add(cartProduct.toMap())
          .then((doc){
            cartProduct.cid = doc.documentID;
      });
      notifyListeners();
    }

    void removeCartItem(CartProduct cartProduct){
      Firestore.instance.collection("users").document(user.firebaseUser.uid)
          .collection("cart").document(cartProduct.cid).delete();

      products.remove(cartProduct);
      notifyListeners();
    }

    void decProduct(CartProduct cartProduct){
        cartProduct.quantity--;

        Firestore.instance.collection("users").document(user.firebaseUser.uid)
            .collection("cart").document(cartProduct.cid).updateData(cartProduct.toMap());

        notifyListeners();
    }

    void incProduct(CartProduct cartProduct){
      cartProduct.quantity++;

      Firestore.instance.collection("users").document(user.firebaseUser.uid)
          .collection("cart").document(cartProduct.cid).updateData(cartProduct.toMap());

      notifyListeners();
    }

    void setCoupon(String couponCode, int discountPercentage){
      this.couponCode = couponCode;
      this.discountPercentage = discountPercentage;
    }

    void updatePrice(){
      notifyListeners();
    }

    double getProductsPrice(){
      double price = 0.0;
      for(CartProduct c in products){
        if(c.productData != null){
          price = c.quantity * c.productData.price;
        }
      }
      return price;
    }

    double getDiscout(){
      return getProductsPrice() * discountPercentage / 100;
    }

    Future<String> finishOrder() async{
      if(products.length == 0 ) return null;

      isLoading = true;
      notifyListeners();

      double productPrice = getProductsPrice();
      double shipPrice =  getShipPrice();
      double discout = getDiscout();

      DocumentReference refOrder = await Firestore.instance.collection("orders").add(
        {
          "clientId": user.firebaseUser.uid,
          "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
          "shipPrice": shipPrice,
          "productPrice": productPrice,
          "discout": discout,
          "totalPrice": productPrice - discout + shipPrice,
          "status": 1
        }
      );

      await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("ordes").document(refOrder.documentID).setData(
        {
          "orderId": refOrder.documentID
        }
      );

      QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart").getDocuments();

      for(DocumentSnapshot doc in query.documents){
        doc.reference.delete();
      }

      products.clear();

      discountPercentage = 0;
      couponCode = null;

      isLoading = false;
      notifyListeners();

      return refOrder.documentID;

    }

    double getShipPrice(){
      return 9.99;
    }

    void _loadCartItems() async{
      QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid)
          .collection("cart").getDocuments();

      products = query.documents.map((document) => CartProduct.fromDocument(document)).toList();
      notifyListeners();

    }
}