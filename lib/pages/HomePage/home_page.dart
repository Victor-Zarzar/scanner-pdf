import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:scan_pdf/components/CameraService/camera_service.dart';
import 'package:scan_pdf/pages/SettingsPage/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraService _cameraService;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initializeCamera();
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _scanAndOpenPDF() async {
    try {
      final imageFile = await _cameraService.takePicture();
      if (imageFile != null) {
        final pdfFile = await _createPdf(imageFile.path);
        OpenFilex.open(pdfFile.path);
      }
    } catch (e) {
      debugPrint('Error scanning and opening PDF: $e');
    }
  }

  Future<File> _createPdf(String imagePath) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(File(imagePath).readAsBytesSync());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Image(image),
      ),
    );

    final outputDirectory = await getTemporaryDirectory();
    final file = File('${outputDirectory.path}/document.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'text_appbar'.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraService.controller == null ||
                    !_cameraService.controller!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : RotatedBox(
                    quarterTurns: 1,
                    child: _cameraService.buildCameraPreview(),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Scan and Open PDF',
        onPressed: _scanAndOpenPDF,
        child: Icon(
          Icons.add,
          size: 28,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.secondary,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.home,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.settings,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
