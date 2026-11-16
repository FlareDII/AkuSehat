import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profil_screen.dart';
import 'login_screen.dart';
import 'balita_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Color _primaryTeal = const Color(0xFF0A7B6C);
  final Color _buttonTeal = const Color(0xFF0BA38E);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textMuted = const Color(0xFF64748B);
  final Color _warningBg = const Color(0xFFFEF3C7);
  final Color _warningText = const Color(0xFFD97706);

  void _showFeedback(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: _textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman sesuai tab BottomNavigationBar
    final List<Widget> pages = [
      _buildHomeContent(),
      const BalitaScreen(),
      const Center(child: Text('Halaman Notifikasi (Segera Hadir)')),
      ProfilScreen(onOpenBalitaTab: () => setState(() => _selectedIndex = 1)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _primaryTeal,
        unselectedItemColor: _textMuted,
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines_outlined),
            activeIcon: Icon(Icons.vaccines_rounded),
            label: 'Balita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                color: _primaryTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AKUSEHAT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _primaryTeal,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar Akun',
            icon: Icon(Icons.logout_rounded, color: _textMuted, size: 22),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Sesi habis, silakan login ulang.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: _buttonTeal),
                  );
                }

                Map<String, dynamic> data = {};
                if (snapshot.hasData && snapshot.data!.exists) {
                  data = snapshot.data!.data() as Map<String, dynamic>;
                }

                final String motherName =
                    data['name'] ?? currentUser.displayName ?? 'Ayah & Bunda';
                final String childName =
                    data['child_name'] ?? 'Belum ada data balita';
                final String childAge = data['child_age'] ?? '-';
                final String kmsId = data['kms_id'] ?? '#AS-0000-000';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $motherName 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantau kesehatan buah hati Anda bersama AkuSehat',
                        style: TextStyle(fontSize: 13, color: _textMuted),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE0F2FE),
                              child: Icon(
                                Icons.child_care_rounded,
                                color: _primaryTeal,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          childName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: _textDark,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD1FAE5),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          childAge,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _primaryTeal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 13,
                                        color: _primaryTeal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'KMS ID: $kmsId',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  _showFeedback('Ganti profil balita diklik'),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.unfold_more_rounded,
                                  color: _textDark,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _warningBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.notifications_active_outlined,
                                        size: 13,
                                        color: _warningText,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'MENDATANG / SEGERA',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: _warningText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Dalam 5 Hari',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: _warningText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'DPT-HB-Hib 3',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  ),
                                ),
                                Text(
                                  'Dosis ke-3',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Usia Rekomendasi: 18 Bulan / Booster Lanjutan',
                              style: TextStyle(fontSize: 12, color: _textMuted),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 15,
                                        color: _primaryTeal,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kamis, 28 Okt 2026 • 09:00 WIB',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_hospital_outlined,
                                        size: 15,
                                        color: _primaryTeal,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Puskesmas Sukamaju (Dr. Siti Rahma, Sp.A)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _textMuted,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showFeedback('Pengingat kalender diatur!'),
                                icon: const Icon(
                                  Icons.alarm_add_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Atur Pengingat Kalender',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _buttonTeal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.verified_outlined,
                                    size: 18,
                                    color: _primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Kelengkapan Imunisasi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  '85%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: 0.85,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _buttonTeal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '11 dari 13 Vaksin Wajib Selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textMuted,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedIndex = 1),
                                  child: Text(
                                    'Lihat detail →',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Layanan Cepat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            'Semua Fitur',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickService(
                              icon: Icons.vaccines_outlined,
                              bgColor: const Color(0xFFD1FAE5),
                              iconColor: _primaryTeal,
                              title: 'Balita',
                              subtitle: 'KMS Digital',
                              onTap: () => setState(() => _selectedIndex = 1),
                            ),
                            _buildQuickService(
                              icon: Icons.calendar_month_outlined,
                              bgColor: const Color(0xFFFEF3C7),
                              iconColor: _warningText,
                              title: 'Jadwal',
                              subtitle: 'Alarm & Kalender',
                              onTap: () => _showFeedback('Menu Jadwal diklik'),
                            ),
                            _buildQuickService(
                              icon: Icons.menu_book_outlined,
                              bgColor: const Color(0xFFE0F2FE),
                              iconColor: const Color(0xFF0284C7),
                              title: 'Vaksinisasi',
                              subtitle: 'Pedoman IDAI',
                              onTap: () =>
                                  _showFeedback('Menu Vaksinisasi diklik'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'UI/UX Designed by Rizla Ananda Taufik',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Versi 2.4.0 • Pediatrik Digital Indonesia',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: _textMuted.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildQuickService({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10.5, color: _textMuted)),
          ],
        ),
      ),
    );
  }
}
