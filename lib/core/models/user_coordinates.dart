class UserCoordinates {
  const UserCoordinates({required this.latitude, required this.longitude});

  final String latitude;
  final String longitude;

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory UserCoordinates.fromJson(Map<String, dynamic> json) {
    return UserCoordinates(
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
    );
  }
}
