import 'package:flutter/material.dart';

class LocationDetailScreen extends StatelessWidget {
  const LocationDetailScreen({super.key});

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
          // SizedBox(height: 20,),
          Positioned(
            left: 16,
            right: 16,
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow:const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.orange, size: 12),
                          Container(
                            height: 30,
                            width: 1,
                            color: Colors.grey,
                          ),
                          const Icon(Icons.location_on,
                              color: Colors.orange, size: 16),
                        ],
                      ),
                      const SizedBox(width: 10),
                   const   Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:  [
                            Text("Freshly",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Restaurant · 13:00 PM",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 8),
                            Text("You - 49th st",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Home · 13:30 PM",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Text(
                        "5mins",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                const  Row(
                    children: [
                       CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg'),
                        radius: 24,
                      ),
                       SizedBox(width: 10),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pavan",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Delivery - 1234567891",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:  Color.fromARGB(255, 33, 152, 37),
                            child:
                                 Icon(Icons.message, color: Colors.white),
                          ),
                           SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor:  Color.fromARGB(255, 33, 152, 37),
                            child:  Icon(Icons.call, color: Colors.white),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
