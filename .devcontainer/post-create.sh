#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.24.5"
ANDROID_CMDTOOLS_VERSION="11076708"
ANDROID_SDK_ROOT="$HOME/android-sdk"
FLUTTER_ROOT="$HOME/flutter"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║    Flutter Admin Dashboard — Dev Container   ║"
echo "║              Setup Iniciado...               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────
# 1. Flutter SDK
# ─────────────────────────────────────────────────
if [ ! -f "$FLUTTER_ROOT/bin/flutter" ]; then
  echo "▶ Instalando Flutter $FLUTTER_VERSION..."
  wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -O /tmp/flutter.tar.xz
  tar -xf /tmp/flutter.tar.xz -C "$HOME"
  rm /tmp/flutter.tar.xz
  echo "✔ Flutter instalado em $FLUTTER_ROOT"
else
  echo "✔ Flutter já instalado (cache)"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"

# ─────────────────────────────────────────────────
# 2. Android Command-line Tools
# ─────────────────────────────────────────────────
if [ ! -f "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "▶ Instalando Android Command-line Tools..."
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  wget -q \
    "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip" \
    -O /tmp/cmdtools.zip
  unzip -q /tmp/cmdtools.zip -d "$ANDROID_SDK_ROOT/cmdline-tools"
  mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" \
     "$ANDROID_SDK_ROOT/cmdline-tools/latest"
  rm /tmp/cmdtools.zip
  echo "✔ Android command-line tools instalados"
else
  echo "✔ Android cmdline-tools já instalados (cache)"
fi

export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# ─────────────────────────────────────────────────
# 3. Android SDK components
# ─────────────────────────────────────────────────
echo "▶ Aceitando licenças Android..."
yes | sdkmanager --licenses > /dev/null 2>&1 || true

echo "▶ Instalando SDK platforms e build-tools..."
sdkmanager \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "platform-tools" \
  > /dev/null 2>&1
echo "✔ Android SDK configurado"

# ─────────────────────────────────────────────────
# 4. Flutter config
# ─────────────────────────────────────────────────
echo "▶ Configurando Flutter..."
flutter config --android-sdk "$ANDROID_SDK_ROOT" --no-analytics > /dev/null 2>&1
flutter config --enable-android > /dev/null 2>&1
yes | flutter doctor --android-licenses > /dev/null 2>&1 || true

# ─────────────────────────────────────────────────
# 5. Adicionar PATH ao .bashrc
# ─────────────────────────────────────────────────
{
  echo ""
  echo "# Flutter & Android"
  echo "export FLUTTER_ROOT=\"\$HOME/flutter\""
  echo "export ANDROID_SDK_ROOT=\"\$HOME/android-sdk\""
  echo "export PATH=\"\$FLUTTER_ROOT/bin:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:\$ANDROID_SDK_ROOT/platform-tools:\$PATH\""
} >> "$HOME/.bashrc"

# ─────────────────────────────────────────────────
# 6. Flutter pub get
# ─────────────────────────────────────────────────
echo "▶ Instalando dependências do projeto..."
cd /workspaces/*/
flutter pub get
echo "✔ Dependências instaladas"

# ─────────────────────────────────────────────────
# 7. Flutter doctor (resumo)
# ─────────────────────────────────────────────────
echo ""
echo "▶ Flutter doctor:"
flutter doctor -v 2>&1 | grep -E "(Flutter|Android|Dart|✓|✗|!|•)" || flutter doctor

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║               Setup Concluído! ✔             ║"
echo "║                                              ║"
echo "║  flutter pub get                             ║"
echo "║  flutter build apk --debug                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
