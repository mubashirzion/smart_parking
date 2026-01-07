import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final _client = Supabase.instance.client;


  Future<void> addVehicle({
    required String regId,
    required String type,
  }) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('vehicles').insert({
      'user_id': userId,
      'reg_id': regId,
      'type': type,
    });
  }

  Future<List<dynamic>> getVehicles() async {
    final userId = _client.auth.currentUser!.id;

    return await _client
        .from('vehicles')
        .select()
        .eq('user_id', userId);
  }
}
