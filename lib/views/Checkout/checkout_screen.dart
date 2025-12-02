import 'package:flutter/material.dart';
import 'package:veegify/views/Checkout/card_details.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(width: 80),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Delivery address
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'Gandhi nagar,1–2–12',
                      style: TextStyle(fontSize: 16),
                    ),
                    
                    SizedBox(width: 90,),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                
              ),
              const SizedBox(height: 20),

              // Order section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Your Order'),
                  Text('2 items from Radha kitchen'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('1x Veg Fried rice', style: TextStyle(color: Colors.green)),
                  Text('₹250.00', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Notes section
              const Text('Add notes about your order'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.edit_note, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      'Add notes about your order',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Payment Method Section
              const Text(
                'Payment method',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
              const SizedBox(height: 15),

              _buildPaymentOption(Icons.credit_card, 'Credit/Debit card', true),
              _buildPaymentOption(Icons.account_balance_wallet, 'Phonepe'),
              _buildPaymentOption(Icons.account_balance_wallet_outlined, 'Google pay'),
              _buildPaymentOption(Icons.payment, 'Paytm'),
              _buildPaymentOption(Icons.money, 'Cash on Delivery'),
              const SizedBox(height: 30),

              // Proceed to Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const CardDetails()));
                  },
                  child: const Text(
                    'Proceed to pay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String title, [bool selected = false]) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio(
        value: title,
        groupValue: 'Credit/Debit card', // Hardcoded selection for demo
        onChanged: (value) {},
        activeColor: Colors.green,
      ),
      title: Text(title),
      trailing: Icon(icon, color: Colors.blue),
    );
  }
}
