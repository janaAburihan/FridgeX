import 'package:FridgeX/providers/recipe_provider.dart';
import 'package:FridgeX/ui/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class DoorControlScreen extends StatefulWidget {
  const DoorControlScreen({Key? key}) : super(key: key);

  @override
  State<DoorControlScreen> createState() => _DoorControlScreenState();
}

class _DoorControlScreenState extends State<DoorControlScreen> {
  bool? isDoorOpen;
  bool? isLocked;
  bool isLoading = false;

  final String baseUrl = 'http://192.168.10.149:5000';

  @override
  void initState() {
    super.initState();
    fetchDoorStatus();
    fetchLockStatus();
  }

  Future<void> fetchDoorStatus() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/door-status'));
      final data = jsonDecode(res.body);
      setState(() {
        isDoorOpen = data['door_open'];
      });
    } catch (e) {
      isDoorOpen = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch door status")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLockStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/door-lock-status'));
      final data = jsonDecode(res.body);
      setState(() {
        isLocked = data['locked'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch lock status")),
      );
    }
  }

  Future<void> toggleLockDoor() async {
    if (isLocked == null || isDoorOpen == null || isDoorOpen!) return;

    setState(() => isLoading = true);
    final endpoint = isLocked! ? '/unlock-door' : '/lock-door';

    try {
      final res = await http.post(Uri.parse('$baseUrl$endpoint'));
      if (res.statusCode == 200) {
        setState(() {
          isLocked = !isLocked!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLocked! ? "Door locked" : "Door unlocked")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to toggle lock state")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error toggling lock")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> closeDoor() async {
    setState(() => isLoading = true);
    try {
      final res = await http.post(Uri.parse('$baseUrl/close-door'));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Door closed successfully")),
        );
        fetchDoorStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to close door")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error closing door")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<RecipeClass>(context, listen: false).isDark;

    final statusText = isDoorOpen == null
        ? 'Unknown'
        : isDoorOpen!
            ? 'Open'
            : 'Closed';

    final statusColor = isDoorOpen == null
        ? Colors.grey
        : isDoorOpen!
            ? Colors.red
            : Colors.green;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Door Control'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDoorStatusCard(statusText, statusColor),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: isDoorOpen == true ? closeDoor : null,
                    icon: const Icon(Icons.door_sliding_outlined),
                    label: const Text("Close Door"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed:
                        (isDoorOpen == false && isLocked != null) ? toggleLockDoor : null,
                    icon: Icon(isLocked == true
                        ? Icons.lock_open
                        : Icons.lock_outline),
                    label: Text(
                      isLocked == null
                          ? "Toggle Lock"
                          : isLocked!
                              ? "Unlock Door"
                              : "Lock Door",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton.icon(
                    onPressed: () {
                      fetchDoorStatus();
                      fetchLockStatus();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh Status"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: !isDark ? Colors.black : Colors.white),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDoorStatusCard(String statusText, Color statusColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDoorOpen == null
                ? Icons.help_outline
                : isDoorOpen!
                    ? Icons.door_front_door_outlined
                    : Icons.check_circle_outline,
            color: statusColor,
            size: 40,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Door Status',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
