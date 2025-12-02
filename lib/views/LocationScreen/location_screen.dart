import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:veegify/views/LocationScreen/location_detail_screen.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            }, icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.network(
            'https://oobrien.com/wordpress/wp-content/uploads/2016/07/googlemaps_july2016.jpg',
            fit: BoxFit.cover,
          )),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                        'Vendor Accepted Your Order From',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Icon(
                        Icons.storefront,
                        color: Colors.orange,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Freshly',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Spacer(),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        '7th street',
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  Divider(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [Text('Total Items'), Spacer(), Text('03')],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text("Sub Total"),
                      Spacer(),
                      Text("₹225"),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text("Delivery charge"),
                      Spacer(),
                      Text("₹2.00"),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  Row(
                    children: [
                      Text(
                        'Total Payable',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Spacer(),
                      Text(
                        '227',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    )
                  ]),
              child: Row(
                children: [
                  const Icon(
                    Icons.delivery_dining,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(
                      child: Text(
                    'Waiting for Order\npickup response!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LocationDetailScreen()));
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: const Icon(FontAwesomeIcons.hourglassHalf,
                          color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
