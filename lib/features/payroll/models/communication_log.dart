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

  factory CommunicationLog.fromJson(Map<String, dynamic> json) {
    const channelMap = {
      'sms': 'sms',
      'whatsapp': 'whatsapp',
      'email': 'email',
      'in_app': 'inApp',
      'push': 'push',
    };
    final now = DateTime.now().toIso8601String();
    return _$CommunicationLogFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'channel': channelMap[json['channel']] ?? json['channel'] ?? 'inApp',
      'templateCode': json['template_code'] ?? json['templateCode'] ?? '',
      'recipientEmployeeIds':
          ((json['recipient_employee_ids'] ??
                      json['recipientEmployeeIds'] ??
                      [])
                  as List)
              .map((e) => e.toString())
              .toList(),
      'sentByUserId':
          (json['sent_by_id'] ?? json['sentByUserId'])?.toString() ?? '',
      'deliveredCount':
          json['delivered_count'] as int? ??
          json['deliveredCount'] as int? ??
          0,
      'failedCount':
          json['failed_count'] as int? ?? json['failedCount'] as int? ?? 0,
      'sentAt': json['sent_at'] ?? json['sentAt'] ?? now,
    });
  }

  int get totalRecipients => recipientEmployeeIds.length;
  double get deliveryRate =>
      totalRecipients == 0 ? 0 : deliveredCount / totalRecipients;
}
