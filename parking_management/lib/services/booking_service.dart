import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final _client = Supabase.instance.client;

Stream<List<Map<String, dynamic>>> getBookingStream() {
  final userId = _client.auth.currentUser!.id;
  return _client
      .from('tokens')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at'); 
}

  Future<List> getUserVehicles() async {
    final userId = _client.auth.currentUser!.id;
    return await _client
        .from('vehicles')
        .select()
        .eq('user_id', userId);
  }


  Future<List> getParkingLots() async {
    return await _client.from('parking_lots').select();
  }


  Future<Map?> getAvailableSpot({
    required String vehicleType,
    required String parkingLotId,
  }) async {
    return await _client
        .from('spots')
        .select()
        .eq('spot_type', vehicleType)
        .eq('parking_lot_id', parkingLotId)
        .eq('status', 'available')
        .limit(1)
        .maybeSingle();
  }


Future<void> bookSpot({
  required String vehicleId,
  required String spotId,
  required int hours,      
  required String vehicleType, 
}) async {
  final userId = _client.auth.currentUser!.id;


  final pricing = await _client
      .from('pricing')
      .select()
      .eq('spot_type', vehicleType)
      .single();

  final amount = pricing['fees_per_hour'] * hours;


  final token = await _client.from('tokens').insert({
    'user_id': userId,
    'vehicle_id': vehicleId,
    'spot_id': spotId,
    'hours': hours,
    'amount': amount,
    'status': 'active',
  }).select().single();


  await _client.from('spots').update({
    'status': 'occupied',
  }).eq('id', spotId);


  await _client.from('token_logs').insert({
    'token_id': token['id'],
    'status': 'booked',
  });
}

Future<void> releaseSpot(String tokenId, String spotId) async {
  try {
    // 1. Update the token status to 'released'
    await _client.from('tokens').update({
      'status': 'released',
    }).eq('id', tokenId);

    // 2. Make the spot available again for other users
    await _client.from('spots').update({
      'status': 'available',
    }).eq('id', spotId);

    // 3. Optional: Log the event
    await _client.from('token_logs').insert({
      'token_id': tokenId,
      'status': 'released',
    });
  } catch (e) {
    print('Error releasing spot: $e');
    rethrow;
  }
}

}