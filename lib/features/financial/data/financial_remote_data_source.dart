import 'package:dio/dio.dart';

import '../models/financial_transaction.dart';
import 'financial_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class FinancialRemoteDataSource implements FinancialDataSource {
  FinancialRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<FinancialTransaction>> getFinancialTransactions() async {
    final res = await _dio.get('/financial');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => FinancialTransaction.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addFinancialTransaction(FinancialTransaction transaction) async {
    await _dio.post('/financial', data: transaction.toJson());
  }
}
