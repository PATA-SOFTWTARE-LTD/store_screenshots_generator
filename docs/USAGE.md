# Store Screenshots Generator - Guida all'Uso

Questo documento contiene tutte le istruzioni per inizializzare, configurare e avviare l'acquisizione dei **RAW Screenshots** necessari poi per la generazione dei frame per App Store e Google Play.

## 1. Setup

Il pacchetto deve essere configurato all'interno delle `dev_dependencies` nel tuo `pubspec.yaml` e necessita di `integration_test` o `flutter_test`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  store_screenshots_generator:
    path: ../ # Sostituire con la versione desiderata se pubblicato in pub.dev
```

## 2. Creazione Test di Acquisizione

A differenza dei soliti integration test lenti, il tool usa `flutter_test` offline rapido avvalendosi della helper library `store_screenshots_generator/src/capture/raw_capturer.dart`.

Dovrai creare un test come nell'esempio base `test/raw_screenshots_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/capture/raw_capturer.dart';
// Importa la tua app

void main() {
  testWidgets('Generate Raw Screenshots', (WidgetTester tester) async {
    // Il CLI andrà a riempire queste variabili
    const deviceId = String.fromEnvironment('DEVICE', defaultValue: 'iphone_15_pro');
    const locale = String.fromEnvironment('LOCALE', defaultValue: 'it-IT');

    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Customizza questa parte con i tap per spostarti
    await captureRawScreenshot(
      tester,
      screenshotId: 'home_light',
      locale: locale,
      deviceId: deviceId,
    );
    
    // reset..
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
```

## 3. Avvio della Acquisizione (CLI)

Il runner di acquisizione leggerà il tuo file `screenshots.yaml` (dove indichi lingue e devices) e re-itererà il test appena definito.

La sintassi generica è:
```bash
dart run store_screenshots_generator:capture_raw -c <percorso_yaml> -t <percorso_test>
```

Se ti trovi **nella root** del pacchetto open source, dovrai indirizzarlo alla cartella `example`:
```bash
dart run store_screenshots_generator:capture_raw -c example/screenshots.yaml -t example/test/raw_screenshots_test.dart
```

Se sei in progetto target che si trova in una root che prevede già un file `screenshots.yaml` alla radice e sei tu a hostare il file `test/raw_screenshots_test.dart`, puoi omettere gli argomenti poiché il default è già gestito.

```bash
dart run store_screenshots_generator:capture_raw
```

### Opzioni CLI aggiuntive

Puoi includere o escludere una **Status Bar simulata** (che mostra l'orario 9:41, Wi-fi e Batteria iOS/Android) sopra i tuoi raw-screenshot. Di default è attiva. Per disattivarla usa il flag:
```bash
dart run store_screenshots_generator:capture_raw --no-status-bar
```

## 4. Gestione della Test UI e ScreenshotScaffold

Invece di gestire manualmente la `MediaQuery` e la `FakeStatusBar`, il tool mette a disposizione il widget `ScreenshotScaffold`. Questo widget configura automaticamente:
- La **Safe Area** corretta in base al `deviceId` (notch, dynamic island, etc).
- La **Status Bar simulata** con altezza adattiva.
- Il **RepaintBoundary** necessario per la cattura.

Esempio di utilizzo nel tuo `raw_screenshots_test.dart`:

```dart
    final rootKey = GlobalKey();
    final device = DeviceRegistry.getById(deviceId);
    const includeStatusBar = bool.fromEnvironment('INCLUDE_STATUS_BAR', defaultValue: true);
    
    // Lo scaffold gestisce logicamente tutto il setup del device
    final appRoot = ScreenshotScaffold(
      device: device,
      includeStatusBar: includeStatusBar,
      boundaryKey: rootKey,
      statusBarContentColor: Colors.white, // Colore icone status bar
      child: const MyApp(),
    );

    // Imposta la dimensione logica e fisica correttamente
    final logicalSize = Size(device.resolution.width / device.pixelRatio, device.resolution.height / device.pixelRatio);
    await tester.binding.setSurfaceSize(logicalSize);
    tester.view.physicalSize = device.resolution;
    tester.view.devicePixelRatio = device.pixelRatio;

    await tester.pumpWidget(appRoot);
    await tester.pumpAndSettle();

    // ... navigazione ...

    await captureRawScreenshot(
      tester,
      screenshotId: 'home_screen',
      locale: locale,
      deviceId: deviceId,
      boundaryKey: rootKey,
    );
```

## 6. Generazione Finale (Framing)

Dopo aver acquisito gli screenshot raw, puoi generare le versioni finali con frame, titoli e sfondi utilizzando il comando `generate`.

```bash
dart run store_screenshots_generator:generate -c <percorso_yaml>
```

Se sei nella root dell'esempio:
```bash
dart run store_screenshots_generator:generate -c example/screenshots.yaml
```

### Configurazione `screenshots.yaml` avanzata

Il file di configurazione ora supporta una sezione globale per il **tema** e la registrazione di **font personalizzati**.

```yaml
# Configurazione Font (opzionale)
# I font devono essere presenti nel sistema (es. .ttf)
fonts:
  - family: "Inter"
    path: "assets/fonts/Inter-VariableFont_slnt,wght.ttf"

# Tema Globale (opzionale)
# I valori qui definiti vengono usati da tutti i template come default
theme:
  titleColor: "#FFFFFF"       # Colore testo titolo (Hex)
  subtitleColor: "#E0E0E0"    # Colore testo sottotitolo
  titleFont: "Inter"         # FontFamily registrata sopra o di sistema
  subtitleFont: "Inter"
  gradientTop: "#1A237E"      # Colore alto dello sfondo (Sfumatura o Solido)
  gradientBottom: "#121212"   # Colore basso dello sfondo

# Definizione Screenshot
screens:
  - id: "home_light"
    template: "device_frame" # default, device_frame, solid_background, split_screen
    variables:
      # Variabili localizzate (verranno risolte in base alla lingua)
      title:
        it-IT: "Gestione Semplice"
        en-US: "Easy Management"
      subtitle:
        it-IT: "Traccia tutte le tue attività"
        en-US: "Track all your activities"
      # Variabili locali (sovrascrivono il tema globale per questa specifica schermata)
      gradientTop: "#D32F2F" 
```

### Template Supportati

1. **`default`**: Sfondo sfumato, titolo in alto, screenshot con bordo arrotondato e ombra.
2. **`device_frame`**: Caricamento di un bezel hardware reale (se disponibile in `DeviceRegistry`).
3. **`solid_background`**: Sfondo a tinta unita (o gradiente piatto) con screenshot centrato.
4. **`split_screen`**: Applica due colori di sfondo distinti (top/bottom) per un effetto dinamico.

### Localizzazione delle Variabili

Il sistema di rendering risolve automaticamente le variabili in base alla gerarchia:
1. Variabile localizzata specifica (es. `title.it-IT`).
2. Variabile locale non localizzata (es. `gradientTop: "#FF0000"`).
3. Variabile definita nel `theme` globale.
4. Valore di fallback del template (HARDCODED).
