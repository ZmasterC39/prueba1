import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(-7.16378, -78.50027);
  final Set<Marker> _markers = {};
  final Set<Marker> _filteredMarkers = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterMarkers);

  }
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://script.googleusercontent.com/a/macros/unc.edu.pe/echo?user_content_key=kHuGhHiPh_KBSnEO2y3A1cRuIoMDX7yguYmCmVPFuccNXZWUemgbrLMOyR0l3Aw3TelnzJ7bl98Ub1h9zHfAFZZowCZWkV_Im5_BxDlH2jW0nuo2oDemN9CCS2h10ox_nRPgeZU6HP_TLDiixwispVRj-G2NbaHUCEgHhxZPJpQ3WDdtCXW6bZ14LJqNP-2BWdKIjUBq7_1ckCCnN-0FL6gqBzMkj-CGwB0qZ_d4XP09FykE6LPVCJ9_Uwiaa41NXMuqa_jo9BU&lib=MVGG1V1y_gbxj3vegL0V6Wn8zz-FOrx0N'));
    final data = jsonDecode(response.body) as List;

    for (var item in data) {
      final marker = Marker(
        markerId: MarkerId(item['Codigo'].toString()),
        position: LatLng(item['Latitud'], item['Longitud']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Codigo: ${item['Codigo']} - Estado: ${item['Estado']}',
          snippet: 'Dirección: ${item['Dirección']}',


        ),
      );

      _markers.add(marker);
    }
    setState(() {
      _filteredMarkers.addAll(_markers);
    });
  }

  void _filterMarkers() {
    final query = _searchController.text;
    setState(() {
      _filteredMarkers.clear();
      for (var marker in _markers) {
        if (marker.infoWindow.snippet!.toLowerCase().contains(query.toLowerCase())) {
          _filteredMarkers.add(marker);
        }
      }
    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fetchData();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Maps'),
          backgroundColor: Colors.green[700],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar dirección',
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                markers: _filteredMarkers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}