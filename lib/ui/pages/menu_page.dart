import 'package:financial_records/models/catatan.dart';
import 'package:financial_records/shared/separator.dart';
import 'package:financial_records/shared/shared_methods.dart';
import 'package:financial_records/shared/shared_preferences.dart';
import 'package:financial_records/shared/theme.dart';
import 'package:financial_records/ui/widgets/history_transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<Catatan>> _catatanFuture;
  @override
  void initState() {
    super.initState();
    _catatanFuture = readCatatan();
  }

  Future<List<Catatan>> readCatatan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String catatanString = prefs.getString('catatan_key') ?? '';
    if (catatanString.isNotEmpty) {
      return Catatan.decode(catatanString);
    }
    return [];
  }

  Future<void> _deleteCatatan(String idToDelete) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String catatanString = prefs.getString('catatan_key') ?? '';

    if (catatanString.isNotEmpty) {
      List<Catatan> currentCatatan = Catatan.decode(catatanString);

      Catatan? deletedCatatan;
      int deletedIndex =
          currentCatatan.indexWhere((catatan) => catatan.id == idToDelete);

      if (deletedIndex != -1) {
        deletedCatatan = currentCatatan[deletedIndex];
        currentCatatan.removeAt(deletedIndex);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi tidak ditemukan.')),
        );
        return;
      }

      final String encodeData = Catatan.encode(currentCatatan);
      await prefs.setString('catatan_key', encodeData);

      if (deletedCatatan != null) {
        int currentSaldo = await SharedPrefUtils.readSaldo();
        int currentPemasukan = await SharedPrefUtils.readPemasukan();
        int currentPengeluaran = await SharedPrefUtils.readPengeluaran();

        if (deletedCatatan.tipeTransaksi.toString().contains('pengeluaran')) {
          currentSaldo += deletedCatatan.jumlah ?? 0;
          currentPengeluaran -= deletedCatatan.jumlah ?? 0;
        } else {
          currentSaldo -= deletedCatatan.jumlah ?? 0;
          currentPemasukan -= deletedCatatan.jumlah ?? 0;
        }

        await SharedPrefUtils.saveSaldo(currentSaldo);
        await SharedPrefUtils.savePemasukan(currentPemasukan);
        await SharedPrefUtils.savePengeluaran(currentPengeluaran);
      }
      setState(() {
        _catatanFuture = readCatatan();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          buildProfile(context),
          buildWallet(context),
          buildHistory(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          setState(() {
            _catatanFuture = readCatatan();
          });
        },
        backgroundColor: whiteColor,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget buildProfile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 40,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang!',
                style: greyTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              FutureBuilder(
                future: SharedPrefUtils.readNama(),
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data}',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: semiBold,
                    ),
                  );
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: FutureBuilder(
              future: SharedPrefUtils.readNameImage(),
              builder: (context, snapshot) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: snapshot.data == null
                          ? const AssetImage('assets/image-1.png')
                          : AssetImage('assets/${snapshot.data}.png'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWallet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/img_bg_card.png'),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo',
              style: whiteTextStyle,
            ),
            FutureBuilder(
              future: SharedPrefUtils.readSaldo(),
              builder: (context, snapshot) {
                return Text(
                  '${formatCurrency(snapshot.data)}',
                  style: whiteTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: semiBold,
                  ),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Separator(
              color: Colors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemasukan',
                      style: whiteTextStyle,
                    ),
                    FutureBuilder(
                      future: SharedPrefUtils.readPemasukan(),
                      builder: (context, snapshot) {
                        return Text(
                          '${formatCurrency(snapshot.data)}',
                          style: whiteTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        );
                      },
                    )
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran',
                      style: whiteTextStyle,
                    ),
                    FutureBuilder(
                      future: SharedPrefUtils.readPengeluaran(),
                      builder: (context, snapshot) {
                        return Text(
                          formatCurrency(snapshot.data),
                          style: whiteTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistory(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histori Transaksi',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(22),
            margin: const EdgeInsets.only(
              top: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: FutureBuilder<List<Catatan>>(
              future: _catatanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final catatan = snapshot.data!.elementAt(index);
                      return HistoryTransactionItem(
                        iconUrl: catatan.tipeTransaksi.toString() == 'pemasukan'
                            ? 'assets/transaksi_pemasukan.png'
                            : 'assets/transaksi_pengeluaran.png',
                        title: catatan.kategori.toString(),
                        date: catatan.tanggal.toString(),
                        value: catatan.tipeTransaksi.toString() == 'pemasukan'
                            ? '+ ${formatCurrency(catatan.jumlah, symbol: '')}'
                            : '- ${formatCurrency(catatan.jumlah, symbol: '')}',
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Transaksi?'),
                              content: Text(
                                  'Anda yakin ingin menghapus transaksi "${catatan.kategori}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (catatan.id != null) {
                                      _deleteCatatan(catatan.id!);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'ID transaksi tidak ditemukan.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text('Tidak ada histori transaksi.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
