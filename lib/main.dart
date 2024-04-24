import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'fitting_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ValueNotifier<ThemeMode>(ThemeMode.system),
        builder: (context, widget) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.light),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            themeMode: context.watch<ValueNotifier<ThemeMode>>().value,
            home: const MyHomePage(title: 'Fluent Icons Search'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController controller;
  static const double padding = 10;

  String get filter => controller.text;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          topRow(context),
          Expanded(
            child: GridView.extent(
              maxCrossAxisExtent: 100,
              crossAxisSpacing: 2.5,
              padding: const EdgeInsets.all(padding),
              physics: const BouncingScrollPhysics(),
              children: FittingIcons.fittingIcons(filter)
                  .entries
                  .map(gridElement)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget gridElement(MapEntry<String, IconData> entry) {
    return MaterialButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: entry.key));
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Copied '${entry.key}' to Clipboard")));
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(entry.value, size: 30),
              const SizedBox(
                height: 5,
              ),
              Text(
                entry.key,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding topRow(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return Padding(
      padding:
          const EdgeInsets.only(left: padding, right: padding, top: padding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: padding),
          IconButton(
            onPressed: () {
              ValueNotifier<ThemeMode> notifier =
                  Provider.of<ValueNotifier<ThemeMode>>(context, listen: false);
              switch (brightness) {
                case Brightness.dark:
                  notifier.value = ThemeMode.light;
                  break;
                case Brightness.light:
                  notifier.value = ThemeMode.dark;
                  break;
              }
            },
            icon: Icon(icon(brightness)),
          )
        ],
      ),
    );
  }

  IconData icon(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return Icons.light_mode;
      case Brightness.light:
        return Icons.dark_mode;
    }
  }
}
