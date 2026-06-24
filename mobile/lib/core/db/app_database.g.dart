// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientMessageIdMeta = const VerificationMeta(
    'clientMessageId',
  );
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
    'client_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderUserIdMeta = const VerificationMeta(
    'senderUserId',
  );
  @override
  late final GeneratedColumn<String> senderUserId = GeneratedColumn<String>(
    'sender_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<bool> isMine = GeneratedColumn<bool>(
    'is_mine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deliveredMeta = const VerificationMeta(
    'delivered',
  );
  @override
  late final GeneratedColumn<bool> delivered = GeneratedColumn<bool>(
    'delivered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("delivered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readByPeerMeta = const VerificationMeta(
    'readByPeer',
  );
  @override
  late final GeneratedColumn<bool> readByPeer = GeneratedColumn<bool>(
    'read_by_peer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read_by_peer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sendFailedMeta = const VerificationMeta(
    'sendFailed',
  );
  @override
  late final GeneratedColumn<bool> sendFailed = GeneratedColumn<bool>(
    'send_failed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("send_failed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _senderLabelMeta = const VerificationMeta(
    'senderLabel',
  );
  @override
  late final GeneratedColumn<String> senderLabel = GeneratedColumn<String>(
    'sender_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewOnceMeta = const VerificationMeta(
    'viewOnce',
  );
  @override
  late final GeneratedColumn<bool> viewOnce = GeneratedColumn<bool>(
    'view_once',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("view_once" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _viewedMeta = const VerificationMeta('viewed');
  @override
  late final GeneratedColumn<bool> viewed = GeneratedColumn<bool>(
    'viewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("viewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaBlobIdMeta = const VerificationMeta(
    'mediaBlobId',
  );
  @override
  late final GeneratedColumn<String> mediaBlobId = GeneratedColumn<String>(
    'media_blob_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaKeyMeta = const VerificationMeta(
    'mediaKey',
  );
  @override
  late final GeneratedColumn<String> mediaKey = GeneratedColumn<String>(
    'media_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaMimeMeta = const VerificationMeta(
    'mediaMime',
  );
  @override
  late final GeneratedColumn<String> mediaMime = GeneratedColumn<String>(
    'media_mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaWidthMeta = const VerificationMeta(
    'mediaWidth',
  );
  @override
  late final GeneratedColumn<int> mediaWidth = GeneratedColumn<int>(
    'media_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaHeightMeta = const VerificationMeta(
    'mediaHeight',
  );
  @override
  late final GeneratedColumn<int> mediaHeight = GeneratedColumn<int>(
    'media_height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaLocalPathMeta = const VerificationMeta(
    'mediaLocalPath',
  );
  @override
  late final GeneratedColumn<String> mediaLocalPath = GeneratedColumn<String>(
    'media_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    clientMessageId,
    conversationId,
    senderUserId,
    body,
    createdAt,
    isMine,
    delivered,
    readByPeer,
    sendFailed,
    senderLabel,
    viewOnce,
    viewed,
    expiresAt,
    mediaType,
    mediaBlobId,
    mediaKey,
    mediaMime,
    mediaWidth,
    mediaHeight,
    mediaLocalPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
        _clientMessageIdMeta,
        clientMessageId.isAcceptableOrUnknown(
          data['client_message_id']!,
          _clientMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_user_id')) {
      context.handle(
        _senderUserIdMeta,
        senderUserId.isAcceptableOrUnknown(
          data['sender_user_id']!,
          _senderUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderUserIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_mine')) {
      context.handle(
        _isMineMeta,
        isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta),
      );
    }
    if (data.containsKey('delivered')) {
      context.handle(
        _deliveredMeta,
        delivered.isAcceptableOrUnknown(data['delivered']!, _deliveredMeta),
      );
    }
    if (data.containsKey('read_by_peer')) {
      context.handle(
        _readByPeerMeta,
        readByPeer.isAcceptableOrUnknown(
          data['read_by_peer']!,
          _readByPeerMeta,
        ),
      );
    }
    if (data.containsKey('send_failed')) {
      context.handle(
        _sendFailedMeta,
        sendFailed.isAcceptableOrUnknown(data['send_failed']!, _sendFailedMeta),
      );
    }
    if (data.containsKey('sender_label')) {
      context.handle(
        _senderLabelMeta,
        senderLabel.isAcceptableOrUnknown(
          data['sender_label']!,
          _senderLabelMeta,
        ),
      );
    }
    if (data.containsKey('view_once')) {
      context.handle(
        _viewOnceMeta,
        viewOnce.isAcceptableOrUnknown(data['view_once']!, _viewOnceMeta),
      );
    }
    if (data.containsKey('viewed')) {
      context.handle(
        _viewedMeta,
        viewed.isAcceptableOrUnknown(data['viewed']!, _viewedMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('media_blob_id')) {
      context.handle(
        _mediaBlobIdMeta,
        mediaBlobId.isAcceptableOrUnknown(
          data['media_blob_id']!,
          _mediaBlobIdMeta,
        ),
      );
    }
    if (data.containsKey('media_key')) {
      context.handle(
        _mediaKeyMeta,
        mediaKey.isAcceptableOrUnknown(data['media_key']!, _mediaKeyMeta),
      );
    }
    if (data.containsKey('media_mime')) {
      context.handle(
        _mediaMimeMeta,
        mediaMime.isAcceptableOrUnknown(data['media_mime']!, _mediaMimeMeta),
      );
    }
    if (data.containsKey('media_width')) {
      context.handle(
        _mediaWidthMeta,
        mediaWidth.isAcceptableOrUnknown(data['media_width']!, _mediaWidthMeta),
      );
    }
    if (data.containsKey('media_height')) {
      context.handle(
        _mediaHeightMeta,
        mediaHeight.isAcceptableOrUnknown(
          data['media_height']!,
          _mediaHeightMeta,
        ),
      );
    }
    if (data.containsKey('media_local_path')) {
      context.handle(
        _mediaLocalPathMeta,
        mediaLocalPath.isAcceptableOrUnknown(
          data['media_local_path']!,
          _mediaLocalPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      clientMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_message_id'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_user_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      isMine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mine'],
      )!,
      delivered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}delivered'],
      )!,
      readByPeer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read_by_peer'],
      )!,
      sendFailed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}send_failed'],
      )!,
      senderLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_label'],
      ),
      viewOnce: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}view_once'],
      )!,
      viewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}viewed'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      ),
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      ),
      mediaBlobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_blob_id'],
      ),
      mediaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_key'],
      ),
      mediaMime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_mime'],
      ),
      mediaWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_width'],
      ),
      mediaHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_height'],
      ),
      mediaLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_local_path'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int localId;

  /// Server envelope id once the message is confirmed; null while only local.
  final String? serverId;

  /// Links an optimistic message to its server echo + outbox entry.
  final String? clientMessageId;
  final String conversationId;
  final String senderUserId;

  /// Decrypted plaintext (or a sentinel like "🔒 Unable to decrypt").
  final String body;

  /// Epoch millis — cheaper to sort/range than DateTime in SQLite.
  final int createdAt;
  final bool isMine;
  final bool delivered;
  final bool readByPeer;
  final bool sendFailed;
  final String? senderLabel;

  /// One-time view; body is wiped locally once opened by the recipient.
  final bool viewOnce;
  final bool viewed;

  /// Disappearing-message expiry (epoch millis); null = never expires.
  final int? expiresAt;

  /// Media attachment metadata (null for plain text). The blob itself lives in
  /// object storage as ciphertext; [mediaKey] decrypts it and is safe here
  /// because the whole DB is encrypted-at-rest.
  final String? mediaType;
  final String? mediaBlobId;
  final String? mediaKey;
  final String? mediaMime;
  final int? mediaWidth;
  final int? mediaHeight;

  /// Decrypted, cached local file path for display (null until downloaded).
  final String? mediaLocalPath;
  const Message({
    required this.localId,
    this.serverId,
    this.clientMessageId,
    required this.conversationId,
    required this.senderUserId,
    required this.body,
    required this.createdAt,
    required this.isMine,
    required this.delivered,
    required this.readByPeer,
    required this.sendFailed,
    this.senderLabel,
    required this.viewOnce,
    required this.viewed,
    this.expiresAt,
    this.mediaType,
    this.mediaBlobId,
    this.mediaKey,
    this.mediaMime,
    this.mediaWidth,
    this.mediaHeight,
    this.mediaLocalPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || clientMessageId != null) {
      map['client_message_id'] = Variable<String>(clientMessageId);
    }
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_user_id'] = Variable<String>(senderUserId);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<int>(createdAt);
    map['is_mine'] = Variable<bool>(isMine);
    map['delivered'] = Variable<bool>(delivered);
    map['read_by_peer'] = Variable<bool>(readByPeer);
    map['send_failed'] = Variable<bool>(sendFailed);
    if (!nullToAbsent || senderLabel != null) {
      map['sender_label'] = Variable<String>(senderLabel);
    }
    map['view_once'] = Variable<bool>(viewOnce);
    map['viewed'] = Variable<bool>(viewed);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<String>(mediaType);
    }
    if (!nullToAbsent || mediaBlobId != null) {
      map['media_blob_id'] = Variable<String>(mediaBlobId);
    }
    if (!nullToAbsent || mediaKey != null) {
      map['media_key'] = Variable<String>(mediaKey);
    }
    if (!nullToAbsent || mediaMime != null) {
      map['media_mime'] = Variable<String>(mediaMime);
    }
    if (!nullToAbsent || mediaWidth != null) {
      map['media_width'] = Variable<int>(mediaWidth);
    }
    if (!nullToAbsent || mediaHeight != null) {
      map['media_height'] = Variable<int>(mediaHeight);
    }
    if (!nullToAbsent || mediaLocalPath != null) {
      map['media_local_path'] = Variable<String>(mediaLocalPath);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientMessageId: clientMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMessageId),
      conversationId: Value(conversationId),
      senderUserId: Value(senderUserId),
      body: Value(body),
      createdAt: Value(createdAt),
      isMine: Value(isMine),
      delivered: Value(delivered),
      readByPeer: Value(readByPeer),
      sendFailed: Value(sendFailed),
      senderLabel: senderLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(senderLabel),
      viewOnce: Value(viewOnce),
      viewed: Value(viewed),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      mediaBlobId: mediaBlobId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaBlobId),
      mediaKey: mediaKey == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaKey),
      mediaMime: mediaMime == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaMime),
      mediaWidth: mediaWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaWidth),
      mediaHeight: mediaHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaHeight),
      mediaLocalPath: mediaLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaLocalPath),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      clientMessageId: serializer.fromJson<String?>(json['clientMessageId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderUserId: serializer.fromJson<String>(json['senderUserId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isMine: serializer.fromJson<bool>(json['isMine']),
      delivered: serializer.fromJson<bool>(json['delivered']),
      readByPeer: serializer.fromJson<bool>(json['readByPeer']),
      sendFailed: serializer.fromJson<bool>(json['sendFailed']),
      senderLabel: serializer.fromJson<String?>(json['senderLabel']),
      viewOnce: serializer.fromJson<bool>(json['viewOnce']),
      viewed: serializer.fromJson<bool>(json['viewed']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
      mediaType: serializer.fromJson<String?>(json['mediaType']),
      mediaBlobId: serializer.fromJson<String?>(json['mediaBlobId']),
      mediaKey: serializer.fromJson<String?>(json['mediaKey']),
      mediaMime: serializer.fromJson<String?>(json['mediaMime']),
      mediaWidth: serializer.fromJson<int?>(json['mediaWidth']),
      mediaHeight: serializer.fromJson<int?>(json['mediaHeight']),
      mediaLocalPath: serializer.fromJson<String?>(json['mediaLocalPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'clientMessageId': serializer.toJson<String?>(clientMessageId),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderUserId': serializer.toJson<String>(senderUserId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<int>(createdAt),
      'isMine': serializer.toJson<bool>(isMine),
      'delivered': serializer.toJson<bool>(delivered),
      'readByPeer': serializer.toJson<bool>(readByPeer),
      'sendFailed': serializer.toJson<bool>(sendFailed),
      'senderLabel': serializer.toJson<String?>(senderLabel),
      'viewOnce': serializer.toJson<bool>(viewOnce),
      'viewed': serializer.toJson<bool>(viewed),
      'expiresAt': serializer.toJson<int?>(expiresAt),
      'mediaType': serializer.toJson<String?>(mediaType),
      'mediaBlobId': serializer.toJson<String?>(mediaBlobId),
      'mediaKey': serializer.toJson<String?>(mediaKey),
      'mediaMime': serializer.toJson<String?>(mediaMime),
      'mediaWidth': serializer.toJson<int?>(mediaWidth),
      'mediaHeight': serializer.toJson<int?>(mediaHeight),
      'mediaLocalPath': serializer.toJson<String?>(mediaLocalPath),
    };
  }

  Message copyWith({
    int? localId,
    Value<String?> serverId = const Value.absent(),
    Value<String?> clientMessageId = const Value.absent(),
    String? conversationId,
    String? senderUserId,
    String? body,
    int? createdAt,
    bool? isMine,
    bool? delivered,
    bool? readByPeer,
    bool? sendFailed,
    Value<String?> senderLabel = const Value.absent(),
    bool? viewOnce,
    bool? viewed,
    Value<int?> expiresAt = const Value.absent(),
    Value<String?> mediaType = const Value.absent(),
    Value<String?> mediaBlobId = const Value.absent(),
    Value<String?> mediaKey = const Value.absent(),
    Value<String?> mediaMime = const Value.absent(),
    Value<int?> mediaWidth = const Value.absent(),
    Value<int?> mediaHeight = const Value.absent(),
    Value<String?> mediaLocalPath = const Value.absent(),
  }) => Message(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    clientMessageId: clientMessageId.present
        ? clientMessageId.value
        : this.clientMessageId,
    conversationId: conversationId ?? this.conversationId,
    senderUserId: senderUserId ?? this.senderUserId,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    isMine: isMine ?? this.isMine,
    delivered: delivered ?? this.delivered,
    readByPeer: readByPeer ?? this.readByPeer,
    sendFailed: sendFailed ?? this.sendFailed,
    senderLabel: senderLabel.present ? senderLabel.value : this.senderLabel,
    viewOnce: viewOnce ?? this.viewOnce,
    viewed: viewed ?? this.viewed,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    mediaType: mediaType.present ? mediaType.value : this.mediaType,
    mediaBlobId: mediaBlobId.present ? mediaBlobId.value : this.mediaBlobId,
    mediaKey: mediaKey.present ? mediaKey.value : this.mediaKey,
    mediaMime: mediaMime.present ? mediaMime.value : this.mediaMime,
    mediaWidth: mediaWidth.present ? mediaWidth.value : this.mediaWidth,
    mediaHeight: mediaHeight.present ? mediaHeight.value : this.mediaHeight,
    mediaLocalPath: mediaLocalPath.present
        ? mediaLocalPath.value
        : this.mediaLocalPath,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderUserId: data.senderUserId.present
          ? data.senderUserId.value
          : this.senderUserId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isMine: data.isMine.present ? data.isMine.value : this.isMine,
      delivered: data.delivered.present ? data.delivered.value : this.delivered,
      readByPeer: data.readByPeer.present
          ? data.readByPeer.value
          : this.readByPeer,
      sendFailed: data.sendFailed.present
          ? data.sendFailed.value
          : this.sendFailed,
      senderLabel: data.senderLabel.present
          ? data.senderLabel.value
          : this.senderLabel,
      viewOnce: data.viewOnce.present ? data.viewOnce.value : this.viewOnce,
      viewed: data.viewed.present ? data.viewed.value : this.viewed,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mediaBlobId: data.mediaBlobId.present
          ? data.mediaBlobId.value
          : this.mediaBlobId,
      mediaKey: data.mediaKey.present ? data.mediaKey.value : this.mediaKey,
      mediaMime: data.mediaMime.present ? data.mediaMime.value : this.mediaMime,
      mediaWidth: data.mediaWidth.present
          ? data.mediaWidth.value
          : this.mediaWidth,
      mediaHeight: data.mediaHeight.present
          ? data.mediaHeight.value
          : this.mediaHeight,
      mediaLocalPath: data.mediaLocalPath.present
          ? data.mediaLocalPath.value
          : this.mediaLocalPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isMine: $isMine, ')
          ..write('delivered: $delivered, ')
          ..write('readByPeer: $readByPeer, ')
          ..write('sendFailed: $sendFailed, ')
          ..write('senderLabel: $senderLabel, ')
          ..write('viewOnce: $viewOnce, ')
          ..write('viewed: $viewed, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaBlobId: $mediaBlobId, ')
          ..write('mediaKey: $mediaKey, ')
          ..write('mediaMime: $mediaMime, ')
          ..write('mediaWidth: $mediaWidth, ')
          ..write('mediaHeight: $mediaHeight, ')
          ..write('mediaLocalPath: $mediaLocalPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    serverId,
    clientMessageId,
    conversationId,
    senderUserId,
    body,
    createdAt,
    isMine,
    delivered,
    readByPeer,
    sendFailed,
    senderLabel,
    viewOnce,
    viewed,
    expiresAt,
    mediaType,
    mediaBlobId,
    mediaKey,
    mediaMime,
    mediaWidth,
    mediaHeight,
    mediaLocalPath,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.clientMessageId == this.clientMessageId &&
          other.conversationId == this.conversationId &&
          other.senderUserId == this.senderUserId &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.isMine == this.isMine &&
          other.delivered == this.delivered &&
          other.readByPeer == this.readByPeer &&
          other.sendFailed == this.sendFailed &&
          other.senderLabel == this.senderLabel &&
          other.viewOnce == this.viewOnce &&
          other.viewed == this.viewed &&
          other.expiresAt == this.expiresAt &&
          other.mediaType == this.mediaType &&
          other.mediaBlobId == this.mediaBlobId &&
          other.mediaKey == this.mediaKey &&
          other.mediaMime == this.mediaMime &&
          other.mediaWidth == this.mediaWidth &&
          other.mediaHeight == this.mediaHeight &&
          other.mediaLocalPath == this.mediaLocalPath);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> localId;
  final Value<String?> serverId;
  final Value<String?> clientMessageId;
  final Value<String> conversationId;
  final Value<String> senderUserId;
  final Value<String> body;
  final Value<int> createdAt;
  final Value<bool> isMine;
  final Value<bool> delivered;
  final Value<bool> readByPeer;
  final Value<bool> sendFailed;
  final Value<String?> senderLabel;
  final Value<bool> viewOnce;
  final Value<bool> viewed;
  final Value<int?> expiresAt;
  final Value<String?> mediaType;
  final Value<String?> mediaBlobId;
  final Value<String?> mediaKey;
  final Value<String?> mediaMime;
  final Value<int?> mediaWidth;
  final Value<int?> mediaHeight;
  final Value<String?> mediaLocalPath;
  const MessagesCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderUserId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isMine = const Value.absent(),
    this.delivered = const Value.absent(),
    this.readByPeer = const Value.absent(),
    this.sendFailed = const Value.absent(),
    this.senderLabel = const Value.absent(),
    this.viewOnce = const Value.absent(),
    this.viewed = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaBlobId = const Value.absent(),
    this.mediaKey = const Value.absent(),
    this.mediaMime = const Value.absent(),
    this.mediaWidth = const Value.absent(),
    this.mediaHeight = const Value.absent(),
    this.mediaLocalPath = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    required String conversationId,
    required String senderUserId,
    required String body,
    required int createdAt,
    this.isMine = const Value.absent(),
    this.delivered = const Value.absent(),
    this.readByPeer = const Value.absent(),
    this.sendFailed = const Value.absent(),
    this.senderLabel = const Value.absent(),
    this.viewOnce = const Value.absent(),
    this.viewed = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaBlobId = const Value.absent(),
    this.mediaKey = const Value.absent(),
    this.mediaMime = const Value.absent(),
    this.mediaWidth = const Value.absent(),
    this.mediaHeight = const Value.absent(),
    this.mediaLocalPath = const Value.absent(),
  }) : conversationId = Value(conversationId),
       senderUserId = Value(senderUserId),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<int>? localId,
    Expression<String>? serverId,
    Expression<String>? clientMessageId,
    Expression<String>? conversationId,
    Expression<String>? senderUserId,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<bool>? isMine,
    Expression<bool>? delivered,
    Expression<bool>? readByPeer,
    Expression<bool>? sendFailed,
    Expression<String>? senderLabel,
    Expression<bool>? viewOnce,
    Expression<bool>? viewed,
    Expression<int>? expiresAt,
    Expression<String>? mediaType,
    Expression<String>? mediaBlobId,
    Expression<String>? mediaKey,
    Expression<String>? mediaMime,
    Expression<int>? mediaWidth,
    Expression<int>? mediaHeight,
    Expression<String>? mediaLocalPath,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderUserId != null) 'sender_user_id': senderUserId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (isMine != null) 'is_mine': isMine,
      if (delivered != null) 'delivered': delivered,
      if (readByPeer != null) 'read_by_peer': readByPeer,
      if (sendFailed != null) 'send_failed': sendFailed,
      if (senderLabel != null) 'sender_label': senderLabel,
      if (viewOnce != null) 'view_once': viewOnce,
      if (viewed != null) 'viewed': viewed,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (mediaType != null) 'media_type': mediaType,
      if (mediaBlobId != null) 'media_blob_id': mediaBlobId,
      if (mediaKey != null) 'media_key': mediaKey,
      if (mediaMime != null) 'media_mime': mediaMime,
      if (mediaWidth != null) 'media_width': mediaWidth,
      if (mediaHeight != null) 'media_height': mediaHeight,
      if (mediaLocalPath != null) 'media_local_path': mediaLocalPath,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? localId,
    Value<String?>? serverId,
    Value<String?>? clientMessageId,
    Value<String>? conversationId,
    Value<String>? senderUserId,
    Value<String>? body,
    Value<int>? createdAt,
    Value<bool>? isMine,
    Value<bool>? delivered,
    Value<bool>? readByPeer,
    Value<bool>? sendFailed,
    Value<String?>? senderLabel,
    Value<bool>? viewOnce,
    Value<bool>? viewed,
    Value<int?>? expiresAt,
    Value<String?>? mediaType,
    Value<String?>? mediaBlobId,
    Value<String?>? mediaKey,
    Value<String?>? mediaMime,
    Value<int?>? mediaWidth,
    Value<int?>? mediaHeight,
    Value<String?>? mediaLocalPath,
  }) {
    return MessagesCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      conversationId: conversationId ?? this.conversationId,
      senderUserId: senderUserId ?? this.senderUserId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      delivered: delivered ?? this.delivered,
      readByPeer: readByPeer ?? this.readByPeer,
      sendFailed: sendFailed ?? this.sendFailed,
      senderLabel: senderLabel ?? this.senderLabel,
      viewOnce: viewOnce ?? this.viewOnce,
      viewed: viewed ?? this.viewed,
      expiresAt: expiresAt ?? this.expiresAt,
      mediaType: mediaType ?? this.mediaType,
      mediaBlobId: mediaBlobId ?? this.mediaBlobId,
      mediaKey: mediaKey ?? this.mediaKey,
      mediaMime: mediaMime ?? this.mediaMime,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
      mediaLocalPath: mediaLocalPath ?? this.mediaLocalPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderUserId.present) {
      map['sender_user_id'] = Variable<String>(senderUserId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<bool>(isMine.value);
    }
    if (delivered.present) {
      map['delivered'] = Variable<bool>(delivered.value);
    }
    if (readByPeer.present) {
      map['read_by_peer'] = Variable<bool>(readByPeer.value);
    }
    if (sendFailed.present) {
      map['send_failed'] = Variable<bool>(sendFailed.value);
    }
    if (senderLabel.present) {
      map['sender_label'] = Variable<String>(senderLabel.value);
    }
    if (viewOnce.present) {
      map['view_once'] = Variable<bool>(viewOnce.value);
    }
    if (viewed.present) {
      map['viewed'] = Variable<bool>(viewed.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mediaBlobId.present) {
      map['media_blob_id'] = Variable<String>(mediaBlobId.value);
    }
    if (mediaKey.present) {
      map['media_key'] = Variable<String>(mediaKey.value);
    }
    if (mediaMime.present) {
      map['media_mime'] = Variable<String>(mediaMime.value);
    }
    if (mediaWidth.present) {
      map['media_width'] = Variable<int>(mediaWidth.value);
    }
    if (mediaHeight.present) {
      map['media_height'] = Variable<int>(mediaHeight.value);
    }
    if (mediaLocalPath.present) {
      map['media_local_path'] = Variable<String>(mediaLocalPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('isMine: $isMine, ')
          ..write('delivered: $delivered, ')
          ..write('readByPeer: $readByPeer, ')
          ..write('sendFailed: $sendFailed, ')
          ..write('senderLabel: $senderLabel, ')
          ..write('viewOnce: $viewOnce, ')
          ..write('viewed: $viewed, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaBlobId: $mediaBlobId, ')
          ..write('mediaKey: $mediaKey, ')
          ..write('mediaMime: $mediaMime, ')
          ..write('mediaWidth: $mediaWidth, ')
          ..write('mediaHeight: $mediaHeight, ')
          ..write('mediaLocalPath: $mediaLocalPath')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerUserIdMeta = const VerificationMeta(
    'peerUserId',
  );
  @override
  late final GeneratedColumn<String> peerUserId = GeneratedColumn<String>(
    'peer_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGroupMeta = const VerificationMeta(
    'isGroup',
  );
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
    'is_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<int> lastAt = GeneratedColumn<int>(
    'last_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPreviewMeta = const VerificationMeta(
    'lastPreview',
  );
  @override
  late final GeneratedColumn<String> lastPreview = GeneratedColumn<String>(
    'last_preview',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    peerUserId,
    title,
    username,
    isGroup,
    groupId,
    lastAt,
    lastPreview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('peer_user_id')) {
      context.handle(
        _peerUserIdMeta,
        peerUserId.isAcceptableOrUnknown(
          data['peer_user_id']!,
          _peerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('last_at')) {
      context.handle(
        _lastAtMeta,
        lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAtMeta);
    }
    if (data.containsKey('last_preview')) {
      context.handle(
        _lastPreviewMeta,
        lastPreview.isAcceptableOrUnknown(
          data['last_preview']!,
          _lastPreviewMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      peerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_user_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      isGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_group'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      lastAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_at'],
      )!,
      lastPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_preview'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String conversationId;
  final String? peerUserId;
  final String? title;
  final String? username;
  final bool isGroup;
  final String? groupId;
  final int lastAt;
  final String lastPreview;
  const Conversation({
    required this.conversationId,
    this.peerUserId,
    this.title,
    this.username,
    required this.isGroup,
    this.groupId,
    required this.lastAt,
    required this.lastPreview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    if (!nullToAbsent || peerUserId != null) {
      map['peer_user_id'] = Variable<String>(peerUserId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['last_at'] = Variable<int>(lastAt);
    map['last_preview'] = Variable<String>(lastPreview);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      conversationId: Value(conversationId),
      peerUserId: peerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(peerUserId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      isGroup: Value(isGroup),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      lastAt: Value(lastAt),
      lastPreview: Value(lastPreview),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      peerUserId: serializer.fromJson<String?>(json['peerUserId']),
      title: serializer.fromJson<String?>(json['title']),
      username: serializer.fromJson<String?>(json['username']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      lastAt: serializer.fromJson<int>(json['lastAt']),
      lastPreview: serializer.fromJson<String>(json['lastPreview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'peerUserId': serializer.toJson<String?>(peerUserId),
      'title': serializer.toJson<String?>(title),
      'username': serializer.toJson<String?>(username),
      'isGroup': serializer.toJson<bool>(isGroup),
      'groupId': serializer.toJson<String?>(groupId),
      'lastAt': serializer.toJson<int>(lastAt),
      'lastPreview': serializer.toJson<String>(lastPreview),
    };
  }

  Conversation copyWith({
    String? conversationId,
    Value<String?> peerUserId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> username = const Value.absent(),
    bool? isGroup,
    Value<String?> groupId = const Value.absent(),
    int? lastAt,
    String? lastPreview,
  }) => Conversation(
    conversationId: conversationId ?? this.conversationId,
    peerUserId: peerUserId.present ? peerUserId.value : this.peerUserId,
    title: title.present ? title.value : this.title,
    username: username.present ? username.value : this.username,
    isGroup: isGroup ?? this.isGroup,
    groupId: groupId.present ? groupId.value : this.groupId,
    lastAt: lastAt ?? this.lastAt,
    lastPreview: lastPreview ?? this.lastPreview,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      peerUserId: data.peerUserId.present
          ? data.peerUserId.value
          : this.peerUserId,
      title: data.title.present ? data.title.value : this.title,
      username: data.username.present ? data.username.value : this.username,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
      lastPreview: data.lastPreview.present
          ? data.lastPreview.value
          : this.lastPreview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('conversationId: $conversationId, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('title: $title, ')
          ..write('username: $username, ')
          ..write('isGroup: $isGroup, ')
          ..write('groupId: $groupId, ')
          ..write('lastAt: $lastAt, ')
          ..write('lastPreview: $lastPreview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    peerUserId,
    title,
    username,
    isGroup,
    groupId,
    lastAt,
    lastPreview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.conversationId == this.conversationId &&
          other.peerUserId == this.peerUserId &&
          other.title == this.title &&
          other.username == this.username &&
          other.isGroup == this.isGroup &&
          other.groupId == this.groupId &&
          other.lastAt == this.lastAt &&
          other.lastPreview == this.lastPreview);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> conversationId;
  final Value<String?> peerUserId;
  final Value<String?> title;
  final Value<String?> username;
  final Value<bool> isGroup;
  final Value<String?> groupId;
  final Value<int> lastAt;
  final Value<String> lastPreview;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.conversationId = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.title = const Value.absent(),
    this.username = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.groupId = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.lastPreview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String conversationId,
    this.peerUserId = const Value.absent(),
    this.title = const Value.absent(),
    this.username = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.groupId = const Value.absent(),
    required int lastAt,
    this.lastPreview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId),
       lastAt = Value(lastAt);
  static Insertable<Conversation> custom({
    Expression<String>? conversationId,
    Expression<String>? peerUserId,
    Expression<String>? title,
    Expression<String>? username,
    Expression<bool>? isGroup,
    Expression<String>? groupId,
    Expression<int>? lastAt,
    Expression<String>? lastPreview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (peerUserId != null) 'peer_user_id': peerUserId,
      if (title != null) 'title': title,
      if (username != null) 'username': username,
      if (isGroup != null) 'is_group': isGroup,
      if (groupId != null) 'group_id': groupId,
      if (lastAt != null) 'last_at': lastAt,
      if (lastPreview != null) 'last_preview': lastPreview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? conversationId,
    Value<String?>? peerUserId,
    Value<String?>? title,
    Value<String?>? username,
    Value<bool>? isGroup,
    Value<String?>? groupId,
    Value<int>? lastAt,
    Value<String>? lastPreview,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      conversationId: conversationId ?? this.conversationId,
      peerUserId: peerUserId ?? this.peerUserId,
      title: title ?? this.title,
      username: username ?? this.username,
      isGroup: isGroup ?? this.isGroup,
      groupId: groupId ?? this.groupId,
      lastAt: lastAt ?? this.lastAt,
      lastPreview: lastPreview ?? this.lastPreview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (peerUserId.present) {
      map['peer_user_id'] = Variable<String>(peerUserId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<int>(lastAt.value);
    }
    if (lastPreview.present) {
      map['last_preview'] = Variable<String>(lastPreview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('title: $title, ')
          ..write('username: $username, ')
          ..write('isGroup: $isGroup, ')
          ..write('groupId: $groupId, ')
          ..write('lastAt: $lastAt, ')
          ..write('lastPreview: $lastPreview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CallHistoryItemsTable extends CallHistoryItems
    with TableInfo<$CallHistoryItemsTable, CallHistoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallHistoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callTypeMeta = const VerificationMeta(
    'callType',
  );
  @override
  late final GeneratedColumn<String> callType = GeneratedColumn<String>(
    'call_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerLabelMeta = const VerificationMeta(
    'peerLabel',
  );
  @override
  late final GeneratedColumn<String> peerLabel = GeneratedColumn<String>(
    'peer_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    callType,
    status,
    startedAt,
    peerLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'call_history_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallHistoryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('call_type')) {
      context.handle(
        _callTypeMeta,
        callType.isAcceptableOrUnknown(data['call_type']!, _callTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_callTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('peer_label')) {
      context.handle(
        _peerLabelMeta,
        peerLabel.isAcceptableOrUnknown(data['peer_label']!, _peerLabelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallHistoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallHistoryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      callType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      peerLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_label'],
      ),
    );
  }

  @override
  $CallHistoryItemsTable createAlias(String alias) {
    return $CallHistoryItemsTable(attachedDatabase, alias);
  }
}

class CallHistoryItem extends DataClass implements Insertable<CallHistoryItem> {
  final String id;
  final String conversationId;
  final String callType;
  final String status;
  final int startedAt;
  final String? peerLabel;
  const CallHistoryItem({
    required this.id,
    required this.conversationId,
    required this.callType,
    required this.status,
    required this.startedAt,
    this.peerLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['call_type'] = Variable<String>(callType);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || peerLabel != null) {
      map['peer_label'] = Variable<String>(peerLabel);
    }
    return map;
  }

  CallHistoryItemsCompanion toCompanion(bool nullToAbsent) {
    return CallHistoryItemsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      callType: Value(callType),
      status: Value(status),
      startedAt: Value(startedAt),
      peerLabel: peerLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(peerLabel),
    );
  }

  factory CallHistoryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallHistoryItem(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      callType: serializer.fromJson<String>(json['callType']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      peerLabel: serializer.fromJson<String?>(json['peerLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'callType': serializer.toJson<String>(callType),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'peerLabel': serializer.toJson<String?>(peerLabel),
    };
  }

  CallHistoryItem copyWith({
    String? id,
    String? conversationId,
    String? callType,
    String? status,
    int? startedAt,
    Value<String?> peerLabel = const Value.absent(),
  }) => CallHistoryItem(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    callType: callType ?? this.callType,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    peerLabel: peerLabel.present ? peerLabel.value : this.peerLabel,
  );
  CallHistoryItem copyWithCompanion(CallHistoryItemsCompanion data) {
    return CallHistoryItem(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      callType: data.callType.present ? data.callType.value : this.callType,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      peerLabel: data.peerLabel.present ? data.peerLabel.value : this.peerLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryItem(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('callType: $callType, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('peerLabel: $peerLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, callType, status, startedAt, peerLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallHistoryItem &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.callType == this.callType &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.peerLabel == this.peerLabel);
}

class CallHistoryItemsCompanion extends UpdateCompanion<CallHistoryItem> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> callType;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<String?> peerLabel;
  final Value<int> rowid;
  const CallHistoryItemsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.callType = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.peerLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CallHistoryItemsCompanion.insert({
    required String id,
    required String conversationId,
    required String callType,
    required String status,
    required int startedAt,
    this.peerLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       callType = Value(callType),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<CallHistoryItem> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? callType,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<String>? peerLabel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (callType != null) 'call_type': callType,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (peerLabel != null) 'peer_label': peerLabel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CallHistoryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? callType,
    Value<String>? status,
    Value<int>? startedAt,
    Value<String?>? peerLabel,
    Value<int>? rowid,
  }) {
    return CallHistoryItemsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      peerLabel: peerLabel ?? this.peerLabel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (callType.present) {
      map['call_type'] = Variable<String>(callType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (peerLabel.present) {
      map['peer_label'] = Variable<String>(peerLabel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallHistoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('callType: $callType, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('peerLabel: $peerLabel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationSettingsTable extends ConversationSettings
    with TableInfo<$ConversationSettingsTable, ConversationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _disappearingSecondsMeta =
      const VerificationMeta('disappearingSeconds');
  @override
  late final GeneratedColumn<int> disappearingSeconds = GeneratedColumn<int>(
    'disappearing_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [conversationId, disappearingSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('disappearing_seconds')) {
      context.handle(
        _disappearingSecondsMeta,
        disappearingSeconds.isAcceptableOrUnknown(
          data['disappearing_seconds']!,
          _disappearingSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  ConversationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationSetting(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      disappearingSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disappearing_seconds'],
      )!,
    );
  }

  @override
  $ConversationSettingsTable createAlias(String alias) {
    return $ConversationSettingsTable(attachedDatabase, alias);
  }
}

class ConversationSetting extends DataClass
    implements Insertable<ConversationSetting> {
  final String conversationId;
  final int disappearingSeconds;
  const ConversationSetting({
    required this.conversationId,
    required this.disappearingSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    map['disappearing_seconds'] = Variable<int>(disappearingSeconds);
    return map;
  }

  ConversationSettingsCompanion toCompanion(bool nullToAbsent) {
    return ConversationSettingsCompanion(
      conversationId: Value(conversationId),
      disappearingSeconds: Value(disappearingSeconds),
    );
  }

  factory ConversationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationSetting(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      disappearingSeconds: serializer.fromJson<int>(
        json['disappearingSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'disappearingSeconds': serializer.toJson<int>(disappearingSeconds),
    };
  }

  ConversationSetting copyWith({
    String? conversationId,
    int? disappearingSeconds,
  }) => ConversationSetting(
    conversationId: conversationId ?? this.conversationId,
    disappearingSeconds: disappearingSeconds ?? this.disappearingSeconds,
  );
  ConversationSetting copyWithCompanion(ConversationSettingsCompanion data) {
    return ConversationSetting(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      disappearingSeconds: data.disappearingSeconds.present
          ? data.disappearingSeconds.value
          : this.disappearingSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationSetting(')
          ..write('conversationId: $conversationId, ')
          ..write('disappearingSeconds: $disappearingSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(conversationId, disappearingSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationSetting &&
          other.conversationId == this.conversationId &&
          other.disappearingSeconds == this.disappearingSeconds);
}

class ConversationSettingsCompanion
    extends UpdateCompanion<ConversationSetting> {
  final Value<String> conversationId;
  final Value<int> disappearingSeconds;
  final Value<int> rowid;
  const ConversationSettingsCompanion({
    this.conversationId = const Value.absent(),
    this.disappearingSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationSettingsCompanion.insert({
    required String conversationId,
    this.disappearingSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId);
  static Insertable<ConversationSetting> custom({
    Expression<String>? conversationId,
    Expression<int>? disappearingSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (disappearingSeconds != null)
        'disappearing_seconds': disappearingSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationSettingsCompanion copyWith({
    Value<String>? conversationId,
    Value<int>? disappearingSeconds,
    Value<int>? rowid,
  }) {
    return ConversationSettingsCompanion(
      conversationId: conversationId ?? this.conversationId,
      disappearingSeconds: disappearingSeconds ?? this.disappearingSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (disappearingSeconds.present) {
      map['disappearing_seconds'] = Variable<int>(disappearingSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationSettingsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('disappearingSeconds: $disappearingSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $CallHistoryItemsTable callHistoryItems = $CallHistoryItemsTable(
    this,
  );
  late final $ConversationSettingsTable conversationSettings =
      $ConversationSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    conversations,
    callHistoryItems,
    conversationSettings,
  ];
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String?> clientMessageId,
      required String conversationId,
      required String senderUserId,
      required String body,
      required int createdAt,
      Value<bool> isMine,
      Value<bool> delivered,
      Value<bool> readByPeer,
      Value<bool> sendFailed,
      Value<String?> senderLabel,
      Value<bool> viewOnce,
      Value<bool> viewed,
      Value<int?> expiresAt,
      Value<String?> mediaType,
      Value<String?> mediaBlobId,
      Value<String?> mediaKey,
      Value<String?> mediaMime,
      Value<int?> mediaWidth,
      Value<int?> mediaHeight,
      Value<String?> mediaLocalPath,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> localId,
      Value<String?> serverId,
      Value<String?> clientMessageId,
      Value<String> conversationId,
      Value<String> senderUserId,
      Value<String> body,
      Value<int> createdAt,
      Value<bool> isMine,
      Value<bool> delivered,
      Value<bool> readByPeer,
      Value<bool> sendFailed,
      Value<String?> senderLabel,
      Value<bool> viewOnce,
      Value<bool> viewed,
      Value<int?> expiresAt,
      Value<String?> mediaType,
      Value<String?> mediaBlobId,
      Value<String?> mediaKey,
      Value<String?> mediaMime,
      Value<int?> mediaWidth,
      Value<int?> mediaHeight,
      Value<String?> mediaLocalPath,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get readByPeer => $composableBuilder(
    column: $table.readByPeer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sendFailed => $composableBuilder(
    column: $table.sendFailed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderLabel => $composableBuilder(
    column: $table.senderLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viewOnce => $composableBuilder(
    column: $table.viewOnce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viewed => $composableBuilder(
    column: $table.viewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaBlobId => $composableBuilder(
    column: $table.mediaBlobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaKey => $composableBuilder(
    column: $table.mediaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaMime => $composableBuilder(
    column: $table.mediaMime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaWidth => $composableBuilder(
    column: $table.mediaWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaHeight => $composableBuilder(
    column: $table.mediaHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaLocalPath => $composableBuilder(
    column: $table.mediaLocalPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get readByPeer => $composableBuilder(
    column: $table.readByPeer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sendFailed => $composableBuilder(
    column: $table.sendFailed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderLabel => $composableBuilder(
    column: $table.senderLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viewOnce => $composableBuilder(
    column: $table.viewOnce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viewed => $composableBuilder(
    column: $table.viewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaBlobId => $composableBuilder(
    column: $table.mediaBlobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaKey => $composableBuilder(
    column: $table.mediaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaMime => $composableBuilder(
    column: $table.mediaMime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaWidth => $composableBuilder(
    column: $table.mediaWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaHeight => $composableBuilder(
    column: $table.mediaHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaLocalPath => $composableBuilder(
    column: $table.mediaLocalPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isMine =>
      $composableBuilder(column: $table.isMine, builder: (column) => column);

  GeneratedColumn<bool> get delivered =>
      $composableBuilder(column: $table.delivered, builder: (column) => column);

  GeneratedColumn<bool> get readByPeer => $composableBuilder(
    column: $table.readByPeer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sendFailed => $composableBuilder(
    column: $table.sendFailed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderLabel => $composableBuilder(
    column: $table.senderLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get viewOnce =>
      $composableBuilder(column: $table.viewOnce, builder: (column) => column);

  GeneratedColumn<bool> get viewed =>
      $composableBuilder(column: $table.viewed, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mediaBlobId => $composableBuilder(
    column: $table.mediaBlobId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaKey =>
      $composableBuilder(column: $table.mediaKey, builder: (column) => column);

  GeneratedColumn<String> get mediaMime =>
      $composableBuilder(column: $table.mediaMime, builder: (column) => column);

  GeneratedColumn<int> get mediaWidth => $composableBuilder(
    column: $table.mediaWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mediaHeight => $composableBuilder(
    column: $table.mediaHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaLocalPath => $composableBuilder(
    column: $table.mediaLocalPath,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> senderUserId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<bool> delivered = const Value.absent(),
                Value<bool> readByPeer = const Value.absent(),
                Value<bool> sendFailed = const Value.absent(),
                Value<String?> senderLabel = const Value.absent(),
                Value<bool> viewOnce = const Value.absent(),
                Value<bool> viewed = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<String?> mediaBlobId = const Value.absent(),
                Value<String?> mediaKey = const Value.absent(),
                Value<String?> mediaMime = const Value.absent(),
                Value<int?> mediaWidth = const Value.absent(),
                Value<int?> mediaHeight = const Value.absent(),
                Value<String?> mediaLocalPath = const Value.absent(),
              }) => MessagesCompanion(
                localId: localId,
                serverId: serverId,
                clientMessageId: clientMessageId,
                conversationId: conversationId,
                senderUserId: senderUserId,
                body: body,
                createdAt: createdAt,
                isMine: isMine,
                delivered: delivered,
                readByPeer: readByPeer,
                sendFailed: sendFailed,
                senderLabel: senderLabel,
                viewOnce: viewOnce,
                viewed: viewed,
                expiresAt: expiresAt,
                mediaType: mediaType,
                mediaBlobId: mediaBlobId,
                mediaKey: mediaKey,
                mediaMime: mediaMime,
                mediaWidth: mediaWidth,
                mediaHeight: mediaHeight,
                mediaLocalPath: mediaLocalPath,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                required String conversationId,
                required String senderUserId,
                required String body,
                required int createdAt,
                Value<bool> isMine = const Value.absent(),
                Value<bool> delivered = const Value.absent(),
                Value<bool> readByPeer = const Value.absent(),
                Value<bool> sendFailed = const Value.absent(),
                Value<String?> senderLabel = const Value.absent(),
                Value<bool> viewOnce = const Value.absent(),
                Value<bool> viewed = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<String?> mediaBlobId = const Value.absent(),
                Value<String?> mediaKey = const Value.absent(),
                Value<String?> mediaMime = const Value.absent(),
                Value<int?> mediaWidth = const Value.absent(),
                Value<int?> mediaHeight = const Value.absent(),
                Value<String?> mediaLocalPath = const Value.absent(),
              }) => MessagesCompanion.insert(
                localId: localId,
                serverId: serverId,
                clientMessageId: clientMessageId,
                conversationId: conversationId,
                senderUserId: senderUserId,
                body: body,
                createdAt: createdAt,
                isMine: isMine,
                delivered: delivered,
                readByPeer: readByPeer,
                sendFailed: sendFailed,
                senderLabel: senderLabel,
                viewOnce: viewOnce,
                viewed: viewed,
                expiresAt: expiresAt,
                mediaType: mediaType,
                mediaBlobId: mediaBlobId,
                mediaKey: mediaKey,
                mediaMime: mediaMime,
                mediaWidth: mediaWidth,
                mediaHeight: mediaHeight,
                mediaLocalPath: mediaLocalPath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String conversationId,
      Value<String?> peerUserId,
      Value<String?> title,
      Value<String?> username,
      Value<bool> isGroup,
      Value<String?> groupId,
      required int lastAt,
      Value<String> lastPreview,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> conversationId,
      Value<String?> peerUserId,
      Value<String?> title,
      Value<String?> username,
      Value<bool> isGroup,
      Value<String?> groupId,
      Value<int> lastAt,
      Value<String> lastPreview,
      Value<int> rowid,
    });

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPreview => $composableBuilder(
    column: $table.lastPreview,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPreview => $composableBuilder(
    column: $table.lastPreview,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => column);

  GeneratedColumn<String> get lastPreview => $composableBuilder(
    column: $table.lastPreview,
    builder: (column) => column,
  );
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (
            Conversation,
            BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>,
          ),
          Conversation,
          PrefetchHooks Function()
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conversationId = const Value.absent(),
                Value<String?> peerUserId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int> lastAt = const Value.absent(),
                Value<String> lastPreview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                conversationId: conversationId,
                peerUserId: peerUserId,
                title: title,
                username: username,
                isGroup: isGroup,
                groupId: groupId,
                lastAt: lastAt,
                lastPreview: lastPreview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conversationId,
                Value<String?> peerUserId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                required int lastAt,
                Value<String> lastPreview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                conversationId: conversationId,
                peerUserId: peerUserId,
                title: title,
                username: username,
                isGroup: isGroup,
                groupId: groupId,
                lastAt: lastAt,
                lastPreview: lastPreview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (
        Conversation,
        BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>,
      ),
      Conversation,
      PrefetchHooks Function()
    >;
typedef $$CallHistoryItemsTableCreateCompanionBuilder =
    CallHistoryItemsCompanion Function({
      required String id,
      required String conversationId,
      required String callType,
      required String status,
      required int startedAt,
      Value<String?> peerLabel,
      Value<int> rowid,
    });
typedef $$CallHistoryItemsTableUpdateCompanionBuilder =
    CallHistoryItemsCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> callType,
      Value<String> status,
      Value<int> startedAt,
      Value<String?> peerLabel,
      Value<int> rowid,
    });

class $$CallHistoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CallHistoryItemsTable> {
  $$CallHistoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerLabel => $composableBuilder(
    column: $table.peerLabel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallHistoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallHistoryItemsTable> {
  $$CallHistoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerLabel => $composableBuilder(
    column: $table.peerLabel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallHistoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallHistoryItemsTable> {
  $$CallHistoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callType =>
      $composableBuilder(column: $table.callType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get peerLabel =>
      $composableBuilder(column: $table.peerLabel, builder: (column) => column);
}

class $$CallHistoryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallHistoryItemsTable,
          CallHistoryItem,
          $$CallHistoryItemsTableFilterComposer,
          $$CallHistoryItemsTableOrderingComposer,
          $$CallHistoryItemsTableAnnotationComposer,
          $$CallHistoryItemsTableCreateCompanionBuilder,
          $$CallHistoryItemsTableUpdateCompanionBuilder,
          (
            CallHistoryItem,
            BaseReferences<
              _$AppDatabase,
              $CallHistoryItemsTable,
              CallHistoryItem
            >,
          ),
          CallHistoryItem,
          PrefetchHooks Function()
        > {
  $$CallHistoryItemsTableTableManager(
    _$AppDatabase db,
    $CallHistoryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallHistoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallHistoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallHistoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> callType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<String?> peerLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallHistoryItemsCompanion(
                id: id,
                conversationId: conversationId,
                callType: callType,
                status: status,
                startedAt: startedAt,
                peerLabel: peerLabel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String callType,
                required String status,
                required int startedAt,
                Value<String?> peerLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CallHistoryItemsCompanion.insert(
                id: id,
                conversationId: conversationId,
                callType: callType,
                status: status,
                startedAt: startedAt,
                peerLabel: peerLabel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallHistoryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallHistoryItemsTable,
      CallHistoryItem,
      $$CallHistoryItemsTableFilterComposer,
      $$CallHistoryItemsTableOrderingComposer,
      $$CallHistoryItemsTableAnnotationComposer,
      $$CallHistoryItemsTableCreateCompanionBuilder,
      $$CallHistoryItemsTableUpdateCompanionBuilder,
      (
        CallHistoryItem,
        BaseReferences<_$AppDatabase, $CallHistoryItemsTable, CallHistoryItem>,
      ),
      CallHistoryItem,
      PrefetchHooks Function()
    >;
typedef $$ConversationSettingsTableCreateCompanionBuilder =
    ConversationSettingsCompanion Function({
      required String conversationId,
      Value<int> disappearingSeconds,
      Value<int> rowid,
    });
typedef $$ConversationSettingsTableUpdateCompanionBuilder =
    ConversationSettingsCompanion Function({
      Value<String> conversationId,
      Value<int> disappearingSeconds,
      Value<int> rowid,
    });

class $$ConversationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationSettingsTable> {
  $$ConversationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get disappearingSeconds => $composableBuilder(
    column: $table.disappearingSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationSettingsTable> {
  $$ConversationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get disappearingSeconds => $composableBuilder(
    column: $table.disappearingSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationSettingsTable> {
  $$ConversationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get disappearingSeconds => $composableBuilder(
    column: $table.disappearingSeconds,
    builder: (column) => column,
  );
}

class $$ConversationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationSettingsTable,
          ConversationSetting,
          $$ConversationSettingsTableFilterComposer,
          $$ConversationSettingsTableOrderingComposer,
          $$ConversationSettingsTableAnnotationComposer,
          $$ConversationSettingsTableCreateCompanionBuilder,
          $$ConversationSettingsTableUpdateCompanionBuilder,
          (
            ConversationSetting,
            BaseReferences<
              _$AppDatabase,
              $ConversationSettingsTable,
              ConversationSetting
            >,
          ),
          ConversationSetting,
          PrefetchHooks Function()
        > {
  $$ConversationSettingsTableTableManager(
    _$AppDatabase db,
    $ConversationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConversationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> conversationId = const Value.absent(),
                Value<int> disappearingSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationSettingsCompanion(
                conversationId: conversationId,
                disappearingSeconds: disappearingSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conversationId,
                Value<int> disappearingSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationSettingsCompanion.insert(
                conversationId: conversationId,
                disappearingSeconds: disappearingSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationSettingsTable,
      ConversationSetting,
      $$ConversationSettingsTableFilterComposer,
      $$ConversationSettingsTableOrderingComposer,
      $$ConversationSettingsTableAnnotationComposer,
      $$ConversationSettingsTableCreateCompanionBuilder,
      $$ConversationSettingsTableUpdateCompanionBuilder,
      (
        ConversationSetting,
        BaseReferences<
          _$AppDatabase,
          $ConversationSettingsTable,
          ConversationSetting
        >,
      ),
      ConversationSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$CallHistoryItemsTableTableManager get callHistoryItems =>
      $$CallHistoryItemsTableTableManager(_db, _db.callHistoryItems);
  $$ConversationSettingsTableTableManager get conversationSettings =>
      $$ConversationSettingsTableTableManager(_db, _db.conversationSettings);
}
