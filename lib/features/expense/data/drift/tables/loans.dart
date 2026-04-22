import 'package:drift/drift.dart';

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get personName => text()();
  RealColumn get amount => real()();
  DateTimeColumn get loanDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, returned
  TextColumn get notes => text().nullable()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();
}
