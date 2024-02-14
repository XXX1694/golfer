// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:dgis_map_kit/src/controllers/dgis_map_controller.dart';
import 'package:dgis_map_platform_interface/dgis_map_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

typedef MapCreatedCallback = void Function(DGisMapController controller);
typedef MapOnReadyCallback = void Function();
typedef MapOnTapCallback = void Function(Position position);
typedef MarkersOnTapCallback = void Function(Marker marker, String? layerId);
typedef OnUserLocationChangedCallback = Marker Function(Position position);
typedef CameraOnMoveCallback = void Function(CameraPosition cameraPosition);

// This is a simple Flutter implementation
// of the 2Gis Map SDK, which enables
// cross-platform map development.
class DGisMap extends StatefulWidget {
  // Base map configuration.
  final MapConfig mapConfig;

  // Map on created callback.
  // Executes when platform view created.
  final MapCreatedCallback? mapOnCreated;

  // Map on ready callback.
  // Executes 2Gis map initiated.
  final MapOnReadyCallback? mapOnReady;

  // Map on tap callback.
  // Triggered when clicking on a
  // location on the map where there are no
  // markers or clusters.
  final MapOnTapCallback? mapOnTap;

  // Marker on tap callback.
  /// Executes when user taps on [Marker].
  final MarkersOnTapCallback? markerOnTap;

  // Enables user location.
  // Initiates "user_location" map layer with user location marker
  final bool enableUserLocation;

  // User location on change callback.
  // Executes when user location updates.
  // Enable only when enableMyLocation is true
  /// Must return [Marker] for view on map
  final OnUserLocationChangedCallback? onUserLocationChanged;

  // Camera on move callback.
  // Executes when camera position updates.
  final CameraOnMoveCallback? cameraOnMove;

  DGisMap({
    super.key,
    required String token,
    required CameraPosition initialCameraPosition,
    List<MapLayer> layers = const [
      MapLayer(),
    ],
    MapTheme theme = MapTheme.LIGHT,
    this.mapOnTap,
    this.markerOnTap,
    this.mapOnReady,
    this.mapOnCreated,
    this.cameraOnMove,
    this.onUserLocationChanged,
    this.enableUserLocation = false,
  }) : mapConfig = MapConfig(
          token: token,
          initialCameraPosition: initialCameraPosition,
          layers: layers,
          theme: theme,
        );

  @override
  State<DGisMap> createState() => _DGisMapState();
}

class _DGisMapState extends State<DGisMap> {
  final Completer<DGisMapController> _controller =
      Completer<DGisMapController>();

  final Completer<bool> isMapReady = Completer<bool>();

  late StreamController<UserLocationChanged> _userLocationStreamController;

  late DGisMapPlatform _dGisMapPlatform;

  @override
  void initState() {
    _dGisMapPlatform = DGisMapPlatform.createInstance(
      mapConfig: widget.mapConfig,
      widgetOptions: const MapWidgetOptions(
        textDirection: TextDirection.ltr,
      ),
    );
    super.initState();
  }

  void _setLocationListeners() async {
    Location location = Location();

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final controller = await _controller.future;

    const userLocationLayerId = "user_location";
    await controller.addLayer(const MapLayer(layerId: userLocationLayerId));

    _userLocationStreamController = StreamController<UserLocationChanged>();
    _userLocationStreamController.stream.listen((event) {
      if (widget.onUserLocationChanged != null) {
        final userMarker = widget.onUserLocationChanged!(event.position);

        controller.markersController.removeAll("user_location");
        controller.markersController.addMarker(
          userMarker,
          userLocationLayerId,
        );
      }
    });

    location.getLocation().then(_userLocationUpdated);

    location.onLocationChanged.listen(_userLocationUpdated);
  }

  void _userLocationUpdated(LocationData currentLocation) {
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      _userLocationStreamController.add(UserLocationChanged(
        position: Position(
          lat: currentLocation.latitude!,
          long: currentLocation.longitude!,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _dGisMapPlatform.buildView(
      onCreated: onPlatformViewCreated,
    );
  }

  Future<void> onPlatformViewCreated() async {
    _setPlatformViewListeners();
    final controller = DGisMapController(
      dGisMapPlatform: _dGisMapPlatform,
      currentCameraPosition: widget.mapConfig.initialCameraPosition,
    );
    _controller.complete(controller);

    if (widget.mapOnCreated != null) {
      widget.mapOnCreated!(controller);
    }
  }

  // Transfers events to callbacks
  void _setPlatformViewListeners() {
    _dGisMapPlatform.on<MapIsReadyEvent>((event) {
      _setLocationListeners();
      if (!isMapReady.isCompleted) {
        if (widget.mapOnReady != null) widget.mapOnReady!();
        isMapReady.complete(true);
      }
    });

    _dGisMapPlatform.on<MapOnTapEvent>((event) {
      if (widget.mapOnTap != null) widget.mapOnTap!(event.position);
    });

    _dGisMapPlatform.on<MarkersOnTapEvent>((event) {
      if (widget.markerOnTap != null) {
        widget.markerOnTap!(event.marker, event.layerId);
      }
    });

    _dGisMapPlatform.on<ClusterOnTapEvent>((event) {
      for (var layer in _dGisMapPlatform.layers) {
        if (layer is ClustererLayer &&
            layer.layerId == event.layerId &&
            layer.onTap != null) {
          layer.onTap!(event.markers, event.layerId);
        }
      }
    });

    _dGisMapPlatform.on<CameraOnMoveEvent>((event) {
      if (widget.cameraOnMove != null) {
        widget.cameraOnMove!(event.cameraPosition);
      }
    });
  }
}
