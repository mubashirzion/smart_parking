import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/splash.dart';
Future<void>main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://elexlbtrucairfrhtnlq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsZXhsYnRydWNhaXJmcmh0bmxxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1MDE5NTMsImV4cCI6MjA4MjA3Nzk1M30.pcjAv0ckX9bmIZpoaB3RMPVH8yyfrBRDIN_76Rmuwsc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

    );
  }
}

class VehicleManager extends StatefulWidget {
  const VehicleManager({super.key});

  @override
  State<VehicleManager> createState() => _VehicleManagerState();
}

class _VehicleManagerState extends State<VehicleManager> {
  final _supabase = Supabase.instance.client;
  final _regController = TextEditingController();
  String _selectedType = 'car';
  bool _isSaving = false;

  Future<void> _addVehicle() async {
    if (_regController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('vehicles').insert({
        'user_id': userId,
        'reg_id': _regController.text.trim(),
        'type': _selectedType,
      });
      _regController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle Added Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _regController,
                    decoration: const InputDecoration(labelText: "Registration Number"),
                  ),
                  DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items: ['car', 'bike', 'truck'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _addVehicle,
                    child: _isSaving ? const CircularProgressIndicator() : const Text("Add Vehicle"),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const Text("Your Vehicles", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: StreamBuilder(
            stream: _supabase.from('vehicles').stream(primaryKey: ['id']).eq('user_id', _supabase.auth.currentUser?.id ?? ''),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final vehicles = snapshot.data!;
              return ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final v = vehicles[index];
                  return ListTile(
                    title: Text(v['reg_id']),
                    subtitle: Text(v['type']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _supabase.from('vehicles').delete().eq('id', v['id']);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}