import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/activity_model.dart';
import '../../providers/trip_provider.dart';

class GoogleMapView extends StatefulWidget {
  static const String routeName = '/google-map';

  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  bool _isLoaded = false;
  GoogleMapController? _controller;
  late Activity _activity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded) return;
    final arguments =
        ModalRoute.of(context)!.settings.arguments! as Map<String, String>;
    _activity = Provider.of<TripProvider>(context, listen: false)
        .getActivityByIds(
          activityId: arguments['activityId']!,
          tripId: arguments['tripId']!,
        );
    _isLoaded = true;
  }

  LatLng get _activityLatLng {
    return LatLng(
      _activity.location!.latitude!,
      _activity.location!.longitude!,
    );
  }

  CameraPosition get _initialCameraPosition {
    return CameraPosition(target: _activityLatLng, zoom: 16.0);
  }

  void _recentrer() {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );
  }

  Future<void> _openUrl() async {
    final adresse = Uri.encodeComponent(_activity.location!.address!);
    final url = Uri.parse('google.navigation:q=$adresse');
    if (!await canLaunchUrl(url)) {
      throw Exception("Aucune application ne sait ouvrir $url");
    }
    if (!await launchUrl(url)) {
      throw Exception("L'ouverture de $url a échoué");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activity.name),
        actions: [
          IconButton(
            onPressed: _recentrer,
            icon: const Icon(Icons.center_focus_strong),
            tooltip: "Recentrer sur l'activité",
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) => _controller = controller,
        markers: {
          Marker(
            markerId: MarkerId(_activity.id!),
            flat: true,
            position: _activityLatLng,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.directions_car),
        onPressed: _openUrl,
        label: const Text('Go'),
      ),
    );
  }
}
