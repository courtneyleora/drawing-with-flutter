// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shape Drawing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DrawingScreen(),
    );
  }
}

// Enum to define different shape types
enum ShapeType { square, circle, arc }

// Shape class to store shape properties
class Shape {
  final Offset start;
  final Offset end;
  final ShapeType type;
  final Color color; // Store color for each shape

  Shape(
      {required this.start,
      required this.end,
      required this.type,
      required this.color});
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<Shape> shapes = [];
  ShapeType selectedShape = ShapeType.square; // Default shape
  Color selectedColor = Colors.blue; // Default color

  // Function to show color picker dialog
  void pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pick a Color"),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
        actions: [
          TextButton(
            child: Text("Done"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw Shapes'),
        actions: [
          // Shape Selection Menu
          PopupMenuButton<ShapeType>(
            onSelected: (ShapeType shape) {
              setState(() {
                selectedShape = shape;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: ShapeType.square, child: Text('Square')),
              PopupMenuItem(value: ShapeType.circle, child: Text('Circle')),
              PopupMenuItem(value: ShapeType.arc, child: Text('Arc')),
            ],
          ),
          // Color Picker Button
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: pickColor,
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset startPosition =
                renderBox.globalToLocal(details.globalPosition);
            shapes.add(Shape(
                start: startPosition,
                end: startPosition,
                type: selectedShape,
                color: selectedColor));
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset currentPosition =
                renderBox.globalToLocal(details.globalPosition);
            shapes.last = Shape(
                start: shapes.last.start,
                end: currentPosition,
                type: selectedShape,
                color: selectedColor);
          });
        },
        child: CustomPaint(
          painter: ShapePainter(shapes),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            shapes.clear();
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Shape> shapes;
  ShapePainter(this.shapes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var shape in shapes) {
      Paint paint = Paint()
        ..color = shape.color // Assign user-selected color
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;

      switch (shape.type) {
        case ShapeType.square:
          canvas.drawRect(Rect.fromPoints(shape.start, shape.end), paint);
          break;
        case ShapeType.circle:
          Offset center = Offset((shape.start.dx + shape.end.dx) / 2,
              (shape.start.dy + shape.end.dy) / 2);
          double radius = (shape.start - shape.end).distance / 2;
          canvas.drawCircle(center, radius, paint);
          break;
        case ShapeType.arc:
          canvas.drawArc(
              Rect.fromPoints(shape.start, shape.end), 0, 3.14, false, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
