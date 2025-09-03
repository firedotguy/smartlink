// warning: this code fully made by ChatGPT, because i am too new to creating stuff like listeners, snapshots, etc.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';
import 'package:smartlink/pages/home.dart';

class ChatWidget extends StatefulWidget{
  const ChatWidget({
    required this.employeeId, super.key,
    this.initialChatId,
    this.initialOpenChat = false,
  });

  final int employeeId;
  final String? initialChatId;
  final bool initialOpenChat;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool chatOpened = false;
  bool messagesOpened = false;

  List<Map<String, dynamic>>? chats;
  List<Map<String, dynamic>>? messages;

  final Map<String, Map<String, dynamic>> _chatsById = {};

  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _msgSubs = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatNewListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatAssignedListener;
  final Map<String, DateTime> _subscribedAt = {};
  final Map<String, bool> _initialSnapshotHandled = {};

  final Map<String, int> _msgCounts = {};
  final Map<String, int> _lastSeenCounts = {};
  final Map<String, int> _unreadCounts = {};
  String? _activeChatId;
  Map<String, dynamic>? _activeChat;

  late final ScrollController _messagesScroll = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  int get newMessages => _unreadCounts.values.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    l.i('start listening chats for employee ${widget.employeeId}');
    listenChats();
    if (widget.initialOpenChat == true && widget.initialChatId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          try {
            l.i('auto-opening initial chat ${widget.initialChatId}');
            _openChat(widget.initialChatId!);
          } catch (e) {
            l.e('auto-open initial chat failed: $e');
          }
        });
      });
    }
  }

  @override
  void dispose() {
    l.i('cancel subscriptions');
    _chatNewListener?.cancel();
    _chatAssignedListener?.cancel();
    for (final s in _msgSubs.values) {
      s.cancel();
    }
    _msgSubs.clear();
    _msgCounts.clear();
    _lastSeenCounts.clear();
    _unreadCounts.clear();
    _chatsById.clear();
    _messagesScroll.dispose();
    _inputController.dispose();
    super.dispose();
  }

  DateTime _toDateTime(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.parse(v);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatTime(dynamic v) {
    final d = _toDateTime(v).toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    if (d.year == 1970) return '';
    return '$hh:$mm';
  }

  void _rebuildChatsList() {
    chats = _chatsById.values.toList()
      ..sort((a, b) {
        final da = _toDateTime(a['last_at']);
        final db = _toDateTime(b['last_at']);
        return db.compareTo(da);
      });
  }

  void listenChats() async {
    try {
      l.d('subscribing to chats where status=wait');
      _chatNewListener = FirebaseFirestore.instance
        .collection('chats')
        .where('status', isEqualTo: 'wait')
        .snapshots()
        .listen(_handleChatsSnapshot, onError: (e) {
          l.e('listenChats (wait) error: $e');
        });
    } catch (e) {
      l.e('failed to listen wait chats: $e');
    }

    try {
      l.d('subscribing to chats assigned to operator ${widget.employeeId}');
      _chatAssignedListener = FirebaseFirestore.instance
        .collection('chats')
        .where('operator', isEqualTo: widget.employeeId)
        .snapshots()
        .listen(_handleChatsSnapshot, onError: (e) {
          l.e('listenChats (assigned) error: $e');
        });
    } catch (e) {
      l.e('failed to listen assigned chats: $e');
    }
  }

  void _handleChatsSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    var changed = false;

    if (snap.docs.isEmpty && _chatsById.isEmpty && (chats == null)) {
      l.i('no chats found (initial), setting empty list');
      chats = [];
      setState(() {});
      return;
    }

    for (final doc in snap.docs) {
      final id = doc.id;
      final data = <String, dynamic>{ 'id': id, ...doc.data() };
      final prev = _chatsById[id];

      _chatsById[id] = {
        ...?_chatsById[id],
        ...data,
      };

      if (prev == null || !mapEquals(prev, _chatsById[id])) {
        changed = true;
      }

      if (!_msgSubs.containsKey(id)) {
        _subscribeMessagesForChat(id);
      }
    }

    if (changed || chats == null) {
      _rebuildChatsList();
      chats ??= [];
      setState(() {});
    }
  }

  void _subscribeMessagesForChat(String chatId) {
    try {
      l.d('subscribing messages for $chatId');
      _subscribedAt[chatId] = DateTime.now();
      _initialSnapshotHandled[chatId] = false;

      // ignore: cancel_subscriptions
      final sub = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at')
        .snapshots()
        .listen((snap) {
          l.i('messages snapshot for $chatId - ${snap.docs.length} messages (initialHandled=${_initialSnapshotHandled[chatId]})');
          final newCount = snap.docs.length;

          if (snap.docs.isNotEmpty) {
            final last = snap.docs.last.data();
            _chatsById[chatId]?['last_message'] = last['content'] ?? '';
            _chatsById[chatId]?['last_at'] = last['created_at'];
          } else {
            _chatsById[chatId]?['last_message'] = '';
            _chatsById[chatId]?['last_at'] = null;
          }

          _msgCounts[chatId] = newCount;

          final subscribedAt = _subscribedAt[chatId];

          if (!(_initialSnapshotHandled[chatId] ?? false)) {
            int initialUnread = 0;

            if (subscribedAt != null) {
              for (final d in snap.docs) {
                final m = d.data();
                final createdRaw = m['created_at'];
                if (createdRaw == null) {
                  initialUnread++;
                  l.d('initial doc ${d.id} created_at=null -> count as new');
                  continue;
                }
                final dt = _toDateTime(createdRaw);
                if (!dt.isBefore(subscribedAt)) {
                  initialUnread++;
                  l.d('initial doc ${d.id} created_at=$dt >= subscribedAt=$subscribedAt -> count as new');
                } else {
                  l.d('initial doc ${d.id} created_at=$dt < subscribedAt=$subscribedAt -> old');
                }
              }
            }

            _lastSeenCounts[chatId] = newCount - initialUnread;
            _unreadCounts[chatId] = initialUnread;
            _initialSnapshotHandled[chatId] = true;

            l.i('initial snapshot for $chatId: total=$newCount initialUnread=$initialUnread');
            if (messagesOpened && _activeChatId == chatId) {
              l.i('initial snapshot: active chat is open, marking seen');
              _lastSeenCounts[chatId] = newCount;
              _unreadCounts[chatId] = 0;

              messages = snap.docs.map((d) {
                final m = d.data();
                return {
                  'id': d.id,
                  'content': m['content'],
                  'is_customer': m['is_customer'] ?? false,
                  'created_at': m['created_at'],
                };
              }).toList(growable: false);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _attemptScrollToBottom();
              });
            }
          } else {
            if (messagesOpened && _activeChatId == chatId) {
              l.i('active chat $chatId updated, marking as seen (normal update)');
              messages = snap.docs.map((d){
                final m = d.data();
                return {
                  'id': d.id,
                  'content': m['content'],
                  'is_customer': m['is_customer'] ?? false,
                  'created_at': m['created_at'],
                  'system': m['system'] ?? false,
                };
              }).toList(growable: false);

              _lastSeenCounts[chatId] = newCount;
              _unreadCounts[chatId] = 0;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _attemptScrollToBottom();
              });
            } else {
              final lastSeen = _lastSeenCounts[chatId] ?? 0;
              final unread = (newCount - lastSeen) > 0 ? (newCount - lastSeen) : 0;
              _unreadCounts[chatId] = unread;
              if (unread > 0) {
                l.i('chat $chatId has $unread unread messages (newCount=$newCount lastSeen=$lastSeen)');
              }
            }
          }

          _rebuildChatsList();
          if (mounted) setState(() {});
        }, onError: (e) {
          l.e('messages listen error for $chatId: $e');
        });

      _msgSubs[chatId] = sub;
    } catch (e) {
      l.e('cant subscribe messages for $chatId: $e');
    }
  }

  Future<void> _openChat(String chatId) async {
    l.i('opening chat $chatId');
    _activeChatId = chatId;
    messagesOpened = true;
    _activeChat = _chatsById[chatId];
    chatOpened = true;

    if (!_msgSubs.containsKey(chatId)) {
      _subscribeMessagesForChat(chatId);
    }

    try {
      final snap = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('created_at')
        .get();

      messages = snap.docs.map((d) {
        final m = d.data();
        return {
          'id': d.id,
          'content': m['content'],
          'is_customer': m['is_customer'] ?? false,
          'created_at': m['created_at'],
          'system': m['system'] ?? false,
          'operator_id': m['operator_id'],
          'operator_name': m['operator_name'],
        };
      }).toList(growable: false);
      l.d('mapped messages for $chatId: ${messages!.map((e) => {'id': e['id'], 'system': e['system']}).toList()}');

      final total = snap.docs.length;
      _msgCounts[chatId] = total;

      _lastSeenCounts[chatId] = total;
      _unreadCounts[chatId] = 0;

      _rebuildChatsList();
      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attemptScrollToBottom();
      });
    } catch (e) {
      l.e('failed to load messages for $chatId: $e');
    }
  }

  Future<void> _acceptChat() async {
    final chatId = _activeChatId;
    if (chatId == null) return;
    final operatorId = widget.employeeId;
    final operatorName = await getEmployeeName(operatorId);

    l.i('accepting chat $chatId by operator $operatorId');
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    try {
      await chatRef.update({
        'operator': operatorId,
        'status': 'active',
        'operators': FieldValue.arrayUnion([operatorId]),
      });

      final content = 'Оператор $operatorName принял обращение.';
      await chatRef.collection('messages').add({
        'content': content,
        'is_customer': false,
        'system': true,
        'operator_id': operatorId,
        'operator_name': operatorName,
        'created_at': FieldValue.serverTimestamp(),
      });

      _chatsById[chatId]?['operator'] = operatorId;
      _chatsById[chatId]?['status'] = 'active';
      _activeChat = _chatsById[chatId];
      setState(() {});
      final int customerId = (await chatRef.get()).data()!['customer'];
      l.i('chat $chatId accepted successfully');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              customerId: customerId,
              initialChatId: chatId,        // <- id чата, который только что приняли
              initialOpenChat: true,        // <- флаг открыть чат сразу
            ),
          ),
        );
      }
    } catch (e) {
      l.e('failed to accept chat $chatId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при принятии чата', style: TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _finishChat() async {
    final chatId = _activeChatId;
    if (chatId == null) return;
    final operatorId = widget.employeeId;
    final operatorName = await getEmployeeName(operatorId);

    l.i('finishing chat $chatId by operator $operatorId');
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    try {
      await chatRef.update({
        'operator': null,
        'status': 'idle',
      });

      final content = 'Оператор $operatorName пометил обращение как завершённое.';
      await chatRef.collection('messages').add({
        'content': content,
        'is_customer': false,
        'system': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      _chatsById[chatId]?['operator'] = null;
      _chatsById[chatId]?['status'] = 'idle';
      _activeChat = _chatsById[chatId];
      _inputController.clear();
      setState(() {});
      l.i('chat $chatId finished successfully');
    } catch (e) {
      l.e('failed to finish chat $chatId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при завершении чата', style: TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final chatId = _activeChatId;
    if (chatId == null) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final operatorId = widget.employeeId;

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    try {
      _inputController.clear();

      await chatRef.collection('messages').add({
        'content': text,
        'is_customer': false,
        'system': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ensure chat metadata updated to reflect last message time (optional)
      await chatRef.update({
        'last_at': FieldValue.serverTimestamp(),
      });

      // scroll will happen by snapshot listener when new message arrives
      l.i('sent message to $chatId by operator $operatorId');
    } catch (e) {
      l.e('failed sending message to $chatId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка отправки сообщения', style: TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  void _closeMessages() {
    l.i('closing messages view (active=$_activeChatId)');
    messagesOpened = false;
    _activeChatId = null;
    _activeChat = null;
    messages = null;
    setState(() {});
  }

  void _attemptScrollToBottom() {
    if (!messagesOpened) return;

    if (!_messagesScroll.hasClients) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!_messagesScroll.hasClients) {
          return;
        }
        try {
          _messagesScroll.jumpTo(_messagesScroll.position.maxScrollExtent);
        } catch (e) {
          l.e('_attemptScrollToBottom delayed jumpTo failed: $e');
        }
      });
      return;
    }

    try {
      final max = _messagesScroll.position.maxScrollExtent;
      _messagesScroll.animateTo(
        max + 40,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ).catchError((e) {
        l.e('animateTo failed: $e, trying jumpTo');
        try {
          _messagesScroll.jumpTo(_messagesScroll.position.maxScrollExtent);
        } catch (err) {
          l.e('jumpTo fallback failed: $err');
        }
      });
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!_messagesScroll.hasClients) {
          l.d('no clients');
          return;
        }
        try {
          _messagesScroll.jumpTo(_messagesScroll.position.maxScrollExtent);
        } catch (err) {
          l.e('delayed jumpTo failed: $err');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        if (chatOpened)
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
          ),
          height: MediaQuery.of(context).size.height / 1.6,
          padding: const EdgeInsets.all(8),
          child: chats == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.neo))
            : messagesOpened ? _buildMessagesView() : _buildChatsListView()
        ),
        GestureDetector(
          onTap: () => setState(() {
            chatOpened = !chatOpened;
            if (chatOpened) {
              l.d('chat panel opened');
            } else {
              l.d('chat panel closed');
              messagesOpened = false;
            }
          }),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.neo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.neo.withValues(alpha: 0.28)),
                  ),
                  child: const Icon(Icons.chat_bubble, color: AppColors.neo, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Сообщения',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (newMessages > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 3))],
                          ),
                          height: 18,
                          width: 18,
                          alignment: Alignment.center,
                          child: Text(
                            newMessages.toString(),
                            style: const TextStyle(color: AppColors.main, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  chatOpened? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatsListView() {
    if (chats != null && chats!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 40, color: AppColors.secondary),
            SizedBox(height: 8),
            Text('Чатов пока нет', style: TextStyle(color: AppColors.secondary)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Чаты', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: chats?.length ?? 0,
            separatorBuilder: (_, __) => const Divider(height: 8, color: Color(0x22FFFFFF)),
            itemBuilder: (c, i) {
              final chat = chats![i];
              final id = chat['id']?.toString() ?? '';
              final customerName = chat['customer_name']?.toString() ?? 'Абонент';
              final lastMessage = chat['last_message']?.toString() ?? '';
              final lastAt = chat['last_at'];
              final unread = _unreadCounts[id] ?? 0;
              return InkWell(
                onTap: () => _openChat(id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(lastMessage, style: const TextStyle(color: AppColors.secondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_formatTime(lastAt), style: const TextStyle(color: AppColors.secondary, fontSize: 10)),
                          const SizedBox(height: 6),
                          if (unread > 0)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.neo,
                                borderRadius: BorderRadius.circular(8)
                              ),
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              child: Text(unread.toString(), style: const TextStyle(color: AppColors.main, fontSize: 12))
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesView() {
    final active = _activeChat ?? {};
    final operatorAssigned = active['operator'] == widget.employeeId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _closeMessages,
              icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.secondary)
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(active['customer_name']?.toString() ?? 'Сообщения', style: const TextStyle(fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            if (active['status'] == 'wait')
            ElevatedButton.icon(
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 50, 181, 104))),
              onPressed: _acceptChat,
              label: const Text('Принять'),
              icon: const Icon(Icons.check),
            ),
            if (active['status'] == 'active')
            ElevatedButton.icon(
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.error)),
              onPressed: _finishChat,
              label: const Text('Завершить'),
              icon: const Icon(Icons.close),
            )
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: messages == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.neo))
            : ListView.builder(
              controller: _messagesScroll,
              itemCount: messages!.length,
              itemBuilder: (c, i) {
                final m = messages![i];
                final isCustomer = m['is_customer'] ?? false;
                final isSystem = m['system'] ?? false;
                final content = m['content']?.toString() ?? '';
                final createdAt = m['created_at'];

                if (isSystem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04))
                        ),
                        child: Text(content, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: isCustomer ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                          decoration: BoxDecoration(
                            color: isCustomer ? AppColors.bg2 : AppColors.neo,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04))
                          ),
                          child: IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(content, style: const TextStyle(color: AppColors.main)),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(_formatTime(createdAt), style: TextStyle(color: isCustomer? AppColors.secondary : AppColors.main, fontSize: 10))
                                )
                              ],
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
        ),

        if (operatorAssigned)
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06)))
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Сообщение...',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                  child: const Icon(Icons.send),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
