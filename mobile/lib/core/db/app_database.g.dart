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
  static const VerificationMeta _mediaFilenameMeta = const VerificationMeta(
    'mediaFilename',
  );
  @override
  late final GeneratedColumn<String> mediaFilename = GeneratedColumn<String>(
    'media_filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaSizeMeta = const VerificationMeta(
    'mediaSize',
  );
  @override
  late final GeneratedColumn<int> mediaSize = GeneratedColumn<int>(
    'media_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaDurationMsMeta = const VerificationMeta(
    'mediaDurationMs',
  );
  @override
  late final GeneratedColumn<int> mediaDurationMs = GeneratedColumn<int>(
    'media_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaWaveformMeta = const VerificationMeta(
    'mediaWaveform',
  );
  @override
  late final GeneratedColumn<String> mediaWaveform = GeneratedColumn<String>(
    'media_waveform',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyToIdMeta = const VerificationMeta(
    'replyToId',
  );
  @override
  late final GeneratedColumn<String> replyToId = GeneratedColumn<String>(
    'reply_to_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replySenderMeta = const VerificationMeta(
    'replySender',
  );
  @override
  late final GeneratedColumn<String> replySender = GeneratedColumn<String>(
    'reply_sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyPreviewMeta = const VerificationMeta(
    'replyPreview',
  );
  @override
  late final GeneratedColumn<String> replyPreview = GeneratedColumn<String>(
    'reply_preview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyMediaTypeMeta = const VerificationMeta(
    'replyMediaType',
  );
  @override
  late final GeneratedColumn<String> replyMediaType = GeneratedColumn<String>(
    'reply_media_type',
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
    mediaFilename,
    mediaSize,
    mediaDurationMs,
    mediaWaveform,
    replyToId,
    replySender,
    replyPreview,
    replyMediaType,
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
    if (data.containsKey('media_filename')) {
      context.handle(
        _mediaFilenameMeta,
        mediaFilename.isAcceptableOrUnknown(
          data['media_filename']!,
          _mediaFilenameMeta,
        ),
      );
    }
    if (data.containsKey('media_size')) {
      context.handle(
        _mediaSizeMeta,
        mediaSize.isAcceptableOrUnknown(data['media_size']!, _mediaSizeMeta),
      );
    }
    if (data.containsKey('media_duration_ms')) {
      context.handle(
        _mediaDurationMsMeta,
        mediaDurationMs.isAcceptableOrUnknown(
          data['media_duration_ms']!,
          _mediaDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('media_waveform')) {
      context.handle(
        _mediaWaveformMeta,
        mediaWaveform.isAcceptableOrUnknown(
          data['media_waveform']!,
          _mediaWaveformMeta,
        ),
      );
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(
        _replyToIdMeta,
        replyToId.isAcceptableOrUnknown(data['reply_to_id']!, _replyToIdMeta),
      );
    }
    if (data.containsKey('reply_sender')) {
      context.handle(
        _replySenderMeta,
        replySender.isAcceptableOrUnknown(
          data['reply_sender']!,
          _replySenderMeta,
        ),
      );
    }
    if (data.containsKey('reply_preview')) {
      context.handle(
        _replyPreviewMeta,
        replyPreview.isAcceptableOrUnknown(
          data['reply_preview']!,
          _replyPreviewMeta,
        ),
      );
    }
    if (data.containsKey('reply_media_type')) {
      context.handle(
        _replyMediaTypeMeta,
        replyMediaType.isAcceptableOrUnknown(
          data['reply_media_type']!,
          _replyMediaTypeMeta,
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
      mediaFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_filename'],
      ),
      mediaSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_size'],
      ),
      mediaDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_duration_ms'],
      ),
      mediaWaveform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_waveform'],
      ),
      replyToId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to_id'],
      ),
      replySender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_sender'],
      ),
      replyPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_preview'],
      ),
      replyMediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_media_type'],
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

  /// Original filename and byte size for 'file' attachments.
  final String? mediaFilename;
  final int? mediaSize;

  /// Voice-note duration (ms) and comma-separated waveform bars (0–100).
  final int? mediaDurationMs;
  final String? mediaWaveform;

  /// Reply/quote: id of the referenced message + a cached preview so the quote
  /// renders even if the original isn't stored locally.
  final String? replyToId;
  final String? replySender;
  final String? replyPreview;
  final String? replyMediaType;
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
    this.mediaFilename,
    this.mediaSize,
    this.mediaDurationMs,
    this.mediaWaveform,
    this.replyToId,
    this.replySender,
    this.replyPreview,
    this.replyMediaType,
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
    if (!nullToAbsent || mediaFilename != null) {
      map['media_filename'] = Variable<String>(mediaFilename);
    }
    if (!nullToAbsent || mediaSize != null) {
      map['media_size'] = Variable<int>(mediaSize);
    }
    if (!nullToAbsent || mediaDurationMs != null) {
      map['media_duration_ms'] = Variable<int>(mediaDurationMs);
    }
    if (!nullToAbsent || mediaWaveform != null) {
      map['media_waveform'] = Variable<String>(mediaWaveform);
    }
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<String>(replyToId);
    }
    if (!nullToAbsent || replySender != null) {
      map['reply_sender'] = Variable<String>(replySender);
    }
    if (!nullToAbsent || replyPreview != null) {
      map['reply_preview'] = Variable<String>(replyPreview);
    }
    if (!nullToAbsent || replyMediaType != null) {
      map['reply_media_type'] = Variable<String>(replyMediaType);
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
      mediaFilename: mediaFilename == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaFilename),
      mediaSize: mediaSize == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaSize),
      mediaDurationMs: mediaDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaDurationMs),
      mediaWaveform: mediaWaveform == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaWaveform),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      replySender: replySender == null && nullToAbsent
          ? const Value.absent()
          : Value(replySender),
      replyPreview: replyPreview == null && nullToAbsent
          ? const Value.absent()
          : Value(replyPreview),
      replyMediaType: replyMediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(replyMediaType),
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
      mediaFilename: serializer.fromJson<String?>(json['mediaFilename']),
      mediaSize: serializer.fromJson<int?>(json['mediaSize']),
      mediaDurationMs: serializer.fromJson<int?>(json['mediaDurationMs']),
      mediaWaveform: serializer.fromJson<String?>(json['mediaWaveform']),
      replyToId: serializer.fromJson<String?>(json['replyToId']),
      replySender: serializer.fromJson<String?>(json['replySender']),
      replyPreview: serializer.fromJson<String?>(json['replyPreview']),
      replyMediaType: serializer.fromJson<String?>(json['replyMediaType']),
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
      'mediaFilename': serializer.toJson<String?>(mediaFilename),
      'mediaSize': serializer.toJson<int?>(mediaSize),
      'mediaDurationMs': serializer.toJson<int?>(mediaDurationMs),
      'mediaWaveform': serializer.toJson<String?>(mediaWaveform),
      'replyToId': serializer.toJson<String?>(replyToId),
      'replySender': serializer.toJson<String?>(replySender),
      'replyPreview': serializer.toJson<String?>(replyPreview),
      'replyMediaType': serializer.toJson<String?>(replyMediaType),
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
    Value<String?> mediaFilename = const Value.absent(),
    Value<int?> mediaSize = const Value.absent(),
    Value<int?> mediaDurationMs = const Value.absent(),
    Value<String?> mediaWaveform = const Value.absent(),
    Value<String?> replyToId = const Value.absent(),
    Value<String?> replySender = const Value.absent(),
    Value<String?> replyPreview = const Value.absent(),
    Value<String?> replyMediaType = const Value.absent(),
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
    mediaFilename: mediaFilename.present
        ? mediaFilename.value
        : this.mediaFilename,
    mediaSize: mediaSize.present ? mediaSize.value : this.mediaSize,
    mediaDurationMs: mediaDurationMs.present
        ? mediaDurationMs.value
        : this.mediaDurationMs,
    mediaWaveform: mediaWaveform.present
        ? mediaWaveform.value
        : this.mediaWaveform,
    replyToId: replyToId.present ? replyToId.value : this.replyToId,
    replySender: replySender.present ? replySender.value : this.replySender,
    replyPreview: replyPreview.present ? replyPreview.value : this.replyPreview,
    replyMediaType: replyMediaType.present
        ? replyMediaType.value
        : this.replyMediaType,
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
      mediaFilename: data.mediaFilename.present
          ? data.mediaFilename.value
          : this.mediaFilename,
      mediaSize: data.mediaSize.present ? data.mediaSize.value : this.mediaSize,
      mediaDurationMs: data.mediaDurationMs.present
          ? data.mediaDurationMs.value
          : this.mediaDurationMs,
      mediaWaveform: data.mediaWaveform.present
          ? data.mediaWaveform.value
          : this.mediaWaveform,
      replyToId: data.replyToId.present ? data.replyToId.value : this.replyToId,
      replySender: data.replySender.present
          ? data.replySender.value
          : this.replySender,
      replyPreview: data.replyPreview.present
          ? data.replyPreview.value
          : this.replyPreview,
      replyMediaType: data.replyMediaType.present
          ? data.replyMediaType.value
          : this.replyMediaType,
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
          ..write('mediaLocalPath: $mediaLocalPath, ')
          ..write('mediaFilename: $mediaFilename, ')
          ..write('mediaSize: $mediaSize, ')
          ..write('mediaDurationMs: $mediaDurationMs, ')
          ..write('mediaWaveform: $mediaWaveform, ')
          ..write('replyToId: $replyToId, ')
          ..write('replySender: $replySender, ')
          ..write('replyPreview: $replyPreview, ')
          ..write('replyMediaType: $replyMediaType')
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
    mediaFilename,
    mediaSize,
    mediaDurationMs,
    mediaWaveform,
    replyToId,
    replySender,
    replyPreview,
    replyMediaType,
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
          other.mediaLocalPath == this.mediaLocalPath &&
          other.mediaFilename == this.mediaFilename &&
          other.mediaSize == this.mediaSize &&
          other.mediaDurationMs == this.mediaDurationMs &&
          other.mediaWaveform == this.mediaWaveform &&
          other.replyToId == this.replyToId &&
          other.replySender == this.replySender &&
          other.replyPreview == this.replyPreview &&
          other.replyMediaType == this.replyMediaType);
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
  final Value<String?> mediaFilename;
  final Value<int?> mediaSize;
  final Value<int?> mediaDurationMs;
  final Value<String?> mediaWaveform;
  final Value<String?> replyToId;
  final Value<String?> replySender;
  final Value<String?> replyPreview;
  final Value<String?> replyMediaType;
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
    this.mediaFilename = const Value.absent(),
    this.mediaSize = const Value.absent(),
    this.mediaDurationMs = const Value.absent(),
    this.mediaWaveform = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replySender = const Value.absent(),
    this.replyPreview = const Value.absent(),
    this.replyMediaType = const Value.absent(),
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
    this.mediaFilename = const Value.absent(),
    this.mediaSize = const Value.absent(),
    this.mediaDurationMs = const Value.absent(),
    this.mediaWaveform = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replySender = const Value.absent(),
    this.replyPreview = const Value.absent(),
    this.replyMediaType = const Value.absent(),
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
    Expression<String>? mediaFilename,
    Expression<int>? mediaSize,
    Expression<int>? mediaDurationMs,
    Expression<String>? mediaWaveform,
    Expression<String>? replyToId,
    Expression<String>? replySender,
    Expression<String>? replyPreview,
    Expression<String>? replyMediaType,
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
      if (mediaFilename != null) 'media_filename': mediaFilename,
      if (mediaSize != null) 'media_size': mediaSize,
      if (mediaDurationMs != null) 'media_duration_ms': mediaDurationMs,
      if (mediaWaveform != null) 'media_waveform': mediaWaveform,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (replySender != null) 'reply_sender': replySender,
      if (replyPreview != null) 'reply_preview': replyPreview,
      if (replyMediaType != null) 'reply_media_type': replyMediaType,
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
    Value<String?>? mediaFilename,
    Value<int?>? mediaSize,
    Value<int?>? mediaDurationMs,
    Value<String?>? mediaWaveform,
    Value<String?>? replyToId,
    Value<String?>? replySender,
    Value<String?>? replyPreview,
    Value<String?>? replyMediaType,
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
      mediaFilename: mediaFilename ?? this.mediaFilename,
      mediaSize: mediaSize ?? this.mediaSize,
      mediaDurationMs: mediaDurationMs ?? this.mediaDurationMs,
      mediaWaveform: mediaWaveform ?? this.mediaWaveform,
      replyToId: replyToId ?? this.replyToId,
      replySender: replySender ?? this.replySender,
      replyPreview: replyPreview ?? this.replyPreview,
      replyMediaType: replyMediaType ?? this.replyMediaType,
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
    if (mediaFilename.present) {
      map['media_filename'] = Variable<String>(mediaFilename.value);
    }
    if (mediaSize.present) {
      map['media_size'] = Variable<int>(mediaSize.value);
    }
    if (mediaDurationMs.present) {
      map['media_duration_ms'] = Variable<int>(mediaDurationMs.value);
    }
    if (mediaWaveform.present) {
      map['media_waveform'] = Variable<String>(mediaWaveform.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<String>(replyToId.value);
    }
    if (replySender.present) {
      map['reply_sender'] = Variable<String>(replySender.value);
    }
    if (replyPreview.present) {
      map['reply_preview'] = Variable<String>(replyPreview.value);
    }
    if (replyMediaType.present) {
      map['reply_media_type'] = Variable<String>(replyMediaType.value);
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
          ..write('mediaLocalPath: $mediaLocalPath, ')
          ..write('mediaFilename: $mediaFilename, ')
          ..write('mediaSize: $mediaSize, ')
          ..write('mediaDurationMs: $mediaDurationMs, ')
          ..write('mediaWaveform: $mediaWaveform, ')
          ..write('replyToId: $replyToId, ')
          ..write('replySender: $replySender, ')
          ..write('replyPreview: $replyPreview, ')
          ..write('replyMediaType: $replyMediaType')
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
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _leftGroupMeta = const VerificationMeta(
    'leftGroup',
  );
  @override
  late final GeneratedColumn<bool> leftGroup = GeneratedColumn<bool>(
    'left_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("left_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _avatarBlobIdMeta = const VerificationMeta(
    'avatarBlobId',
  );
  @override
  late final GeneratedColumn<String> avatarBlobId = GeneratedColumn<String>(
    'avatar_blob_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarKeyMeta = const VerificationMeta(
    'avatarKey',
  );
  @override
  late final GeneratedColumn<String> avatarKey = GeneratedColumn<String>(
    'avatar_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    unreadCount,
    leftGroup,
    avatarBlobId,
    avatarKey,
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
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('left_group')) {
      context.handle(
        _leftGroupMeta,
        leftGroup.isAcceptableOrUnknown(data['left_group']!, _leftGroupMeta),
      );
    }
    if (data.containsKey('avatar_blob_id')) {
      context.handle(
        _avatarBlobIdMeta,
        avatarBlobId.isAcceptableOrUnknown(
          data['avatar_blob_id']!,
          _avatarBlobIdMeta,
        ),
      );
    }
    if (data.containsKey('avatar_key')) {
      context.handle(
        _avatarKeyMeta,
        avatarKey.isAcceptableOrUnknown(data['avatar_key']!, _avatarKeyMeta),
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
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      leftGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}left_group'],
      )!,
      avatarBlobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_blob_id'],
      ),
      avatarKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_key'],
      ),
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

  /// Unread messages in this thread (badge on the chat list). Client-maintained.
  final int unreadCount;

  /// True once the local user leaves (or is removed from) a group. The chat
  /// stays in the list as a read-only thread instead of vanishing.
  final bool leftGroup;

  /// Group avatar: encrypted image blob id + its AES key (null = no photo).
  final String? avatarBlobId;
  final String? avatarKey;
  const Conversation({
    required this.conversationId,
    this.peerUserId,
    this.title,
    this.username,
    required this.isGroup,
    this.groupId,
    required this.lastAt,
    required this.lastPreview,
    required this.unreadCount,
    required this.leftGroup,
    this.avatarBlobId,
    this.avatarKey,
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
    map['unread_count'] = Variable<int>(unreadCount);
    map['left_group'] = Variable<bool>(leftGroup);
    if (!nullToAbsent || avatarBlobId != null) {
      map['avatar_blob_id'] = Variable<String>(avatarBlobId);
    }
    if (!nullToAbsent || avatarKey != null) {
      map['avatar_key'] = Variable<String>(avatarKey);
    }
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
      unreadCount: Value(unreadCount),
      leftGroup: Value(leftGroup),
      avatarBlobId: avatarBlobId == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarBlobId),
      avatarKey: avatarKey == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarKey),
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
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      leftGroup: serializer.fromJson<bool>(json['leftGroup']),
      avatarBlobId: serializer.fromJson<String?>(json['avatarBlobId']),
      avatarKey: serializer.fromJson<String?>(json['avatarKey']),
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
      'unreadCount': serializer.toJson<int>(unreadCount),
      'leftGroup': serializer.toJson<bool>(leftGroup),
      'avatarBlobId': serializer.toJson<String?>(avatarBlobId),
      'avatarKey': serializer.toJson<String?>(avatarKey),
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
    int? unreadCount,
    bool? leftGroup,
    Value<String?> avatarBlobId = const Value.absent(),
    Value<String?> avatarKey = const Value.absent(),
  }) => Conversation(
    conversationId: conversationId ?? this.conversationId,
    peerUserId: peerUserId.present ? peerUserId.value : this.peerUserId,
    title: title.present ? title.value : this.title,
    username: username.present ? username.value : this.username,
    isGroup: isGroup ?? this.isGroup,
    groupId: groupId.present ? groupId.value : this.groupId,
    lastAt: lastAt ?? this.lastAt,
    lastPreview: lastPreview ?? this.lastPreview,
    unreadCount: unreadCount ?? this.unreadCount,
    leftGroup: leftGroup ?? this.leftGroup,
    avatarBlobId: avatarBlobId.present ? avatarBlobId.value : this.avatarBlobId,
    avatarKey: avatarKey.present ? avatarKey.value : this.avatarKey,
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
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      leftGroup: data.leftGroup.present ? data.leftGroup.value : this.leftGroup,
      avatarBlobId: data.avatarBlobId.present
          ? data.avatarBlobId.value
          : this.avatarBlobId,
      avatarKey: data.avatarKey.present ? data.avatarKey.value : this.avatarKey,
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
          ..write('lastPreview: $lastPreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('leftGroup: $leftGroup, ')
          ..write('avatarBlobId: $avatarBlobId, ')
          ..write('avatarKey: $avatarKey')
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
    unreadCount,
    leftGroup,
    avatarBlobId,
    avatarKey,
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
          other.lastPreview == this.lastPreview &&
          other.unreadCount == this.unreadCount &&
          other.leftGroup == this.leftGroup &&
          other.avatarBlobId == this.avatarBlobId &&
          other.avatarKey == this.avatarKey);
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
  final Value<int> unreadCount;
  final Value<bool> leftGroup;
  final Value<String?> avatarBlobId;
  final Value<String?> avatarKey;
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
    this.unreadCount = const Value.absent(),
    this.leftGroup = const Value.absent(),
    this.avatarBlobId = const Value.absent(),
    this.avatarKey = const Value.absent(),
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
    this.unreadCount = const Value.absent(),
    this.leftGroup = const Value.absent(),
    this.avatarBlobId = const Value.absent(),
    this.avatarKey = const Value.absent(),
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
    Expression<int>? unreadCount,
    Expression<bool>? leftGroup,
    Expression<String>? avatarBlobId,
    Expression<String>? avatarKey,
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
      if (unreadCount != null) 'unread_count': unreadCount,
      if (leftGroup != null) 'left_group': leftGroup,
      if (avatarBlobId != null) 'avatar_blob_id': avatarBlobId,
      if (avatarKey != null) 'avatar_key': avatarKey,
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
    Value<int>? unreadCount,
    Value<bool>? leftGroup,
    Value<String?>? avatarBlobId,
    Value<String?>? avatarKey,
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
      unreadCount: unreadCount ?? this.unreadCount,
      leftGroup: leftGroup ?? this.leftGroup,
      avatarBlobId: avatarBlobId ?? this.avatarBlobId,
      avatarKey: avatarKey ?? this.avatarKey,
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
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (leftGroup.present) {
      map['left_group'] = Variable<bool>(leftGroup.value);
    }
    if (avatarBlobId.present) {
      map['avatar_blob_id'] = Variable<String>(avatarBlobId.value);
    }
    if (avatarKey.present) {
      map['avatar_key'] = Variable<String>(avatarKey.value);
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
          ..write('unreadCount: $unreadCount, ')
          ..write('leftGroup: $leftGroup, ')
          ..write('avatarBlobId: $avatarBlobId, ')
          ..write('avatarKey: $avatarKey, ')
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

class $MessageReactionsTable extends MessageReactions
    with TableInfo<$MessageReactionsTable, MessageReaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
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
  static const VerificationMeta _reactorUserIdMeta = const VerificationMeta(
    'reactorUserId',
  );
  @override
  late final GeneratedColumn<String> reactorUserId = GeneratedColumn<String>(
    'reactor_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    targetId,
    conversationId,
    reactorUserId,
    emoji,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageReaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
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
    if (data.containsKey('reactor_user_id')) {
      context.handle(
        _reactorUserIdMeta,
        reactorUserId.isAcceptableOrUnknown(
          data['reactor_user_id']!,
          _reactorUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reactorUserIdMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetId, reactorUserId};
  @override
  MessageReaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageReaction(
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      reactorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reactor_user_id'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MessageReactionsTable createAlias(String alias) {
    return $MessageReactionsTable(attachedDatabase, alias);
  }
}

class MessageReaction extends DataClass implements Insertable<MessageReaction> {
  /// Target message id (server message_id / envelopeId).
  final String targetId;
  final String conversationId;
  final String reactorUserId;
  final String emoji;
  final int updatedAt;
  const MessageReaction({
    required this.targetId,
    required this.conversationId,
    required this.reactorUserId,
    required this.emoji,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_id'] = Variable<String>(targetId);
    map['conversation_id'] = Variable<String>(conversationId);
    map['reactor_user_id'] = Variable<String>(reactorUserId);
    map['emoji'] = Variable<String>(emoji);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MessageReactionsCompanion toCompanion(bool nullToAbsent) {
    return MessageReactionsCompanion(
      targetId: Value(targetId),
      conversationId: Value(conversationId),
      reactorUserId: Value(reactorUserId),
      emoji: Value(emoji),
      updatedAt: Value(updatedAt),
    );
  }

  factory MessageReaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageReaction(
      targetId: serializer.fromJson<String>(json['targetId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      reactorUserId: serializer.fromJson<String>(json['reactorUserId']),
      emoji: serializer.fromJson<String>(json['emoji']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetId': serializer.toJson<String>(targetId),
      'conversationId': serializer.toJson<String>(conversationId),
      'reactorUserId': serializer.toJson<String>(reactorUserId),
      'emoji': serializer.toJson<String>(emoji),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MessageReaction copyWith({
    String? targetId,
    String? conversationId,
    String? reactorUserId,
    String? emoji,
    int? updatedAt,
  }) => MessageReaction(
    targetId: targetId ?? this.targetId,
    conversationId: conversationId ?? this.conversationId,
    reactorUserId: reactorUserId ?? this.reactorUserId,
    emoji: emoji ?? this.emoji,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MessageReaction copyWithCompanion(MessageReactionsCompanion data) {
    return MessageReaction(
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      reactorUserId: data.reactorUserId.present
          ? data.reactorUserId.value
          : this.reactorUserId,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageReaction(')
          ..write('targetId: $targetId, ')
          ..write('conversationId: $conversationId, ')
          ..write('reactorUserId: $reactorUserId, ')
          ..write('emoji: $emoji, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(targetId, conversationId, reactorUserId, emoji, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageReaction &&
          other.targetId == this.targetId &&
          other.conversationId == this.conversationId &&
          other.reactorUserId == this.reactorUserId &&
          other.emoji == this.emoji &&
          other.updatedAt == this.updatedAt);
}

class MessageReactionsCompanion extends UpdateCompanion<MessageReaction> {
  final Value<String> targetId;
  final Value<String> conversationId;
  final Value<String> reactorUserId;
  final Value<String> emoji;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MessageReactionsCompanion({
    this.targetId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.reactorUserId = const Value.absent(),
    this.emoji = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageReactionsCompanion.insert({
    required String targetId,
    required String conversationId,
    required String reactorUserId,
    required String emoji,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : targetId = Value(targetId),
       conversationId = Value(conversationId),
       reactorUserId = Value(reactorUserId),
       emoji = Value(emoji),
       updatedAt = Value(updatedAt);
  static Insertable<MessageReaction> custom({
    Expression<String>? targetId,
    Expression<String>? conversationId,
    Expression<String>? reactorUserId,
    Expression<String>? emoji,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetId != null) 'target_id': targetId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (reactorUserId != null) 'reactor_user_id': reactorUserId,
      if (emoji != null) 'emoji': emoji,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageReactionsCompanion copyWith({
    Value<String>? targetId,
    Value<String>? conversationId,
    Value<String>? reactorUserId,
    Value<String>? emoji,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MessageReactionsCompanion(
      targetId: targetId ?? this.targetId,
      conversationId: conversationId ?? this.conversationId,
      reactorUserId: reactorUserId ?? this.reactorUserId,
      emoji: emoji ?? this.emoji,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (reactorUserId.present) {
      map['reactor_user_id'] = Variable<String>(reactorUserId.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageReactionsCompanion(')
          ..write('targetId: $targetId, ')
          ..write('conversationId: $conversationId, ')
          ..write('reactorUserId: $reactorUserId, ')
          ..write('emoji: $emoji, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $MessageReactionsTable messageReactions = $MessageReactionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    conversations,
    callHistoryItems,
    conversationSettings,
    messageReactions,
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
      Value<String?> mediaFilename,
      Value<int?> mediaSize,
      Value<int?> mediaDurationMs,
      Value<String?> mediaWaveform,
      Value<String?> replyToId,
      Value<String?> replySender,
      Value<String?> replyPreview,
      Value<String?> replyMediaType,
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
      Value<String?> mediaFilename,
      Value<int?> mediaSize,
      Value<int?> mediaDurationMs,
      Value<String?> mediaWaveform,
      Value<String?> replyToId,
      Value<String?> replySender,
      Value<String?> replyPreview,
      Value<String?> replyMediaType,
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

  ColumnFilters<String> get mediaFilename => $composableBuilder(
    column: $table.mediaFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaSize => $composableBuilder(
    column: $table.mediaSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mediaDurationMs => $composableBuilder(
    column: $table.mediaDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaWaveform => $composableBuilder(
    column: $table.mediaWaveform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyToId => $composableBuilder(
    column: $table.replyToId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replySender => $composableBuilder(
    column: $table.replySender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyPreview => $composableBuilder(
    column: $table.replyPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyMediaType => $composableBuilder(
    column: $table.replyMediaType,
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

  ColumnOrderings<String> get mediaFilename => $composableBuilder(
    column: $table.mediaFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaSize => $composableBuilder(
    column: $table.mediaSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaDurationMs => $composableBuilder(
    column: $table.mediaDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaWaveform => $composableBuilder(
    column: $table.mediaWaveform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyToId => $composableBuilder(
    column: $table.replyToId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replySender => $composableBuilder(
    column: $table.replySender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyPreview => $composableBuilder(
    column: $table.replyPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyMediaType => $composableBuilder(
    column: $table.replyMediaType,
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

  GeneratedColumn<String> get mediaFilename => $composableBuilder(
    column: $table.mediaFilename,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mediaSize =>
      $composableBuilder(column: $table.mediaSize, builder: (column) => column);

  GeneratedColumn<int> get mediaDurationMs => $composableBuilder(
    column: $table.mediaDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaWaveform => $composableBuilder(
    column: $table.mediaWaveform,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyToId =>
      $composableBuilder(column: $table.replyToId, builder: (column) => column);

  GeneratedColumn<String> get replySender => $composableBuilder(
    column: $table.replySender,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyPreview => $composableBuilder(
    column: $table.replyPreview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyMediaType => $composableBuilder(
    column: $table.replyMediaType,
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
                Value<String?> mediaFilename = const Value.absent(),
                Value<int?> mediaSize = const Value.absent(),
                Value<int?> mediaDurationMs = const Value.absent(),
                Value<String?> mediaWaveform = const Value.absent(),
                Value<String?> replyToId = const Value.absent(),
                Value<String?> replySender = const Value.absent(),
                Value<String?> replyPreview = const Value.absent(),
                Value<String?> replyMediaType = const Value.absent(),
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
                mediaFilename: mediaFilename,
                mediaSize: mediaSize,
                mediaDurationMs: mediaDurationMs,
                mediaWaveform: mediaWaveform,
                replyToId: replyToId,
                replySender: replySender,
                replyPreview: replyPreview,
                replyMediaType: replyMediaType,
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
                Value<String?> mediaFilename = const Value.absent(),
                Value<int?> mediaSize = const Value.absent(),
                Value<int?> mediaDurationMs = const Value.absent(),
                Value<String?> mediaWaveform = const Value.absent(),
                Value<String?> replyToId = const Value.absent(),
                Value<String?> replySender = const Value.absent(),
                Value<String?> replyPreview = const Value.absent(),
                Value<String?> replyMediaType = const Value.absent(),
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
                mediaFilename: mediaFilename,
                mediaSize: mediaSize,
                mediaDurationMs: mediaDurationMs,
                mediaWaveform: mediaWaveform,
                replyToId: replyToId,
                replySender: replySender,
                replyPreview: replyPreview,
                replyMediaType: replyMediaType,
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
      Value<int> unreadCount,
      Value<bool> leftGroup,
      Value<String?> avatarBlobId,
      Value<String?> avatarKey,
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
      Value<int> unreadCount,
      Value<bool> leftGroup,
      Value<String?> avatarBlobId,
      Value<String?> avatarKey,
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

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get leftGroup => $composableBuilder(
    column: $table.leftGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarBlobId => $composableBuilder(
    column: $table.avatarBlobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarKey => $composableBuilder(
    column: $table.avatarKey,
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

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get leftGroup => $composableBuilder(
    column: $table.leftGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarBlobId => $composableBuilder(
    column: $table.avatarBlobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarKey => $composableBuilder(
    column: $table.avatarKey,
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

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get leftGroup =>
      $composableBuilder(column: $table.leftGroup, builder: (column) => column);

  GeneratedColumn<String> get avatarBlobId => $composableBuilder(
    column: $table.avatarBlobId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarKey =>
      $composableBuilder(column: $table.avatarKey, builder: (column) => column);
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
                Value<int> unreadCount = const Value.absent(),
                Value<bool> leftGroup = const Value.absent(),
                Value<String?> avatarBlobId = const Value.absent(),
                Value<String?> avatarKey = const Value.absent(),
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
                unreadCount: unreadCount,
                leftGroup: leftGroup,
                avatarBlobId: avatarBlobId,
                avatarKey: avatarKey,
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
                Value<int> unreadCount = const Value.absent(),
                Value<bool> leftGroup = const Value.absent(),
                Value<String?> avatarBlobId = const Value.absent(),
                Value<String?> avatarKey = const Value.absent(),
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
                unreadCount: unreadCount,
                leftGroup: leftGroup,
                avatarBlobId: avatarBlobId,
                avatarKey: avatarKey,
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
typedef $$MessageReactionsTableCreateCompanionBuilder =
    MessageReactionsCompanion Function({
      required String targetId,
      required String conversationId,
      required String reactorUserId,
      required String emoji,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MessageReactionsTableUpdateCompanionBuilder =
    MessageReactionsCompanion Function({
      Value<String> targetId,
      Value<String> conversationId,
      Value<String> reactorUserId,
      Value<String> emoji,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$MessageReactionsTableFilterComposer
    extends Composer<_$AppDatabase, $MessageReactionsTable> {
  $$MessageReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactorUserId => $composableBuilder(
    column: $table.reactorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageReactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageReactionsTable> {
  $$MessageReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactorUserId => $composableBuilder(
    column: $table.reactorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageReactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageReactionsTable> {
  $$MessageReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reactorUserId => $composableBuilder(
    column: $table.reactorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MessageReactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageReactionsTable,
          MessageReaction,
          $$MessageReactionsTableFilterComposer,
          $$MessageReactionsTableOrderingComposer,
          $$MessageReactionsTableAnnotationComposer,
          $$MessageReactionsTableCreateCompanionBuilder,
          $$MessageReactionsTableUpdateCompanionBuilder,
          (
            MessageReaction,
            BaseReferences<
              _$AppDatabase,
              $MessageReactionsTable,
              MessageReaction
            >,
          ),
          MessageReaction,
          PrefetchHooks Function()
        > {
  $$MessageReactionsTableTableManager(
    _$AppDatabase db,
    $MessageReactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> targetId = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> reactorUserId = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageReactionsCompanion(
                targetId: targetId,
                conversationId: conversationId,
                reactorUserId: reactorUserId,
                emoji: emoji,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String targetId,
                required String conversationId,
                required String reactorUserId,
                required String emoji,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MessageReactionsCompanion.insert(
                targetId: targetId,
                conversationId: conversationId,
                reactorUserId: reactorUserId,
                emoji: emoji,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageReactionsTable,
      MessageReaction,
      $$MessageReactionsTableFilterComposer,
      $$MessageReactionsTableOrderingComposer,
      $$MessageReactionsTableAnnotationComposer,
      $$MessageReactionsTableCreateCompanionBuilder,
      $$MessageReactionsTableUpdateCompanionBuilder,
      (
        MessageReaction,
        BaseReferences<_$AppDatabase, $MessageReactionsTable, MessageReaction>,
      ),
      MessageReaction,
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
  $$MessageReactionsTableTableManager get messageReactions =>
      $$MessageReactionsTableTableManager(_db, _db.messageReactions);
}
