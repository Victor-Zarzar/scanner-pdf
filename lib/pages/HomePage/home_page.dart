import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:scan_pdf/components/CameraService/camera_service.dart';
import 'package:scan_pdf/components/Drawer/drawer_app.dart';

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          'text_appbar'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
      drawer: const DrawerComponent(),
      body: _cameraService.controller == null ||
              !_cameraService.controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : RotatedBox(
              quarterTurns: 1,
              child: _cameraService.buildCameraPreview(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Scan and Open PDF',
        onPressed: _scanAndOpenPDF,
        child: const Icon(
          Icons.add,
          size: 28,
          color: Colors.white,
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
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.wrap_text_sharp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
