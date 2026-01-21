import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controllers/keranjang_controller.dart';
import '../models/keranjang.dart';

class KeranjangView extends StatefulWidget {
  const KeranjangView({super.key});

  @override
  State<KeranjangView> createState() => _KeranjangViewState();
}

class _KeranjangViewState extends State<KeranjangView> {
  late Future<List<Keranjang>> futureKeranjang;
  final KeranjangService _service = KeranjangService();

  @override
  void initState() {
    super.initState();
    futureKeranjang = _service.getKeranjang();
  }

  void _refreshData() {
    setState(() {
      futureKeranjang = _service.getKeranjang();
    });
  }

  Future<void> generatePdf(List<Keranjang> keranjangList) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Data Keranjang', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['No', 'Meja', 'Nama Pelanggan'],
                data: keranjangList.asMap().entries.map((entry) {
                  return [
                    (entry.key + 1).toString(),
                    entry.value.meja,
                    entry.value.namaPelanggan,
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

  Future<void> _showForm(BuildContext context, {Keranjang? keranjang}) {
    final isEdit = keranjang != null;
    final mejaController = TextEditingController(text: keranjang?.meja ?? '');
    final namaPelangganController = TextEditingController(text: keranjang?.namaPelanggan ?? '');

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Ubah Keranjang' : 'Tambah Keranjang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mejaController,
                decoration: const InputDecoration(labelText: 'Nomor Meja'),
              ),
              TextField(
                controller: namaPelangganController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final newKeranjang = Keranjang(
                  id: keranjang?.id,
                  meja: mejaController.text,
                  namaPelanggan: namaPelangganController.text,
                );

                if (isEdit) {
                  _service.updateKeranjang(keranjang.id!, newKeranjang).then((_) {
                    Navigator.of(context).pop();
                    _refreshData();
                  });
                } else {
                  _service.createKeranjang(newKeranjang).then((_) {
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
  }

  Future<void> _deleteKeranjang(int id) async {
    await _service.deleteKeranjang(id);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Keranjang'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final keranjangList = await _service.getKeranjang();
              generatePdf(keranjangList);
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
      body: FutureBuilder<List<Keranjang>>(
        future: futureKeranjang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data keranjang'));
          }

          List<Keranjang> keranjangList = snapshot.data!;
          return ListView.builder(
            itemCount: keranjangList.length,
            itemBuilder: (context, index) {
              final keranjang = keranjangList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      keranjang.meja,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    keranjang.namaPelanggan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Meja: ${keranjang.meja}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showForm(context, keranjang: keranjang),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteKeranjang(keranjang.id!),
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
