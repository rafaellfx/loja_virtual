import 'package:flutter/material.dart';
import 'package:lojavirtual/datas/cart_product.dart';
import 'package:lojavirtual/datas/product_data.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:lojavirtual/models/cart_model.dart';
import 'package:lojavirtual/models/user_model.dart';
import 'package:lojavirtual/screen/cart_screen.dart';
import 'package:lojavirtual/screen/login_screen.dart';


class ProductScreen extends StatefulWidget {

  final ProductData product;

  ProductScreen(this.product);

  @override
  _ProductScreenState createState() => _ProductScreenState(this.product);
}

class _ProductScreenState extends State<ProductScreen> {

  final ProductData product;
  String size;

  _ProductScreenState(this.product);


  @override
  Widget build(BuildContext context) {

    final Color primaryColot = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 0.8,
            child: Carousel(
              images: product.images.map((url){
                return Image.network(url);
              }).toList(),
              dotSize: 4.0,
              dotSpacing: 15.0,
              dotBgColor: Colors.transparent,
              dotColor: primaryColot,
              autoplay: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  product.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500
                  ),
                  maxLines: 3,
                ),
                Text(
                  "R\$ ${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: primaryColot
                  ),
                ),
                SizedBox(height: 16.0,),
                Text(
                  "Tamanho",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0
                  ),
                ),
                SizedBox(
                  height: 34.0,
                  child: GridView(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.5
                    ),
                    children: product.sizes.map((s){
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            size = s;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            border: Border.all(
                                color: s == size ? primaryColot : Colors.grey[500],
                                width: 3.0)
                          ),
                          width: 50.0,
                          alignment: Alignment.center,
                          child: Text(s, style: TextStyle(color: s == size ? primaryColot : Colors.grey[500]),),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    onPressed: size == null
                       ? null
                       :(){
                        if(UserModel.of(context).isLoggedIn()){

                          CartProduct cartproduct = CartProduct();
                          cartproduct.size = size;
                          cartproduct.quantity = 1;
                          cartproduct.pid = product.id;
                          cartproduct.category = product.category;
                          cartproduct.productData = product;

                          CartModel.of(context).addCartItem(cartproduct);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CartScreen()));
                        }else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreen()));
                        }
                    },
                    child: Text(UserModel.of(context).isLoggedIn()  ? "Adicionar ao carrinho": "Entre para comprar",
                    style: TextStyle(fontSize: 18.0),),
                    color: primaryColot,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0,),
                Text(
                  "Descrição",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0
                  ),
                ),
                Text(product.description, style: TextStyle(fontSize: 16.0),)
              ],
            ),
          )
        ],
      ),
    );
  }
}
