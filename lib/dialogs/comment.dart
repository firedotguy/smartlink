import 'package:flutter/material.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';

/// Task comment dialog
class CommentDialog extends StatefulWidget{
  /// Init dialog
  const CommentDialog({required this.taskId, super.key});
  /// task id
  final int taskId;

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  List<Map>? comments;

  void _loadComments() async {
    l.i('load comments from task ${widget.taskId}');
    try{
      comments = List<Map>.from((await getComments(widget.taskId))['comments']);
    } catch (e){
      l.i('error while loading comments: $e');
      if (mounted){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка получения комментариев задания', style: TextStyle(color: AppColors.error))
        ));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Комментарии задания'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (comments == null)
            const Center(child: AngularProgressBar())
            else if (comments!.isEmpty)
            const Text('Нет комментариев', style: TextStyle(color: AppColors.secondary))
            else
            ListView.builder(
              shrinkWrap: true,
              itemCount: comments!.length,
              itemBuilder: (c, i){
                final Map comment = comments![i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(comment['content']),
                      Text(formatDate(comment['date']).substring(9, 14), style: const TextStyle(color: AppColors.secondary, fontSize: 12))
                    ],
                  ),
                );
              }
            )
          ]
        )
      ),
      actions: [
        ElevatedButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text('Ок')
        )
      ],
    );
  }
}