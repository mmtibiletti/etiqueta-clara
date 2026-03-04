import 'package:flutter/material.dart';
import '../../core/services/history_service.dart';
import '../../core/models/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  late Future<List<HistoryItem>> _history;

  @override
  void initState() {
    super.initState();
    _history = HistoryService().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await HistoryService().clearHistory();
              setState(() {
                _history = HistoryService().getHistory();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: _history,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(
              child: Text("No hay escaneos aún"),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {

              final item = items[index];

              Color color;
              switch (item.status) {
                case "green":
                  color = Colors.green;
                  break;
                case "yellow":
                  color = Colors.orange;
                  break;
                default:
                  color = Colors.red;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(
                    item.status == "green"
                        ? Icons.check
                        : item.status == "yellow"
                        ? Icons.warning
                        : Icons.close,
                    color: color,
                  ),
                ),
                title: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(item.brand ?? ""),
                trailing: Text(
                  "${item.date.day}/${item.date.month}",
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(item.name),
                      content: Text(
                        "Estado: ${item.status.toUpperCase()}\n\nEscaneado el ${item.date.day}/${item.date.month}/${item.date.year}",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}