import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/airport_model.dart';

class ReservationRouteMapScreen extends StatefulWidget {
  final Airport from;
  final Airport to;
  const ReservationRouteMapScreen({
    super.key,
    required this.from,
    required this.to,
  });

  @override
  State<ReservationRouteMapScreen> createState() =>
      _ReservationRouteMapScreenState();
}

class _ReservationRouteMapScreenState extends State<ReservationRouteMapScreen> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final from = LatLng(widget.from.latitude, widget.from.longitude);
    final to = LatLng(widget.to.latitude, widget.to.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(
        (from.latitude < to.latitude) ? from.latitude : to.latitude,
        (from.longitude < to.longitude) ? from.longitude : to.longitude,
      ),
      northeast: LatLng(
        (from.latitude > to.latitude) ? from.latitude : to.latitude,
        (from.longitude > to.longitude) ? from.longitude : to.longitude,
      ),
    );

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('from'),
        position: from,
        infoWindow: InfoWindow(title: 'Departure', snippet: widget.from.name),
      ),
      Marker(
        markerId: const MarkerId('to'),
        position: to,
        infoWindow: InfoWindow(title: 'Arrival', snippet: widget.to.name),
      ),
    };

    final polylines = <Polyline>{
      const Polyline(
        polylineId: PolylineId('route'),
        width: 5,
        color: Colors.blue,
        points: [],
      ),
    }.map((p) => p.copyWith(pointsParam: [from, to])).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Route on map'), centerTitle: true),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: from, zoom: 6),
        onMapCreated: (c) {
          _controller = c;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 300));
            try {
              await _controller?.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 64),
              );
            } catch (_) {}
          });
        },
        markers: markers,
        polylines: polylines,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
