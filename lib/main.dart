import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'screens/entry.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const EcoPickApp());
}

class EcoPickApp extends StatelessWidget {
  const EcoPickApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EcoPick',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    // Di layar lebar (Chrome desktop) tampilan dibatasi selebar HP.
    builder: (context, child) => ColoredBox(
      color: const Color(0xFFDCE8D2),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: child,
        ),
      ),
    ),
    home: const SplashScreen(),
  );
}
