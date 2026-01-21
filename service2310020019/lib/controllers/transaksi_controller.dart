import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaksi.dart';

class TransaksiService {
  // Gunakan 10.0.2.2 untuk Android Emulator, localhost untuk Web/Desktop
  final String baseUrl = kIsWeb 
      ? 'http://127.0.0.1:8000/api/transaksi' 
      : 'http://10.0.2.2:8000/api/transaksi';

  Future<List<Transaksi>> getTransaksi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Transaksi.fromJson(data)).toList();
    } else {
      throw Exception('Gagal mengambil data transaksi');
    }
  }

  Future<Transaksi> createTransaksi(Transaksi transaksi) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(transaksi.toJson()),
    );

    if (response.statusCode == 201) {
      return Transaksi.fromJson(json.decode(response.body));
    } else {
      if (kDebugMode) {
        print('Failed to create transaction: ${response.statusCode} ${response.body}');
      }
      throw Exception('Gagal menyimpan data transaksi: ${response.body}');
    }
  }

  Future<Transaksi> updateTransaksi(int id, Transaksi transaksi) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(transaksi.toJson()),
    );

    if (response.statusCode == 200) {
      return Transaksi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengubah data transaksi');
    }
  }

  Future<void> deleteTransaksi(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Gagal menghapus data transaksi');
    }
  }
}
