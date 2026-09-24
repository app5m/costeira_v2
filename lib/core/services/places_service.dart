import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/utils/app_logger.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.description,
    this.latitude,
    this.longitude,
    this.distanceMeters,
  });

  final String description;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
}

class PlacesService {
  PlacesService(this._locationService, {ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final LocationService _locationService;
  final ApiClient _client;

  bool get isEnabled => true;

  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    final input = query.trim();
    if (input.length < 3) {
      return const [];
    }

    try {
      final coords = await _locationService.getCurrentCoordinates();
      final latitude = double.tryParse(coords?.latitude ?? '');
      final longitude = double.tryParse(coords?.longitude ?? '');
      if (latitude == null || longitude == null) {
        AppLogger.error('PLACES SERVICE: SEM COORDENADAS PARA BUSCA ENDERECO');
        return const [];
      }

      final response = await _client.post(
        WSConstantes.usuariosBuscaEndereco,
        data: {
          'end_busca': input,
          'latitude': latitude,
          'longitude': longitude,
          'token': WSConstantes.token,
        },
      );

      return responseAsList(response)
          .map(_fromJson)
          .where((item) => item.description.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      AppLogger.error('PLACES SERVICE: BUSCA ENDERECO ERROR=$error');
      return const [];
    }
  }

  Future<String?> details(String address) async {
    final value = address.trim();
    return value.isEmpty ? null : value;
  }

  PlaceSuggestion _fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      description: json['end_completo']?.toString().trim() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      distanceMeters: double.tryParse(json['distance_meters']?.toString() ?? ''),
    );
  }
}
