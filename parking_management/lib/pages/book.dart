import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final BookingService _bookingService = BookingService();


  int selectedHours = 1;
  List vehicles = [];
  List parkingLots = [];
  Map? selectedVehicle;
  Map? selectedLot;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  // Initial data fetch
  Future<void> _initialLoad() async {
    setState(() => loading = true);
    try {
      final results = await Future.wait([
        _bookingService.getUserVehicles(),
        _bookingService.getParkingLots(),
      ]);
      if (mounted) {
        setState(() {
          vehicles = results[0];
          parkingLots = results[1];
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        _showSnackBar('Failed to load data: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showPaymentSheet() {
    if (selectedVehicle == null || selectedLot == null) {
      _showSnackBar('Please select both a vehicle and a parking lot');
      return;
    }

    const double ratePerHour = 20;
    final double total = selectedHours * ratePerHour;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Summary",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24, height: 30),
            _rowItem("Location", "${selectedLot!['name']}"),
            _rowItem("Vehicle", "${selectedVehicle!['reg_id']}"),
            _rowItem("Duration", "$selectedHours Hours"),
            _rowItem("Rate", "\BDT 20/hr"),
            const SizedBox(height: 10),
            _rowItem("Total Amount", "\TK${total.toStringAsFixed(2)}", isTotal: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  book();
                },
                child: const Text(
                  "CONFIRM & PAY",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> book() async {
    if (selectedVehicle == null || selectedLot == null) return;
    setState(() => loading = true);

    try {
      final spot = await _bookingService.getAvailableSpot(
        parkingLotId: selectedLot!['id'],
        vehicleType: selectedVehicle!['type'],
      );

      if (!mounted) return;

      if (spot == null) {
        setState(() => loading = false);
        _showSnackBar('No available spots for this vehicle type.');
        return;
      }

      await _bookingService.bookSpot(
        vehicleId: selectedVehicle!['id'].toString(),
        spotId: spot['id'].toString(),
        hours: selectedHours,
        vehicleType: selectedVehicle!['type'].toString(),
      );

      if (!mounted) return;
      setState(() => loading = false);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Success', style: TextStyle(color: Colors.white)),
          content: const Text('Parking booked successfully!', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('OK', style: TextStyle(color: Colors.lightGreen)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        _showSnackBar('Booking failed: $e');
      }
    }
  }

  Widget _rowItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: isTotal ? Colors.white : Colors.white70, fontSize: isTotal ? 18 : 14)),
          Text(value,
              style: TextStyle(
                  color: isTotal ? Colors.lightGreen : Colors.white,
                  fontSize: isTotal ? 20 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        title: const Text('Book Parking', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: loading && vehicles.isEmpty
            ? const CircularProgressIndicator(color: Colors.lightGreen)
            : Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Vehicle Details",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Map>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          labelText: 'Select Vehicle',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[900],
                        ),
                        dropdownColor: Colors.grey[900],
                        items: vehicles
                            .map(
                              (v) => DropdownMenuItem<Map>(
                                value: v,
                                child: Text('${v['reg_id']} (${v['type']})', style: const TextStyle(color: Colors.white)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => selectedVehicle = value),
                      ),
                      const SizedBox(height: 16),
                      const Text("Location",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Map>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          labelText: 'Select Parking Lot',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey[900],
                        ),
                        dropdownColor: Colors.grey[900],
                        items: parkingLots
                            .map(
                              (lot) => DropdownMenuItem<Map>(
                                value: lot,
                                child: Text(lot['name'], style: const TextStyle(color: Colors.white)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => selectedLot = value),
                      ),
                      const SizedBox(height: 16),
                      const Text("Duration",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedHours,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[900],
                        ),
                        dropdownColor: Colors.grey[900],
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 Hour', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 2, child: Text('2 Hours', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 5, child: Text('5 Hours', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (value) => setState(() => selectedHours = value!),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : _showPaymentSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text('PROCEED TO PAY',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
