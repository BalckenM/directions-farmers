// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'communication_log.freezed.dart';
part 'communication_log.g.dart';

enum CommunicationChannel { sms, whatsapp, email, inApp, push }

@freezed
abstract class CommunicationLog with _$CommunicationLog {
  const CommunicationLog._();

  const factory CommunicationLog({
    required String id,
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
    required int deliveredCount,
    required int failedCount,
    required DateTime sentAt,
  }) = _CommunicationLog;

  factory CommunicationLog.fromJson(Map<String, dynamic> json) =>
      _$CommunicationLogFromJson(json);

  int get totalRecipients => recipientEmployeeIds.length;
  double get deliveryRate =>
      totalRecipients == 0 ? 0 : deliveredCount / totalRecipients;
}
