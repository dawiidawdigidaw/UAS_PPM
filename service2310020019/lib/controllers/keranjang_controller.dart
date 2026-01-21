import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/keranjang.dart';

class KeranjangService {
  // Gunakan 10.0.2.2 untuk Android Emulator, localhost untuk Web/Desktop
  final String baseUrl = kIsWeb 
      ? 'http://127.0.0.1:8000/api/keranjang' 
      : 'http://10.0.2.2:8000/api/keranjang';

  Future<List<Keranjang>> getKeranjang() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Keranjang.fromJson(data)).toList();
    } else {
      throw Exception('Gagal mengambil data keranjang');
    }
  }

  Future<Keranjang> createKeranjang(Keranjang keranjang) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(keranjang.toJson()),
    );

    if (response.statusCode == 201) {
      return Keranjang.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal menyimpan data keranjang');
    }
  }

  Future<Keranjang> updateKeranjang(int id, Keranjang keranjang) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(keranjang.toJson()),
    );

    if (response.statusCode == 200) {
      return Keranjang.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengubah data keranjang');
    }
  }

  Future<void> deleteKeranjang(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus data keranjang');
    }
  }
}
