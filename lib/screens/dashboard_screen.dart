import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/watch_data_service.dart';
import '../services/ml_api_service.dart';
import '../widgets/app_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isMonthly = true; // Toggle for Analysis Tab
  String _predictionResult = "No analysis yet";
  bool _isLoading = false;

  // Controllers for Settings Tab
  final TextEditingController _ageController = TextEditingController(text: "28");
  final TextEditingController _heightController = TextEditingController(text: "178");
  final TextEditingController _weightController = TextEditingController(text: "75");

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _analyzeData() async {
    final watchService = Provider.of<WatchDataService>(context, listen: false);
    final apiService = Provider.of<MLApiService>(context, listen: false);

    if (!watchService.isAuthorized) {
      await watchService.authorize();
    }
    
    setState(() => _isLoading = true);
    await watchService.fetchRecentData();

    if (watchService.healthData.isNotEmpty) {
      final mockPayload = {
        "heart_rate_avg": 75,
        "steps_total": 5000,
        "data_points": watchService.healthData.length
      };

      final result = await apiService.sendDataForPrediction(mockPayload);
      
      setState(() {
        if (result != null) {
          _predictionResult = "Analysis Result: ${result['prediction']}";
        } else {
          _predictionResult = "Error communicating with API.";
        }
      });
    } else {
      setState(() {
         _predictionResult = "No Watch data found in HealthKit.";
      });
    }

    setState(() => _isLoading = false);
  }

  Widget _buildHomeTab() {
    final watchService = Provider.of<WatchDataService>(context);
    final now = DateTime.now();
    final dateStr = "${_getWeekday(now.weekday)}, ${_getMonth(now.month)} ${now.day}";

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      children: [
        // Summary Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ana Ekran',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 25),
        
        // Connected Device Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.watch, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Bağlı Cihaz Durumu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Icon(Icons.close, color: Colors.grey.shade600, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                watchService.isAuthorized 
                  ? 'Apple Sağlık (HealthKit) üzerinden akıllı saat verileriniz başarıyla senkronize ediliyor.'
                  : 'Sistem şu anda sağlık verilerini çekmek için beklemede.',
                style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    watchService.isAuthorized ? 'Bağlı Cihaz: Apple HealthKit' : 'Cihaz Bağlanmadı',
                    style: TextStyle(
                      color: watchService.isAuthorized ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 15),

        // Sleep Score Ring Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Uyku Analizi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 0.85,
                          strokeWidth: 20,
                          backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      const Icon(Icons.nights_stay_rounded, color: Colors.white),
                    ],
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Uyku Skoru', style: TextStyle(fontSize: 18, color: Colors.white)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: const [
                            Flexible(child: Text('85', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent), overflow: TextOverflow.ellipsis)),
                            Text('/100 PUAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Sleep Metrics Grid
        Row(
          children: [
            Expanded(child: _buildMetricCard('Derin Uyku', 'Son Kayıt', '2', 'SA 15 DK', Colors.blueAccent)),
            const SizedBox(width: 15),
            Expanded(child: _buildMetricCard('Dinlenik Nabız', 'Ortalama', '62', 'BPM', Colors.redAccent)),
          ],
        ),
        
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(child: _buildMetricCard('Hareketlilik', 'Uyku İçi', '%12', '', Colors.orangeAccent)),
            const SizedBox(width: 15),
            Expanded(child: Container()), // Empty space to balance the grid, or can add a 4th metric later
          ],
        ),
        
        const SizedBox(height: 120), // Bottom padding for floating nav bar
      ],
    );
  }

  Widget _buildMetricCard(String title, String subtitle, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Icon(Icons.chevron_right, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(child: Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (unit.isNotEmpty) Text(unit, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 15),
          // Mock bar chart area
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(15, (index) => Container(
                width: 3,
                height: (index % 5 + 2) * 5.0,
                color: Colors.grey.shade800,
              )),
            ),
          )
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return "Pazartesi";
      case 2: return "Salı";
      case 3: return "Çarşamba";
      case 4: return "Perşembe";
      case 5: return "Cuma";
      case 6: return "Cumartesi";
      case 7: return "Pazar";
      default: return "";
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1: return "Oca"; case 2: return "Şub"; case 3: return "Mar";
      case 4: return "Nis"; case 5: return "May"; case 6: return "Haz";
      case 7: return "Tem"; case 8: return "Ağu"; case 9: return "Eyl";
      case 10: return "Eki"; case 11: return "Kas"; case 12: return "Ara";
      default: return "";
    }
  }

  Widget _buildDevicesTab() {
    final watchService = Provider.of<WatchDataService>(context);
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cihazlarım',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 36),
              onPressed: () {
                // Future: Open scanning modal
              },
            ),
          ],
        ),
        const SizedBox(height: 25),
        
        // Active HealthKit Sync (System Level)
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: watchService.isAuthorized ? Colors.greenAccent.withOpacity(0.3) : Colors.transparent, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety, color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Apple HealthKit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      watchService.isAuthorized ? 'Senkronize Ediliyor' : 'Bağlı Değil', 
                      style: TextStyle(fontSize: 14, color: watchService.isAuthorized ? Colors.greenAccent : Colors.grey)
                    ),
                  ],
                ),
              ),
              Icon(
                watchService.isAuthorized ? Icons.check_circle : Icons.error_outline,
                color: watchService.isAuthorized ? Colors.greenAccent : Colors.grey,
              )
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        const Text('Kayıtlı Bluetooth Cihazları', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),

        // Mock Bluetooth Device 1
        _buildDeviceCard(
          icon: Icons.watch,
          name: 'Apple Watch Series 8',
          status: 'Bağlı',
          isConnected: true,
        ),
        const SizedBox(height: 15),
        
        // Mock Bluetooth Device 2
        _buildDeviceCard(
          icon: Icons.watch_later_outlined,
          name: 'Xiaomi Mi Band 7',
          status: 'Bağlantı Koptu',
          isConnected: false,
        ),
        const SizedBox(height: 15),

        // Mock Bluetooth Device 3
        _buildDeviceCard(
          icon: Icons.monitor_heart,
          name: 'Polar H10 Kalp Sensörü',
          status: 'Kayıtlı (Yakında Değil)',
          isConnected: false,
        ),

        const SizedBox(height: 120), // Padding for bottom nav bar
      ],
    );
  }

  Widget _buildDeviceCard({required IconData icon, required String name, required String status, required bool isConnected}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(fontSize: 14, color: isConnected ? Colors.blueAccent : Colors.grey)),
              ],
            ),
          ),
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? Colors.blueAccent : Colors.grey.shade600,
          )
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      children: [
        const Text(
          'Analiz Geçmişi',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        
        // Toggle Buttons: Aylık / Yıllık
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMonthly = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isMonthly ? Colors.grey.shade800 : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('Aylık', style: TextStyle(color: _isMonthly ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMonthly = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isMonthly ? Colors.grey.shade800 : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('Yıllık', style: TextStyle(color: !_isMonthly ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        // Mock Graph 1: Uyku Skoru
        _buildMockGraphCard('Uyku Skoru', _isMonthly ? 'Ort. 82 Puan' : 'Ort. 78 Puan', Colors.deepPurpleAccent),
        const SizedBox(height: 15),
        
        // Mock Graph 2: Derin Uyku
        _buildMockGraphCard('Derin Uyku Süresi', _isMonthly ? 'Ort. 2 Sa 10 Dk' : 'Ort. 1 Sa 50 Dk', Colors.blueAccent),
        const SizedBox(height: 15),

        // Mock Graph 3: Dinlenik Nabız
        _buildMockGraphCard('Dinlenik Nabız', _isMonthly ? 'Ort. 64 BPM' : 'Ort. 66 BPM', Colors.redAccent),
        const SizedBox(height: 15),

        // Mock Graph 4: Hareketlilik
        _buildMockGraphCard('Uyku İçi Hareketlilik', _isMonthly ? 'Ort. %14' : 'Ort. %16', Colors.orangeAccent),
        
        const SizedBox(height: 120), // Padding for bottom nav bar
      ],
    );
  }

  Widget _buildMockGraphCard(String title, String subtitle, Color color) {
    // Generate random-looking bar heights based on the current toggle
    final barCount = _isMonthly ? 12 : 6; 
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 25),
          // Mock Bar Chart
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(barCount, (index) {
                // Pseudo-random height for visual variety
                final heightMultiplier = ((index * 13) % 10 + 4) * 6.0;
                return Container(
                  width: _isMonthly ? 12 : 25,
                  height: heightMultiplier,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          // X-Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _isMonthly 
              ? [
                  const Text('1', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Text('15', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Text('30', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ]
              : [
                  const Text('Oca', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Text('Haz', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Text('Ara', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
          )
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      children: [
        const Text(
          'Profil ve Ayarlar',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 25),
        
        const Text('KİŞİSEL BİLGİLER', style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildSettingsInputRow('Yaş', 'Yıl', _ageController),
              Divider(height: 1, color: Colors.grey.shade800, indent: 20, endIndent: 20),
              _buildSettingsInputRow('Boy', 'cm', _heightController),
              Divider(height: 1, color: Colors.grey.shade800, indent: 20, endIndent: 20),
              _buildSettingsInputRow('Kilo', 'kg', _weightController),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            // Dismiss keyboard
            FocusScope.of(context).unfocus();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil bilgileri güncellendi!')),
            );
          },
          child: const Text('Bilgileri Kaydet', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 35),
        const Text('UYGULAMA AYARLARI', style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
              Divider(height: 1, color: Colors.grey.shade800, indent: 20, endIndent: 20),
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: Colors.white),
                title: const Text('Gizlilik ve Güvenlik', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
              Divider(height: 1, color: Colors.grey.shade800, indent: 20, endIndent: 20),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.white),
                title: const Text('Yardım ve Destek', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 120), // Padding for bottom nav bar
      ],
    );
  }

  Widget _buildSettingsInputRow(String label, String unit, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(unit, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildAnalysisTab(),
            _buildDevicesTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_rounded, 0),
              _buildNavItem(Icons.trending_up_rounded, 1),
              _buildNavItem(Icons.watch_rounded, 2),
              _buildNavItem(Icons.settings_rounded, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black.withOpacity(0.05) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.black : Colors.grey.shade400,
        ),
      ),
    );
  }
}
