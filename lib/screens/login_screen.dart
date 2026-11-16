import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  final Color _primaryTeal = const Color(0xFF0A7B6C);
  final Color _buttonTeal = const Color(0xFF0BA38E);
  final Color _inputFill = const Color(0xFFF1F3F9);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textMuted = const Color(0xFF64748B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showActionFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? Colors.red.shade700 : _textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _loginWithFirebase() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showActionFeedback('Email dan kata sandi wajib diisi.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat login.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        errorMessage = 'Email atau kata sandi salah.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Kata sandi yang dimasukkan salah.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Terlalu banyak percobaan gagal. Coba lagi nanti.';
      }
      _showActionFeedback(errorMessage, isError: true);
    } catch (e) {
      _showActionFeedback('Gagal terhubung ke server: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAppLogo(),
              const SizedBox(height: 14),
              Text(
                'AkuSehat',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'TUMBUH KEMBANG & IMUNISASI SI KECIL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 26),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang Ayah & Bunda 👋',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk untuk memantau jadwal imunisasi dan buku KIA/KMS digital si kecil secara terpadu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Email atau No. Handphone',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'KMS & KIA Terdaftar',
                          style: TextStyle(fontSize: 11, color: _textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 14, color: _textDark),
                      decoration: InputDecoration(
                        hintText: 'annisa@example.com atau 0812xxxx',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: _textMuted.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.contact_mail_outlined,
                          color: _textMuted,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: _inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kata Sandi',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(fontSize: 14, color: _textDark),
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: _textMuted.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: _textMuted,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: _inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: _primaryTeal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingat Saya',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showActionFeedback(
                              'Tombol "Lupa Kata Sandi?" diklik',
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginWithFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Masuk ke Akun',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 19),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'ATAU MASUK MELALUI',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          _showActionFeedback(
                            'Tombol "Masuk dengan Google" diklik',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(fontSize: 13.5, color: _textMuted),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showActionFeedback('Tombol "Daftar Sekarang" diklik');
                    },
                    child: Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: _primaryTeal,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data rekam medis imunisasi si kecil tersimpan secara rahasia dan terenkripsi aman sesuai standar interoperabilitas Kemenkes RI.',
                        style: TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: _primaryTeal,
              size: 36,
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF7DD3FC),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.child_care_rounded,
                color: _primaryTeal,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
