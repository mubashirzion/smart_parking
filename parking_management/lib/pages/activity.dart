import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  Future<void> _showReleaseDialog(
      BuildContext context, Map item, BookingService service) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('End Parking Session?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to release this spot? This will end your current session.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.lightGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await service.releaseSpot(
                  item['id'].toString(),
                  item['spot_id'].toString(),
                );
                if (context.mounted) {
                  _showSuccessSheet(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('YES, RELEASE', style: TextStyle(color: Colors.white,),
          ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('Spot Released!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Your session has ended. Have a safe drive!',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: const Text('My Bookings', style: TextStyle(color: Colors.black)),
          bottom: const TabBar(
            indicatorColor: Colors.lightGreen,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'ACTIVE', icon: Icon(Icons.timer)),
              Tab(text: 'HISTORY', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: bookingService.getBookingStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.amberAccent));

            final allBookings = snapshot.data!;
            final activeBookings = allBookings.where((b) => b['status'] == 'active').toList();
            final historyBookings = allBookings.where((b) => b['status'] == 'released').toList();

            return TabBarView(
              children: [
                _buildList(activeBookings, bookingService, isHistory: false),
                _buildList(historyBookings, bookingService, isHistory: true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, BookingService service, {required bool isHistory}) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isHistory ? 'No past bookings' : 'No active sessions',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Colors.grey[850],
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isHistory ? Colors.grey[700] : Colors.blue[50],
                    child: Icon(
                      isHistory ? Icons.history : Icons.local_parking,
                      color: isHistory ? Colors.white70 : Colors.blue,
                    ),
                  ),
                  title: Text('Spot ID: ${item['spot_id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount Paid: \BDT ${item['amount']}', style: const TextStyle(color: Colors.white70)),
                      if (!isHistory) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            CountdownWidget(
                              createdAt: DateTime.parse(item['created_at']),
                              hoursBooked: item['hours'],
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                if (!isHistory)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('RELEASE SPOT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showReleaseDialog(context, item, service),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class CountdownWidget extends StatefulWidget {
  final DateTime createdAt;
  final int hoursBooked;

  const CountdownWidget({super.key, required this.createdAt, required this.hoursBooked});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final expiry = widget.createdAt.add(Duration(hours: widget.hoursBooked));
    if (mounted) {
      setState(() {
        _timeLeft = expiry.difference(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) {
      return const Text("EXPIRED", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    }
    String pads(int n) => n.toString().padLeft(2, '0');
    return Text(
      "${pads(_timeLeft.inHours)}:${pads(_timeLeft.inMinutes.remainder(60))}:${pads(_timeLeft.inSeconds.remainder(60))}",
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
}
