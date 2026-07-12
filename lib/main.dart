import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/data/vault_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await Hive.initFlutter();
  final store = VaultStore();
  await store.initialize();
  runApp(
    ChangeNotifierProvider.value(
      value: store,
      child: const InterviewVaultApp(),
    ),
  );
}
