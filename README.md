# Ghosts of the Sky

Flutter + Three.js r170 in a WebView (`flutter_inappwebview` 6.1.5, pinned).

## Requirements

- Flutter SDK: `>=3.5.0 <4.0.0`

## Getting Started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) version `>=3.5.0 <4.0.0`.
2. Clone the repository and navigate to the project directory.
3. Install dependencies:

   ```bash
   flutter pub get
   ```

## Running the App

### Android / iOS

Connect a real phone or start an emulator/simulator:

```bash
flutter run
```

### Web

<badge color="warning">Incomplete support</badge>

Web support is currently incomplete and experimental. Some WebView-specific functionality may not work as expected because the project uses `flutter_inappwebview`.

```bash
flutter run -d chrome
```

### Windows

```bash
flutter run -d windows
```

### macOS

```bash
flutter run -d macos
```

## Testing the Experience

Check the following interactions:

- Moon appears on the screen.
- Drag to rotate the scene.
- Pinch to zoom.
- Tap an orange dot to update the status bar (3D → Flutter).
- Use the bottom buttons to fly the camera (Flutter → 3D).

## Platform Notes

- **Android / iOS:** Primary target platforms.
- **Web:** Incomplete; WebView integration and platform-specific functionality may not work as expected.
- **Windows / macOS:** Desktop support is available, but some mobile-specific interactions may behave differently.
