import 'package:FlowPhi/features/expense/data/drift/tables/expenses.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'flowphi_db'));

  @override
  int get schemaVersion => 1;
}

/*
tells Drift which tables exist
creates a database named flowphi_db
sets schema version 1
*/
