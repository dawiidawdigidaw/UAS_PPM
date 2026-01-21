class Keranjang {
  final int? id;
  final String meja;
  final String namaPelanggan;
  final String? createdAt;
  final String? updatedAt;

  Keranjang({
    this.id,
    required this.meja,
    required this.namaPelanggan,
    this.createdAt,
    this.updatedAt,
  });

  factory Keranjang.fromJson(Map<String, dynamic> json) {
    return Keranjang(
      id: json['id'],
      meja: json['meja'],
      namaPelanggan: json['nama_pelanggan'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meja': meja,
      'nama_pelanggan': namaPelanggan,
    };
  }
}
