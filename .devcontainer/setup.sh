#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  setup.sh — Instala Flutter + Android SDK no GitHub Codespace
#  Uso: bash .devcontainer/setup.sh
# ══════════════════════════════════════════════════════════════
set -euo pipefail

# ── Versões ────────────────────────────────────────────────────
FLUTTER_VERSION="3.24.5"
ANDROID_CMDTOOLS_BUILD="11076708"
ANDROID_PLATFORM="android-34"
ANDROID_BUILD_TOOLS="34.0.0"

# ── Caminhos ───────────────────────────────────────────────────
FLUTTER_DIR="$HOME/flutter"
ANDROID_DIR="$HOME/android-sdk"
CMDTOOLS_DIR="$ANDROID_DIR/cmdline-tools/latest"

# ── Cores ──────────────────────────────────────────────────────
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

step()  { echo -e "\n${CYAN}▶ $1${RESET}"; }
ok()    { echo -e "${GREEN}✔ $1${RESET}"; }
warn()  { echo -e "${YELLOW}⚠ $1${RESET}"; }
die()   { echo -e "${RED}✖ $1${RESET}"; exit 1; }

echo -e "\n${CYAN}╔══════════════════════════════════════════════╗"
echo -e "║   Flutter Admin Dashboard — Setup Script    ║"
echo -e "╚══════════════════════════════════════════════╝${RESET}\n"

# ══════════════════════════════════════════════════════════════
# 1. Java 17
# ══════════════════════════════════════════════════════════════
step "Verificando Java..."
if ! java -version &>/dev/null; then
  step "Instalando Java 17..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq openjdk-17-jdk
fi
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
export JAVA_HOME="$JAVA_HOME_PATH"
ok "Java: $(java -version 2>&1 | head -1)"

# ══════════════════════════════════════════════════════════════
# 2. Dependências de sistema
# ══════════════════════════════════════════════════════════════
step "Instalando dependências de sistema..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  curl wget git unzip xz-utils zip \
  libglu1-mesa lib32stdc++6 lib32z1 \
  clang cmake ninja-build pkg-config \
  2>/dev/null || true
ok "Dependências instaladas"

# ══════════════════════════════════════════════════════════════
# 3. Flutter SDK
# ══════════════════════════════════════════════════════════════
step "Configurando Flutter SDK $FLUTTER_VERSION..."
if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
  step "Baixando Flutter (pode demorar ~2 min)..."
  wget -q --show-progress \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -O /tmp/flutter.tar.xz || die "Falha ao baixar Flutter"
  step "Extraindo Flutter..."
  tar -xf /tmp/flutter.tar.xz -C "$HOME"
  rm /tmp/flutter.tar.xz
  ok "Flutter extraído em $FLUTTER_DIR"
else
  ok "Flutter já instalado (pulando download)"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Pré-carrega binários do Flutter/Dart
step "Inicializando Flutter (primeira execução)..."
flutter precache --no-web --no-ios --no-macos --no-windows --no-linux \
  2>/dev/null || true
ok "Flutter: $(flutter --version | head -1)"

# ══════════════════════════════════════════════════════════════
# 4. Android Command-line Tools
# ══════════════════════════════════════════════════════════════
step "Configurando Android SDK..."
if [ ! -f "$CMDTOOLS_DIR/bin/sdkmanager" ]; then
  step "Baixando Android Command-line Tools..."
  mkdir -p "$ANDROID_DIR/cmdline-tools"
  wget -q --show-progress \
    "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDTOOLS_BUILD}_latest.zip" \
    -O /tmp/cmdtools.zip || die "Falha ao baixar Android cmdline-tools"
  step "Extraindo cmdline-tools..."
  unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools-extract
  mkdir -p "$CMDTOOLS_DIR"
  mv /tmp/cmdtools-extract/cmdline-tools/* "$CMDTOOLS_DIR/"
  rm -rf /tmp/cmdtools.zip /tmp/cmdtools-extract
  ok "Android cmdline-tools instalados"
else
  ok "Android cmdline-tools já instalados (pulando download)"
fi

export ANDROID_SDK_ROOT="$ANDROID_DIR"
export PATH="$CMDTOOLS_DIR/bin:$ANDROID_DIR/platform-tools:$PATH"

# ══════════════════════════════════════════════════════════════
# 5. Android SDK packages
# ══════════════════════════════════════════════════════════════
step "Aceitando licenças Android SDK..."
yes | sdkmanager --sdk_root="$ANDROID_DIR" --licenses > /dev/null 2>&1 || true

step "Instalando platforms;$ANDROID_PLATFORM e build-tools;$ANDROID_BUILD_TOOLS..."
sdkmanager --sdk_root="$ANDROID_DIR" \
  "platforms;$ANDROID_PLATFORM" \
  "build-tools;$ANDROID_BUILD_TOOLS" \
  "platform-tools" \
  2>&1 | grep -v "^Checking\|^Unzipping\|^\[" || true
ok "Android SDK configurado"

# ══════════════════════════════════════════════════════════════
# 6. Conectar Flutter ao Android SDK
# ══════════════════════════════════════════════════════════════
step "Configurando Flutter com Android SDK..."
flutter config --android-sdk "$ANDROID_DIR" --no-analytics > /dev/null 2>&1
yes | flutter doctor --android-licenses > /dev/null 2>&1 || true
ok "Flutter configurado"

# ══════════════════════════════════════════════════════════════
# 7. Persistir PATH no .bashrc e .profile
# ══════════════════════════════════════════════════════════════
step "Salvando variáveis de ambiente..."

EXPORT_BLOCK="
# ── Flutter & Android SDK ────────────────────────────────────
export JAVA_HOME=\"$JAVA_HOME\"
export FLUTTER_ROOT=\"$FLUTTER_DIR\"
export ANDROID_SDK_ROOT=\"$ANDROID_DIR\"
export PATH=\"\$FLUTTER_ROOT/bin:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:\$ANDROID_SDK_ROOT/platform-tools:\$PATH\"
# ─────────────────────────────────────────────────────────────"

for RC in "$HOME/.bashrc" "$HOME/.profile"; do
  if ! grep -q "FLUTTER_ROOT" "$RC" 2>/dev/null; then
    echo "$EXPORT_BLOCK" >> "$RC"
    ok "PATH salvo em $RC"
  else
    warn "PATH já existe em $RC (pulando)"
  fi
done

# ══════════════════════════════════════════════════════════════
# 8. flutter pub get
# ══════════════════════════════════════════════════════════════
step "Instalando dependências do projeto..."
WORKDIR=$(find /workspaces -maxdepth 2 -name "pubspec.yaml" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo ".")
cd "$WORKDIR"
flutter pub get
ok "Dependências instaladas"

# ══════════════════════════════════════════════════════════════
# 9. Flutter doctor — resumo final
# ══════════════════════════════════════════════════════════════
echo ""
step "Flutter doctor:"
flutter doctor 2>&1

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗"
echo -e "║            Setup concluído com sucesso!     ║"
echo -e "╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  Recarregue o terminal:  ${CYAN}source ~/.bashrc${RESET}"
echo ""
echo -e "  Depois rode:"
echo -e "    ${CYAN}flutter build apk --debug${RESET}     ← mais rápido"
echo -e "    ${CYAN}flutter build apk --release${RESET}   ← para distribuir"
echo ""
echo -e "  O APK ficará em:"
echo -e "    ${CYAN}build/app/outputs/flutter-apk/${RESET}"
echo ""
