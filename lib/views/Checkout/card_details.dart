import 'package:flutter/material.dart';
import 'package:veegify/views/home/verify_screen.dart';

class CardDetails extends StatelessWidget {
  const CardDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Spacer(),
                  const Text(
                    'Card Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 24),

             
              const Text("card holder name",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
              const SizedBox(height: 6),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Card Number
              const Text("Card Number",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
              const SizedBox(height: 6),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter card number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Expiry Date & CVV
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Expiry Date",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        const SizedBox(height: 6),
                        TextFormField(
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            hintText: 'Mm / Yy',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CVV",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        const SizedBox(height: 6),
                        TextFormField(
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'CVV',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Proceed to pay button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>const OtpScreen()));
                  },
                  child: const Text(
                    'Proceed to pay',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
