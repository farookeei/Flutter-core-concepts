import 'package:flutter/material.dart';
import 'package:stac/stac.dart';

class StacDemoPage extends StatelessWidget {
  const StacDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stac SDUI Demo')),
      body: Stac.fromJson(json, context),
    );
  }
}

const Map<String, dynamic> json = {
  "type": "Column",
  "axis": "vertical",
  "mainAxisAlignment": "center",
  "crossAxisAlignment": "center",
  "children": [
    {
      "type": "Text",
      "data": "Hello from Stac!",
      "style": {"fontSize": 24, "fontWeight": "bold", "color": "#6200EE"},
    },
    {"type": "SizedBox", "height": 20},
    {
      "type": "Image",
      "src":
          "https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png",
      "height": 100,
      "width": 100,
      "fit": "contain",
    },
    {"type": "SizedBox", "height": 20},
    {
      "type": "Text",
      "data": "This UI is defined in JSON.",
      "style": {"fontSize": 16},
    },
    {
      "type": "Container",
      "margin": {"top": 20},
      "padding": {"all": 16},
      "decoration": {"color": "#E0E0E0", "borderRadius": 12},
      "child": {"type": "Text", "data": "Dynamic Container"},
    },
  ],
};
