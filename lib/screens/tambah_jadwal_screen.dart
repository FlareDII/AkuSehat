import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef VaccineOption = Map<String, String>;

class TambahJadwalScreen extends StatefulWidget {
  final String initialVaccineName;
  final String initialAgeLabel;

  const TambahJadwalScreen({
    super.key,
    this.initialVaccineName = 'DPT-HB-Hib 3',
    this.initialAgeLabel = 'Lanjutan 18–24 Bulan',
  });

  @override
  State<TambahJadwalScreen> createState() => _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  final Color _primaryTeal = const Color(0xFF0A7B6C);
  final Color _buttonTeal = const Color(0xFF0BA38E);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textMuted = const Color(0xFF64748B);
  final Color _warningText = const Color(0xFFB45309);

  late String _selectedVaccine;
  late String _selectedVaccineSub;
  DateTime _selectedDate = DateTime(2026, 10, 28);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);

  // Interval notifikasi (bisa pilih lebih dari 1)
  final Set<String> _selectedIntervals = {'H-1 Hari'};

  final TextEditingController _faskesController = TextEditingController(
    text: 'Puskesm Kebayoran Baru',
  );
  final TextEditingController _notesController = TextEditingController(
    text: 'Bawa buku KIA kuning, pastikan suhu Rayyan normal & bawa biskuit favorit setelah suntik.',
  );

  bool _isSaving = false;

  final List<VaccineOption> _vaccineOptions = [
    {'name': 'DPT-HB-Hib 3', 'sub': 'Lanjutan 18–24 Bulan'},
    {'name': 'Varisela (Cacar Air)', 'sub': 'Usia 2 Tahun'},
    {'name': 'Campak Rubella (MR) Booster', 'sub': 'Usia 18 Bulan'},
    {'name': 'PCV 3 (Booster)', 'sub': 'Usia 12–15 Bulan'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedVaccine = widget.initialVaccineName.replaceAll(' (Booster)', '');
    _selectedVaccineSub = widget.initialAgeLabel;
  }

  @override
  void dispose() {
    _faskesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showFeedback(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: isError ? Colors.red.shade700 : _textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[date.weekday - 1];
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  String _getTimePeriod(TimeOfDay time) {
    if (time.hour < 11) return 'Pagi Hari';
    if (time.hour < 15) return 'Siang Hari';
    if (time.hour < 18) return 'Sore Hari';
    return 'Malam Hari';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveReminder(String childName) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('reminders')
          .add({
            'child_name': childName,
            'vaccine_name': _selectedVaccine,
            'vaccine_sub': _selectedVaccineSub,
            'date': _formatDate(_selectedDate),
            'time': _formatTime(_selectedTime),
            'intervals': _selectedIntervals.toList(),
            'faskes': _faskesController.text.trim(),
            'notes': _notesController.text.trim(),
            'created_at': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      _showFeedback('Pengingat $_selectedVaccine berhasil disimpan!');
      Navigator.pop(context);
    } catch (e) {
      _showFeedback('Gagal menyimpan pengingat: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                color: _primaryTeal,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Tambah Jadwal Vaksin',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
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
                final String childAge = data['child_age'] ?? '2 tahun';
                final String childGender = data['child_gender'] ?? 'Laki-laki';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER ATUR PENGINGAT IMUNISASI
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBAE6FD),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: _primaryTeal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Atur Pengingat Imunisasi',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Atur alarm dan sinkronisasi otomatis agar jadwal si kecil tetap terjaga.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. PILIH ANAK (OTOMATIS DARI FIREBASE)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRequiredLabel('Pilih Anak'),
                          Text(
                            'Tersedia 2 Profil',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showFeedback('Profil aktif: $childName'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFE0F2FE),
                                child: Icon(
                                  Icons.child_care_rounded,
                                  color: _primaryTeal,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      childName,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    Text(
                                      '$childAge • $childGender',
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
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Aktif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryTeal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. JENIS VAKSIN
                      _buildRequiredLabel('Jenis Vaksin'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showVaccinePicker,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.vaccines_outlined,
                                  color: _primaryTeal,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedVaccine,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    Text(
                                      _selectedVaccineSub,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: _warningText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Wajib untuk imunisasi lanjutan balita (Kemenkes RI)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _warningText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. TANGGAL & WAKTU
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequiredLabel('Tanggal'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickDate,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18,
                                          color: _primaryTeal,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDate(_selectedDate),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: _textDark,
                                              ),
                                            ),
                                            Text(
                                              _formatDayName(_selectedDate),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequiredLabel('Waktu'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickTime,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: _primaryTeal,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatTime(_selectedTime),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: _textDark,
                                              ),
                                            ),
                                            Text(
                                              _getTimePeriod(_selectedTime),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 5. INTERVAL NOTIFIKASI (MULTI-SELECT)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Interval Notifikasi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            'Bisa pilih lebih dari 1',
                            style: TextStyle(fontSize: 11, color: _textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildIntervalChip('H-3 Hari', Icons.alarm_outlined),
                          _buildIntervalChip(
                            'H-1 Hari',
                            Icons.check_circle_rounded,
                          ),
                          _buildIntervalChip(
                            'Hari H (07:00 WIB)',
                            Icons.calendar_today_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 6. FASILITAS KESEHATAN
                      Text(
                        'Fasilitas Kesehatan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _faskesController,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: _primaryTeal,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.my_location_rounded,
                                color: _textMuted,
                                size: 19,
                              ),
                              onPressed: () => _showFeedback(
                                'Mencari Puskesmas terdekat...',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFD97706),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jl. Kerinci VII No.1, Jaksel (1.4 km)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _showFeedback('Membuka lokasi di Maps...'),
                              child: Text(
                                'Buka',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 7. CATATAN TAMBAHAN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Catatan Tambahan (Opsional)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            'Maks. 200 karakter',
                            style: TextStyle(fontSize: 11, color: _textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _notesController,
                          maxLines: 3,
                          maxLength: 200,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _textDark,
                            height: 1.4,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 8. BOX TIPS BUNDA
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              color: _primaryTeal,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: _textMuted,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Tips Bunda: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'Kompres hangat lembut pada area bekas suntikan dan peluk si kecil untuk meredakan rasa gelisah pasca vaksin.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 9. TOMBOL UTAMA SIMPAN PENGINGAT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () => _saveReminder(childName),
                          icon: _isSaving
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.notifications_active_rounded,
                                  size: 20,
                                ),
                          label: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Simpan Pengingat',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Footer Sinkronisasi Kalender
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 14,
                            color: _primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Pengingat lokal otomatis tersinkronisasi ke kalender perangkat Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: _textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _textDark,
        ),
        children: [
          TextSpan(text: '$text '),
          const TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalChip(String label, IconData icon) {
    final bool isActive = _selectedIntervals.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isActive) {
            _selectedIntervals.remove(label);
          } else {
            _selectedIntervals.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _buttonTeal : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle_rounded : icon,
              size: 16,
              color: isActive ? Colors.white : _textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? '$label (Aktif)' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVaccinePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Jenis Vaksin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            ..._vaccineOptions.map(
              (v) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.vaccines_outlined, color: _primaryTeal),
                title: Text(
                  v['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(v['sub']!),
                onTap: () {
                  setState(() {
                    _selectedVaccine = v['name']!;
                    _selectedVaccineSub = v['sub']!;
                  });
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
