import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  final VoidCallback? onOpenBalitaTab;

  const ProfilScreen({super.key, this.onOpenBalitaTab});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final Color _primaryTeal = const Color(0xFF0A7B6C);
  final Color _buttonTeal = const Color(0xFF0BA38E);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textMuted = const Color(0xFF64748B);

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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Dialog Edit Profil Ibu & Balita langsung menyimpan ke Firestore
  void _showEditProfileDialog(
    String uid,
    String currentName,
    String currentPhone,
    String currentChildName,
  ) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final childController = TextEditingController(text: currentChildName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profil Akun',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Orang Tua',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. Handphone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: childController,
              decoration: const InputDecoration(
                labelText: 'Nama Balita',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).set(
                {
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'child_name': childController.text.trim(),
                },
                SetOptions(merge: true),
              );

              if (!mounted) return;
              Navigator.pop(ctx);
              _showFeedback('Profil berhasil diperbarui di Firebase!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
          ],
        ),
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

                // Data orang tua dari Firebase Auth & Firestore
                final String motherName =
                    data['name'] ?? currentUser.displayName ?? 'Ibu Annisa';
                final String email =
                    currentUser.email ?? data['email'] ?? 'annisa@example.com';
                final String phone = data['phone'] ?? '+62 812-3456-7890';

                // Data balita dari Firestore
                final String childName = data['child_name'] ?? 'Ananda Rayyan';
                final String kiaId = data['kms_id'] ?? '#IDAI-2024-8841';
                final String childAge = data['child_age'] ?? '2 Thn 3 Bln';
                final String birthDate =
                    data['child_birth_date'] ?? '15 Okt 2024';
                final String gender = data['child_gender'] ?? 'Laki-laki';
                final String bloodType = data['blood_type'] ?? 'O+';
                final String weight = data['weight'] ?? '12.4';
                final String height = data['height'] ?? '88';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. CARD PROFIL ORANG TUA
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: const Color(0xFFE0F2FE),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: _primaryTeal,
                                        size: 32,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _primaryTeal,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              motherName,
                                              style: TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w800,
                                                color: _textDark,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            Icons.verified_rounded,
                                            color: _primaryTeal,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        phone,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _showEditProfileDialog(
                                    currentUser.uid,
                                    motherName,
                                    phone,
                                    childName,
                                  ),
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: _primaryTeal,
                                  ),
                                  label: Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryTeal,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFECFDF5),
                                    side: BorderSide.none,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: _primaryTeal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Akun Terverifikasi SatuSehat',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _textDark,
                                          ),
                                        ),
                                        Text(
                                          'NIK & Rekam Medis sinkron nasional',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: _primaryTeal,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. HEADER DATA BALITA SAYA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Data Balita Saya',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '1 Anak Terdaftar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. CARD DETAIL BALITA
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFD1FAE5),
                                  child: Icon(
                                    Icons.face_rounded,
                                    color: _primaryTeal,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              childName,
                                              style: TextStyle(
                                                fontSize: 15.5,
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '• Aktif',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: _primaryTeal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'ID KIA: $kiaId',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Usia & Lahir',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: _textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          childAge,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: _textDark,
                                          ),
                                        ),
                                        Text(
                                          birthDate,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Biometrik & Darah',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: _textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          gender,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: _textDark,
                                          ),
                                        ),
                                        Text(
                                          'Golongan $bloodType',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.monitor_weight_outlined,
                                          size: 16,
                                          color: _primaryTeal,
                                        ),
                                        const SizedBox(width: 6),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Berat Badan Terakhir',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: _textMuted,
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: _textDark,
                                                ),
                                                children: [
                                                  TextSpan(text: '$weight kg '),
                                                  TextSpan(
                                                    text: '(Normal)',
                                                    style: TextStyle(
                                                      color: _primaryTeal,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.straighten_rounded,
                                          size: 16,
                                          color: _primaryTeal,
                                        ),
                                        const SizedBox(width: 6),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tinggi Terakhir',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: _textMuted,
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: _textDark,
                                                ),
                                                children: [
                                                  TextSpan(text: '$height cm '),
                                                  TextSpan(
                                                    text: '(Optimal)',
                                                    style: TextStyle(
                                                      color: _primaryTeal,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                if (widget.onOpenBalitaTab != null) {
                                  widget.onOpenBalitaTab!();
                                } else {
                                  _showFeedback(
                                    'Membuka Buku KMS & Grafik Pertumbuhan',
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 17,
                                      color: _primaryTeal,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Buka Buku KMS & Grafik Pertumbuhan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryTeal,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: _primaryTeal,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4. TOMBOL TAMBAH DATA BALITA
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showFeedback('Form Tambah Data Balita diklik'),
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            color: _primaryTeal,
                            size: 20,
                          ),
                          label: Text(
                            'Tambah Data Balita',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _primaryTeal,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEEF2F6),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. CARD INTEGRASI REKAM MEDIS KEMENKES
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.laptop_mac_rounded,
                                    color: _primaryTeal,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Integrasi Rekam Medis Kemenkes',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: _textDark,
                                        ),
                                      ),
                                      Text(
                                        'Platform Nasional SatuSehat',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '✓ Terhubung',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Terakhir sinkron otomatis:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _textMuted,
                                    ),
                                  ),
                                  Text(
                                    'Hari ini, 09:30 WIB',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. PREFERENSI & AKUN
                      Text(
                        'PREFERENSI & AKUN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Pengaturan Notifikasi',
                        subtitle: 'Pengingat H-3, H-1, WhatsApp & Push',
                        onTap: () =>
                            _showFeedback('Membuka Pengaturan Notifikasi'),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Keamanan & Kata Sandi',
                        subtitle: 'Ubah PIN & Biometrik Face ID',
                        onTap: () =>
                            _showFeedback('Membuka Keamanan & Kata Sandi'),
                      ),
                      const SizedBox(height: 20),

                      // 7. DUKUNGAN & INFORMASI
                      Text(
                        'DUKUNGAN & INFORMASI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Pusat Bantuan & FAQ',
                        subtitle: 'Panduan imunisasi IDAI & info klinis',
                        onTap: () => _showFeedback('Membuka Pusat Bantuan'),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuTile(
                        icon: Icons.shield_outlined,
                        title: 'Kebijakan Privasi & Ketentuan',
                        subtitle: 'Keamanan data anak sesuai regulasi',
                        onTap: () => _showFeedback('Membuka Kebijakan Privasi'),
                      ),
                      const SizedBox(height: 10),
                      _buildMenuTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang AkuSehat',
                        subtitle: 'Versi v2.4.0 • Dirancang oleh Rizla Ananda',
                        badgeText: 'Terbaru',
                        onTap: () => _showFeedback('AkuSehat Versi 2.4.0'),
                      ),
                      const SizedBox(height: 16),

                      // 8. TOMBOL KELUAR AKUN (LOGOUT FIREBASE)
                      InkWell(
                        onTap: _logout,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFFD97706),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Keluar Akun',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                    Text(
                                      'Tutup sesi di perangkat ini',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primaryTeal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.5, color: _textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
