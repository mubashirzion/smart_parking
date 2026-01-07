import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final VehicleService _vehicleService = VehicleService();
  final TextEditingController _regController = TextEditingController();
  String _selectedType = 'car';

  List vehicles = [];

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    final data = await _vehicleService.getVehicles();
    setState(() {
      vehicles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'My Vehicles',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _regController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Registration Number',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: Colors.grey[900],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'bike', child: Text('Bike')),
                        DropdownMenuItem(value: 'car', child: Text('Car')),
                        DropdownMenuItem(value: 'truck', child: Text('Truck')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_regController.text.isEmpty) return;
                          await _vehicleService.addVehicle(
                            regId: _regController.text,
                            type: _selectedType,
                          );
                          _regController.clear();
                          await loadVehicles();
                        },
                        child: const Text('Add Vehicle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            vehicles.isEmpty
                ? const Text('No vehicles added yet.',
                    style: TextStyle(color: Colors.white70))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car, color: Colors.lightGreen),
                          title: Text(vehicle['reg_id'], style: const TextStyle(color: Colors.white)),
                          subtitle: Text(vehicle['type'], style: const TextStyle(color: Colors.white70)),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
