import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'tambah_jadwal_screen.dart';

typedef VaccineItem = Map<String, dynamic>;

class BalitaScreen extends StatefulWidget {
  const BalitaScreen({super.key});

  @override
  State<BalitaScreen> createState() => _BalitaScreenState();
}

class _BalitaScreenState extends State<BalitaScreen> {
  // Filter tab aktif: 0 = Semua, 1 = Selesai, 2 = Belum / Tertunda
  int _selectedFilter = 0;

  final Color _primaryTeal = const Color(0xFF0A7B6C);
  final Color _buttonTeal = const Color(0xFF0BA38E);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textMuted = const Color(0xFF64748B);
  final Color _warningText = const Color(0xFFD97706);
  final Color _warningBg = const Color(0xFFFEF3C7);

  // Daftar riwayat imunisasi sesuai desain mockup
  final List<VaccineItem> _immunizationList = [
    {
      'ageLabel': 'USIA 18 BULAN - 2 TAHUN',
      'name': 'DPT-HB-Hib 3 (Booster)',
      'status': 'Perlu Dijadwalkan',
      'isCompleted': false,
      'date': 'Target Waktu: 28 Okt 2026',
      'location': 'Posyandu Flamboyan /\nPuskesmas',
      'actionType': 'reminder',
    },
    {
      'ageLabel': 'USIA 2 TAHUN',
      'name': 'Varisela (Cacar Air)',
      'status': 'Mendatang',
      'isCompleted': false,
      'date': 'Target: 15 Nov 2026',
      'location': '',
      'actionType': 'info',
    },
    {
      'ageLabel': 'Usia 9 Bulan',
      'name': 'Campak Rubella (MR)',
      'status': 'Selesai',
      'isCompleted': true,
      'date': '20 Jul 2025 • RSUD Kota',
      'batch': 'Batch: MR-2025-09',
    },
    {
      'ageLabel': 'Usia 2 Bulan',
      'name': 'PCV 1',
      'status': 'Selesai',
      'isCompleted': true,
      'date': '16 Des 2024 • Klinik Sehat Bersama',
      'batch': 'Batch: PCV-1102A',
    },
    {
      'ageLabel': 'Usia 2 Bulan',
      'name': 'DPT-HB-Hib 1 & Polio 2',
      'status': 'Selesai',
      'isCompleted': true,
      'date': '16 Des 2024 • Puskesmas Sukamaju',
      'batch': 'Batch: DPT-HIB-881',
    },
    {
      'ageLabel': 'Usia 1 Bulan',
      'name': 'Polio Tetes 1 (OPV 1)',
      'status': 'Selesai',
      'isCompleted': true,
      'date': '12 Nov 2024 • Puskesmas Sukamaju',
      'batch': '',
    },
    {
      'ageLabel': 'Usia 1 Bulan',
      'name': 'BCG',
      'status': 'Selesai',
      'isCompleted': true,
      'date': '12 Nov 2024 • Puskesmas Sukamaju',
      'batch': 'Batch: BCG-4410',
    },
    {
      'ageLabel': 'Usia 0-24 Jam',
      'name': 'Hepatitis B (HB-0)',
      'status': 'Selesai',
      'isCompleted': true,
      'date': '15 Okt 2024 • RS Ibu & Anak Kasih Bunda',
      'batch': 'Batch: HB-9921',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Filter daftar berdasarkan tab yang dipilih
    final List<VaccineItem> filteredList = _immunizationList.where((item) {
      if (_selectedFilter == 1) return item['isCompleted'] == true;
      if (_selectedFilter == 2) return item['isCompleted'] == false;
      return true;
    }).toList();

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
                  'Profile Balita',
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
      ),
      body: currentUser == null
          ? const Center(child: Text('Silakan login terlebih dahulu.'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                Map<String, dynamic> data = {};
                if (snapshot.hasData && snapshot.data!.exists) {
                  data = snapshot.data!.data() as Map<String, dynamic>;
                }

                final String childName = data['child_name'] ?? 'Ananda Rayyan';
                final String childGender = data['child_gender'] ?? 'Laki-laki';
                final String childAge = data['child_age'] ?? '2 Tahun';
                final String birthDate =
                    data['child_birth_date'] ?? '15 Okt 2024';
                final String bloodType = data['blood_type'] ?? 'O+';
                final String weight = data['weight'] ?? '12.4';
                final String height = data['height'] ?? '88';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. CARD PROFIL UTAMA BALITA
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFECFDF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
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
                                  radius: 26,
                                  backgroundColor: const Color(0xFFE0F2FE),
                                  child: Icon(
                                    Icons.child_care_rounded,
                                    color: _primaryTeal,
                                    size: 30,
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
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                color: _textDark,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.verified_rounded,
                                            color: _primaryTeal,
                                            size: 17,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$childGender • $childAge • Lahir: $birthDate',
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricBox(
                                    label: 'Gol. Darah',
                                    value: bloodType,
                                    unit: '',
                                    valueColor: _primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildMetricBox(
                                    label: 'Berat Badan',
                                    value: weight,
                                    unit: 'kg',
                                    valueColor: _textDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildMetricBox(
                                    label: 'Tinggi Badan',
                                    value: height,
                                    unit: 'cm',
                                    valueColor: _textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5).withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 15,
                                        color: _primaryTeal,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '11 Vaksin Selesai • 2 Mendatang',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '85%',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: _primaryTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. FILTER PILLS (Semua, Selesai, Belum / Tertunda)
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip(
                              index: 0,
                              label: 'Semua\n(13)',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip(
                              index: 1,
                              label: 'Selesai\n(11)',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip(
                              index: 2,
                              label: 'Belum / Tertunda\n(2)',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. DAFTAR RIWAYAT & JADWAL VAKSIN
                      ...filteredList.map(
                        (vaccine) => _buildVaccineCard(vaccine),
                      ),

                      const SizedBox(height: 8),

                      // 4. CARD UNDUH BUKU KIA DIGITAL
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_primaryTeal, const Color(0xFF065F46)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Buku KIA Digital',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Unduh sertifikat imunisasi resmi berkode QR untuk administrasi PAUD / TK.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => _showFeedback(
                                'Mengunduh sertifikat Buku KIA Digital...',
                              ),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.download_rounded,
                                  color: _primaryTeal,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildMetricBox({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: _textMuted)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required int index, required String label}) {
    final bool isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? _buttonTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _buttonTeal : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _textDark,
            height: 1.25,
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineCard(VaccineItem vaccine) {
    final bool isCompleted = vaccine['isCompleted'] as bool;
    final Color stripeColor = isCompleted ? _buttonTeal : _warningText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.5, color: stripeColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vaccine['ageLabel'],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? _primaryTeal : _warningText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFFD1FAE5)
                                  : _warningBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.circle,
                                  size: isCompleted ? 12 : 7,
                                  color: isCompleted
                                      ? _primaryTeal
                                      : _warningText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  vaccine['status'],
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted
                                        ? _primaryTeal
                                        : _warningText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        vaccine['name'],
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: isCompleted ? _primaryTeal : _warningText,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              vaccine['date'],
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCompleted &&
                          (vaccine['batch'] as String).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_2_rounded,
                              size: 13,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              vaccine['batch'],
                              style: TextStyle(fontSize: 11, color: _textMuted),
                            ),
                          ],
                        ),
                      ],
                      if (!isCompleted) ...[
                        const SizedBox(height: 10),
                        if (vaccine['actionType'] == 'reminder')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                vaccine['location'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _textMuted,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TambahJadwalScreen(
                                        initialVaccineName: vaccine['name'],
                                        initialAgeLabel: vaccine['ageLabel'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_active_outlined,
                                  size: 15,
                                ),
                                label: const Text(
                                  'Atur\nPengingat',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _buttonTeal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => _showFeedback(
                                'Membuka informasi vaksin ${vaccine['name']}',
                              ),
                              icon: Icon(
                                Icons.info_outline_rounded,
                                size: 15,
                                color: _textDark,
                              ),
                              label: Text(
                                'Lihat Info Vaksin',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
