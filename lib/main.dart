import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuração para remover todas as barras do sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MissionPlayApp());
}

class MissionPlayApp extends StatelessWidget {
  const MissionPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MissionPlay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navega para a tela principal após um curto período
    Future.delayed(Duration(seconds: 4), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => MissionPlayWebView(),
          transitionDuration: Duration.zero,
          opaque: true,
          barrierColor: Colors.black,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000), // Fundo preto
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou imagem da MissionPlay
            Image.network(
              'https://missionplay.com.br/logo.png', // Substitua pela URL real do logo
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'MissionPlay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MissionPlayWebView extends StatefulWidget {
  const MissionPlayWebView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MissionPlayWebViewState createState() => _MissionPlayWebViewState();
}

class _MissionPlayWebViewState extends State<MissionPlayWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Configuração do WebView
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                setState(() {
                  _isLoading = progress < 100;
                });
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                // ignore: avoid_print
                print('Erro ao carregar página: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse('https://missionplay.com.br'));
  }

  @override
  Widget build(BuildContext context) {
    // Configuração para modo fullscreen sem qualquer barra
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      backgroundColor: Colors.black, // Garantir fundo preto
      body: Stack(
        children: [
          // WebView ocupando toda a tela
          WebViewWidget(controller: _controller),

          // Indicador de carregamento
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
