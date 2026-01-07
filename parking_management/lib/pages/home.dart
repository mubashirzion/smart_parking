import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import 'book.dart';
import 'activity.dart';
import 'profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Hero(
              tag: 'profile_icon',
              child: Icon(Icons.person, color: Colors.black),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: bookingService.getBookingStream(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            );
          }

          final allBookings = snapshot.data ?? [];
          final activeBookings =
              allBookings.where((b) => b['status'] == 'active').toList();
          final historyBookings =
              allBookings.where((b) => b['status'] == 'released').toList();

          return Center(
            child: FractionallySizedBox(
              widthFactor: 0.95,
              child: Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Center(
                          child: const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        
                        activeBookings.isNotEmpty
                            ? _buildActiveCard(context, activeBookings.first)
                            : _buildIdleCard(context),

                        const SizedBox(height: 24),
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),

                        
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.confirmation_number,
                                title: 'Total Visits',
                                value: historyBookings.length.toString(),
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.access_time,
                                title: 'Active Now',
                                value: activeBookings.length.toString(),
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.local_parking,
                                title: 'Last Spot',
                                value: historyBookings.isNotEmpty
                                    ? 'Spot ${historyBookings.first['spot_id'] ?? '?'}'
                                    : 'N/A',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.payments_outlined,
                                title: 'Total Spent',
                                value:
                                    '\$${historyBookings.fold<num>(0, (sum, item) => sum + (item['amount'] ?? 0)).toStringAsFixed(2)}',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightGreen,
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookPage())),
        label: const Text(
          "BOOK NOW",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, Map item) {
    return Card(
      color: Colors.lightGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityPage())),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ACTIVE PARKING",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration:
                        const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.bolt, color: Colors.amberAccent, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.timer, size: 40, color: Colors.black),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
  Theme(
    data: Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    child: CountdownWidget(
      createdAt: DateTime.parse(
        item['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      hoursBooked: (item['hours'] ?? 0) as int,
    ),
  ),
  Text(
    "Time remaining at Spot ${item['spot_id'] ?? 'N/A'}",
    style: const TextStyle(fontSize: 12, color: Colors.black),
  ),
],

                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleCard(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.local_parking, size: 40, color: Colors.white24),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No Active Sessions',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _summaryCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
