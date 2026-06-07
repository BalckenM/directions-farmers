// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunicationLog _$CommunicationLogFromJson(Map<String, dynamic> json) =>
    _CommunicationLog(
      id: json['id'] as String,
      channel: $enumDecode(_$CommunicationChannelEnumMap, json['channel']),
      templateCode: json['templateCode'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
      recipientEmployeeIds: (json['recipientEmployeeIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sentByUserId: json['sentByUserId'] as String,
      deliveredCount: (json['deliveredCount'] as num).toInt(),
      failedCount: (json['failedCount'] as num).toInt(),
      sentAt: DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$CommunicationLogToJson(_CommunicationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channel': _$CommunicationChannelEnumMap[instance.channel]!,
      'templateCode': instance.templateCode,
      'subject': instance.subject,
      'body': instance.body,
      'recipientEmployeeIds': instance.recipientEmployeeIds,
      'sentByUserId': instance.sentByUserId,
      'deliveredCount': instance.deliveredCount,
      'failedCount': instance.failedCount,
      'sentAt': instance.sentAt.toIso8601String(),
    };

const _$CommunicationChannelEnumMap = {
  CommunicationChannel.sms: 'sms',
  CommunicationChannel.whatsapp: 'whatsapp',
  CommunicationChannel.email: 'email',
  CommunicationChannel.inApp: 'inApp',
  CommunicationChannel.push: 'push',
};
