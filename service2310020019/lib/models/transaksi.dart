class Transaksi {
  final int? id;
  final int idKeranjang;
  final int status;
  final String waktuPesan;
  final String? waktuBayar;
  final String? createdAt;
  final String? updatedAt;

  Transaksi({
    this.id,
    required this.idKeranjang,
    required this.status,
    required this.waktuPesan,
    this.waktuBayar,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      idKeranjang: json['id_keranjang'],
      status: json['status'],
      waktuPesan: json['waktu_pesan'],
      waktuBayar: json['waktu_bayar'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_keranjang': idKeranjang,
      'status': status,
      'waktu_pesan': waktuPesan,
      'waktu_bayar': waktuBayar,
    };
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Selesai';
      case 2:
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
}
