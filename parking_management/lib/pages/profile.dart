import 'package:flutter/material.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'vehicle.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user data from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    
    final String email = user?.email ?? 'No email found';
    final String name = user?.userMetadata?['full_name'] ?? 'User';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Header
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.lightGreen,
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Profile Options
                _profileTile(
                  icon: Icons.phone,
                  title: 'Phone',
                  subtitle: user?.phone ?? 'Not provided',
                  onTap: () {}, // Optional: add edit phone logic
                ),
                const SizedBox(height: 8),
                _profileTile(
                  icon: Icons.directions_car,
                  title: 'My Vehicles',
                  subtitle: 'Manage your saved cars',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehiclePage()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _profileTile(
                  icon: Icons.history,
                  title: 'Booking History',
                  subtitle: 'View past parking records',
                  onTap: () {
                    // Future: Navigate to HistoryPage()
                  },
                ),
                const SizedBox(height: 40),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'LOGOUT',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for each profile option tile
  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.lightGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }
}
