enum CommunicationChannel { sms, whatsapp, email, inApp, push }

class CommunicationLog {
  const CommunicationLog({
    required this.id,
    required this.channel,
    required this.templateCode,
    required this.subject,
    required this.body,
    required this.recipientEmployeeIds,
    required this.sentByUserId,
    required this.deliveredCount,
    required this.failedCount,
    required this.sentAt,
  });

  final String id;
  final CommunicationChannel channel;
  final String templateCode;
  final String subject;
  final String body;
  final List<String> recipientEmployeeIds;
  final String sentByUserId;
  final int deliveredCount;
  final int failedCount;
  final DateTime sentAt;

  factory CommunicationLog.fromJson(Map<String, dynamic> json) => CommunicationLog(
        id: json['id'] as String,
        channel: CommunicationChannel.values.byName(json['channel'] as String),
        templateCode: json['templateCode'] as String,
        subject: json['subject'] as String,
        body: json['body'] as String,
        recipientEmployeeIds: (json['recipientEmployeeIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        sentByUserId: json['sentByUserId'] as String,
        deliveredCount: json['deliveredCount'] as int,
        failedCount: json['failedCount'] as int,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel': channel.name,
        'templateCode': templateCode,
        'subject': subject,
        'body': body,
        'recipientEmployeeIds': recipientEmployeeIds,
        'sentByUserId': sentByUserId,
        'deliveredCount': deliveredCount,
        'failedCount': failedCount,
        'sentAt': sentAt.toIso8601String(),
      };

  int get totalRecipients => recipientEmployeeIds.length;
  double get deliveryRate =>
      totalRecipients == 0 ? 0 : deliveredCount / totalRecipients;
}
