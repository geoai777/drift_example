import 'package:flutter/material.dart';

class LauncherScreen extends StatefulWidget {
  final String title;
  final Color color;

  const LauncherScreen({super.key, required this.title, required this.color});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  @override
  Widget build(BuildContext context) {
    /// make button 1/3rd of screen width
    final double buttonWidth = MediaQuery.of(context).size.width / 3;
    const double buttonHeight = 75.0;
    const double buttonBorder = 5.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorder)
                  ),
                  minimumSize: Size(buttonWidth, buttonHeight)
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/common');
                },
                child: const Text('Drift example')
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorder)
                  ),
                  minimumSize: Size(buttonWidth, buttonHeight)
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/dao');
                },
                child: const Text('DAO chunks')
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorder)
                  ),
                  minimumSize: Size(buttonWidth, buttonHeight)
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/postgres');
                },
                child: const Text('Drift with postgres')
            ),
          ],
        ),
      ),
    );
  }
}
