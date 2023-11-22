class OnibusModel {
  List<BusModel> results = [];

  OnibusModel(this.results);

  OnibusModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <BusModel>[];
      json['results'].forEach((v) {
        results.add(BusModel.fromJson(v));
      });
    }
  }

  OnibusModel.fromJsonUnico(Map<String, dynamic> json) {
    results = <BusModel>[];
    results.add(BusModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['results'] = results.map((v) => v.toJson()).toList();
      return data;
  }
}

class BusModel {
  String objectId = "";
  String latitude = "";
  String longitude = "";
  String data = "";
  String hora = "";


  BusModel(
      this.objectId,
      this.latitude,
      this.longitude,
      this.data,
      this.hora);

  BusModel.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    data = json['data'];
    hora = json['hora'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['objectId'] = this.objectId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['data'] = this.data;
    data['hora'] = this.hora;
    return data;
  }

  Map<String, dynamic> toJsonEndpoint() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectId'] = this.objectId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['data'] = this.data;
    data['hora'] = this.hora;
    return data;
  }
}
