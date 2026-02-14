import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

const String periodicTaskName = "fetch_field_data_periodic";
const String taskName = "fetchFieldData";

// 1. The callback function must be top-level or static
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background Service: Workmanager Task Started: $task");

    // Initialize services inside the isolate
    final prefs = await SharedPreferences.getInstance();
    final String? cookie = prefs.getString('session_cookie');
    final String? deviceId = prefs.getString('selected_device_id');
    final String? settingsJson = prefs.getString('alert_settings');

    if (cookie == null || deviceId == null || settingsJson == null) {
      print(
          "Background Service: Missing required data (cookie/device/settings). Aborting.");
      return Future.value(false);
    }

    // Parse Settings
    Map<String, dynamic> settings = jsonDecode(settingsJson);

    try {
      print("Background Service: Fetching live data for device $deviceId...");
      // Fetch Live Data
      final response = await http.get(
        Uri.parse('https://gridsphere.in/station/api/live-data/$deviceId'),
        headers: {
          'Cookie': cookie,
          'User-Agent': 'FlutterApp',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Handle API structure flexibility
        final data = (jsonResponse is List)
            ? jsonResponse
            : (jsonResponse['data'] ?? []);

        if (data.isEmpty) {
          print("Background Service: No data returned from API.");
          return Future.value(true);
        }

        final reading = data[0];

        // Check "freshness" to avoid spamming alerts for stale data
        String currentTimestamp = reading['timestamp']?.toString() ?? "";
        String? lastProcessed = prefs.getString('last_background_timestamp');

        if (currentTimestamp.isNotEmpty && currentTimestamp == lastProcessed) {
          print(
              "Background Service: Data is same as last check. Skipping alert.");
          return Future.value(true);
        }

        // Initialize Notification Service in this isolate
        await NotificationService.initialize();

        print("Background Service: Checking thresholds...");
        _checkThreshold(reading, settings, 'temp', 'Air Temperature', '°C', 1);
        _checkThreshold(reading, settings, 'humidity', 'Humidity', '%', 2);
        // Mapped 'surface_humidity' from settings to 'surface_humidity' in API data
        _checkThreshold(
            reading, settings, 'surface_humidity', 'Soil Moisture', '%', 3);
        _checkThreshold(reading, settings, 'rainfall', 'Rainfall', 'mm', 4);
        _checkThreshold(
            reading, settings, 'wind_speed', 'Wind Speed', 'km/h', 5);

        // Update last processed timestamp
        if (currentTimestamp.isNotEmpty) {
          await prefs.setString('last_background_timestamp', currentTimestamp);
        }

        return Future.value(true);
      } else {
        print("Background Service: API Error ${response.statusCode}");
      }
    } catch (e) {
      print("Background Service Error: $e");
      return Future.value(
          false); // Return false to retry if it was a network error
    }

    return Future.value(true);
  });
}

void _checkThreshold(Map<String, dynamic> data, Map<String, dynamic> settings,
    String key, String label, String unit, int notifId) async {
  // Guard clause: setting must exist
  if (!settings.containsKey(key)) return;

  final config = settings[key];
  if (config['enabled'] != true) return;

  // Safe parsing of values
  double value = double.tryParse(data[key].toString()) ?? 0.0;

  // Handle case where API key might differ (e.g. wind vs wind_speed)
  // The 'key' param matches the settings key. If API uses different key, handle logic here.
  // For now assuming 1:1 mapping or handled by caller logic (like wind_speed passed as key).

  double min = double.tryParse(config['min']?.toString() ?? '0.0') ?? 0.0;
  double max = double.tryParse(config['max']?.toString() ?? '1000.0') ?? 1000.0;

  if (value < min) {
    print("Background Service: ALERT: Low $label ($value < $min)");
    await NotificationService.showNotification(
      id: notifId,
      title: 'Low $label Alert! ⚠️',
      body: 'Current $label ($value$unit) is below minimum ($min$unit).',
    );
  } else if (value > max) {
    print("Background Service: ALERT: High $label ($value > $max)");
    await NotificationService.showNotification(
      id: notifId,
      title: 'High $label Alert! 🚨',
      body: 'Current $label ($value$unit) exceeded maximum ($max$unit).',
    );
  }
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode:
          true, // Keep true for testing, change to false for production
    );
    print("Background Service: Initialized");
  }

  static void registerPeriodicTask() {
    print("Background Service: Registering periodic task '$periodicTaskName'");
    Workmanager().registerPeriodicTask(
      periodicTaskName,
      taskName,
      // Minimum interval on Android is 15 minutes
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy.update, // Use update to refresh settings
      initialDelay: const Duration(seconds: 10), // Short delay to start
    );
  }

  static void cancelAll() {
    Workmanager().cancelAll();
    print("Background Service: All tasks cancelled");
  }
}
