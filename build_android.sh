#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

BUILD_TYPE="${1:-appbundle}"

KEY_PROPERTIES="$ROOT_DIR/android/key.properties"
if [[ ! -f "$KEY_PROPERTIES" ]]; then
  echo "ERRO: falta android/key.properties (keystore de release)."
  echo "Sem isso o AAB/APK release não assina para a Play Store."
  echo ""
  echo "Crie android/key.properties com:"
  echo "  storePassword=..."
  echo "  keyPassword=..."
  echo "  keyAlias=..."
  echo "  storeFile=/caminho/absoluto/para/upload-keystore.jks"
  exit 1
fi

echo "==> Flutter pub get"
flutter pub get

case "$BUILD_TYPE" in
  apk)
    echo "==> Gerando APK release"
    flutter build apk --release
    echo "APK gerado em:"
    echo "build/app/outputs/flutter-apk/app-release.apk"
    ;;
  appbundle|aab)
    echo "==> Gerando App Bundle release"
    flutter build appbundle --release
    echo "App Bundle gerado em:"
    echo "build/app/outputs/bundle/release/app-release.aab"
    ;;
  *)
    echo "Uso: ./build_android.sh [apk|appbundle]"
    exit 1
    ;;
esac
