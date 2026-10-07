import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DangerWorldSecurityApp());
}

class DangerWorldSecurityApp extends StatelessWidget {
  const DangerWorldSecurityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danger World Security',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.red[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.red.shade900,
          secondary: Colors.redAccent,
          surface: const Color(0xFF121212),
          background: Colors.black,
        ),
        fontFamily: 'monospace',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLocked = true;
  String _pinInput = '';
  final String _correctPin = '1984'; // Default security PIN

  // Panic Button State
  bool _isPanicActive = false;
  int _panicCountdown = 5;
  Timer? _panicTimer;

  // Radar Animation
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _panicTimer?.cancel();
    super.dispose();
  }

  void _handlePinPress(String value) {
    setState(() {
      if (_pinInput.length < 4) {
        _pinInput += value;
        if (_pinInput.length == 4) {
          if (_pinInput == _correctPin) {
            _isLocked = false;
            _pinInput = '';
          } else {
            HapticFeedback.vibrate();
            _pinInput = '';
          }
        }
      }
    });
  }

  void _triggerPanic() {
    setState(() {
      _isPanicActive = true;
      _panicCountdown = 5;
    });

    _panicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_panicCountdown > 1) {
        setState(() {
          _panicCountdown--;
        });
        HapticFeedback.heavyImpact();
      } else {
        timer.cancel();
        setState(() {
          _isPanicActive = false;
        });
        _showEmergencyDialog();
      }
    });
  }

  void _cancelPanic() {
    _panicTimer?.cancel();
    setState(() {
      _isPanicActive = false;
      _panicCountdown = 5;
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[900],
        title: const Text('🚨 DISTRESS SIGNAL SENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Location data, audio feed, and emergency broadcast have been dispatched to designated contacts and security nodes.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => Navigator.pop(context),
            child: const Text('DISMISS / STAND DOWN', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return _buildLockScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.red[900]),
            const SizedBox(width: 8),
            const Text(
              'DANGER WORLD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.redAccent),
            onPressed: () => setState(() => _isLocked = true),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildLauncherTab(),
          _buildRadarTab(),
          _buildVaultTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'LAUNCHER'),
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'RADAR'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'VAULT'),
        ],
      ),
    );
  }

  Widget _buildLockScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, size: 80, color: Colors.red[900]),
            const SizedBox(height: 16),
            const Text(
              'SYSTEM LOCKED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ENTER SECURITY PIN (1984)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool filled = index < _pinInput.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? Colors.red[900] : Colors.transparent,
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            for (var row in [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['C', '0', '⌫']
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((char) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 65,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.red.shade900, width: 1),
                          ),
                        ),
                        onPressed: () {
                          if (char == 'C') {
                            setState(() => _pinInput = '');
                          } else if (char == '⌫') {
                            if (_pinInput.isNotEmpty) {
                              setState(() => _pinInput = _pinInput.substring(0, _pinInput.length - 1));
                            }
                          } else {
                            _handlePinPress(char);
                          }
                        },
                        child: Text(char, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLauncherTab() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade900),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('DEFCON 2', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('Perimeter Secure • Encrypted', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Icon(Icons.warning_amber_rounded, color: Colors.red[900], size: 36),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('SECURE MODULES', style: TextStyle(color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildModuleCard(Icons.mic, 'Audio Sweep', 'Detect bugs'),
                    _buildModuleCard(Icons.wifi_lock, 'Signal Shield', 'Jam trackers'),
                    _buildModuleCard(Icons.camera_alt, 'Optic Sweep', 'Find lenses'),
                    _buildModuleCard(Icons.bolt, 'Kill Switch', 'Wipe system'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ).wrap(
                  GestureDetector(
                    onLongPress: _triggerPanic,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                      onPressed: _triggerPanic,
                      child: const Text(
                        'HOLD FOR PANIC ALARM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isPanicActive)
          Container(
            color: Colors.black.withOpacity(0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('DISPATCHING SOS IN', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                  const SizedBox(height: 20),
                  Text('$_panicCountdown', style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: _cancelPanic,
                    child: const Text('CANCEL PANIC', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModuleCard(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade900.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.redAccent, size: 32),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('THREAT RADAR ACTIVE', style: TextStyle(color: Colors.redAccent, letterSpacing: 2)),
          const SizedBox(height: 40),
          SizedBox(
            width: 280,
            height: 280,
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return CustomPaint(
                  painter: RadarPainter(_radarController.value),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          const Text('0 Threats Detected', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVaultTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('SECURE VAULT', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildVaultItem('Encrypted Notes', '12 items stored'),
        _buildVaultItem('Secure Credentials', '34 passwords locked'),
        _buildVaultItem('Hidden Media', '0 files'),
        _buildVaultItem('Emergency Contacts', '3 nodes active'),
      ],
    );
  }

  Widget _buildVaultItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade900.withOpacity(0.4)),
      ),
      child: ListTile(
        leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {},
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;

  RadarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintCircle = Paint()
      ..color = Colors.red.shade900.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw grid circles
    canvas.drawCircle(center, radius * 0.33, paintCircle);
    canvas.drawCircle(center, radius * 0.66, paintCircle);
    canvas.drawCircle(center, radius, paintCircle);

    // Crosshairs
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paintCircle);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paintCircle);

    // Sweep Line
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 3.14 * 2,
        colors: [Colors.transparent, Colors.red.shade900],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animationValue * 6.28);
    canvas.translate(-center.dx, -center.dy);

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0, 1.57, false)
      ..close();

    canvas.drawPath(path, sweepPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

extension on ButtonStyle {
  Widget wrap({required Widget child}) {
    return child;
  }
}