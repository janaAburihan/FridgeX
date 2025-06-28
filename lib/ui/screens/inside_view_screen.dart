import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:FridgeX/ui/widgets/app_drawer.dart';

class InsideViewScreen extends StatefulWidget {
  const InsideViewScreen({Key? key}) : super(key: key);

  @override
  State<InsideViewScreen> createState() => _FridgeInsideViewScreenState();
}

class _FridgeInsideViewScreenState extends State<InsideViewScreen> {
  String? _fridgeImageBase64;
  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchFridgeImage();
  }

  Future<void> _fetchFridgeImage() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final response = await http.get(Uri.parse('http://192.168.10.149:5000/inside-view'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _fridgeImageBase64 = data['image'];
          });
        } else {
          setState(() {
            _isError = true;
          });
        }
      } else {
        setState(() {
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Fridge Inside View'),
        backgroundColor: const Color(0xFF78B298),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _isError
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Failed to load fridge image.',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchFridgeImage,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : _fridgeImageBase64 != null
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width, // Full screen width
                                //height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
                                child: Image.memory(
                                  base64Decode(_fridgeImageBase64!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _fetchFridgeImage,
                                child: const Text('Refresh Photo'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Text('No image available.'),
      ),
    );
  }
}
