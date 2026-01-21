import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../controllers/transaksi_controller.dart';
import '../models/transaksi.dart';

class TransaksiView extends StatefulWidget {
  const TransaksiView({super.key});

  @override
  State<TransaksiView> createState() => _TransaksiViewState();
}

class _TransaksiViewState extends State<TransaksiView> {
  late Future<List<Transaksi>> futureTransaksi;
  final TransaksiService _service = TransaksiService();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    futureTransaksi = _service.getTransaksi();
  }

  void _refreshData() {
    setState(() {
      futureTransaksi = _service.getTransaksi();
    });
  }

  Future<void> generatePdf(List<Transaksi> transaksiList) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Data Transaksi', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['No', 'ID Keranjang', 'Status', 'Waktu Pesan', 'Waktu Bayar'],
                data: transaksiList.asMap().entries.map((entry) {
                  return [
                    (entry.key + 1).toString(),
                    entry.value.idKeranjang.toString(),
                    entry.value.statusText,
                    entry.value.waktuPesan,
                    entry.value.waktuBayar != null 
                        ? entry.value.waktuBayar! 
                        : '-',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _showForm(BuildContext context, {Transaksi? transaksi}) {
    final isEdit = transaksi != null;
    final idKeranjangController = TextEditingController(
      text: transaksi?.idKeranjang.toString() ?? '',
    );
    int selectedStatus = transaksi?.status ?? 0;
    String selectedWaktuPesan = transaksi?.waktuPesan ?? '';
    String? selectedWaktuBayar = transaksi?.waktuBayar;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Ubah Transaksi' : 'Tambah Transaksi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idKeranjangController,
                      decoration: const InputDecoration(labelText: 'ID Keranjang'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Pending')),
                        DropdownMenuItem(value: 1, child: Text('Selesai')),
                        DropdownMenuItem(value: 2, child: Text('Dibatalkan')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: selectedWaktuPesan),
                      decoration: const InputDecoration(
                        labelText: 'Waktu Pesan',
                        helperText: 'YYYY-MM-DD HH:MM',
                      ),
                      onChanged: (value) {
                        selectedWaktuPesan = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: selectedWaktuBayar),
                      decoration: const InputDecoration(
                        labelText: 'Waktu Bayar',
                        helperText: 'YYYY-MM-DD HH:MM (Kosongkan jika belum)',
                      ),
                      onChanged: (value) {
                        selectedWaktuBayar = value.isEmpty ? null : value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    final newTransaksi = Transaksi(
                      id: transaksi?.id,
                      idKeranjang: int.parse(idKeranjangController.text),
                      status: selectedStatus,
                      waktuPesan: selectedWaktuPesan,
                      waktuBayar: selectedWaktuBayar,
                    );

                    if (isEdit) {
                      _service.updateTransaksi(transaksi.id!, newTransaksi).then((_) {
                        Navigator.of(context).pop();
                        _refreshData();
                      });
                    } else {
                      _service.createTransaksi(newTransaksi).then((_) {
                        Navigator.of(context).pop();
                        _refreshData();
                      });
                    }
                  },
                  child: Text(isEdit ? 'Ubah' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTransaksi(int id) async {
    await _service.deleteTransaksi(id);
    _refreshData();
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Transaksi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final transaksiList = await _service.getTransaksi();
              generatePdf(transaksiList);
            },
            tooltip: 'Cetak PDF',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context),
            tooltip: 'Tambah Data',
          ),
        ],
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: futureTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data transaksi'));
          }

          List<Transaksi> transaksiList = snapshot.data!;
          return ListView.builder(
            itemCount: transaksiList.length,
            itemBuilder: (context, index) {
              final transaksi = transaksiList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(transaksi.status),
                    child: Text(
                      transaksi.idKeranjang.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    'ID Keranjang: ${transaksi.idKeranjang}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${transaksi.statusText}'),
                      Text('Waktu Pesan: ${transaksi.waktuPesan}'),
                      if (transaksi.waktuBayar != null)
                        Text('Waktu Bayar: ${transaksi.waktuBayar!}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showForm(context, transaksi: transaksi),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTransaksi(transaksi.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
