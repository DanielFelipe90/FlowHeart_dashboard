#!/usr/bin/env bash
# Executado toda vez que o container inicia (não apenas na criação).
# Garante que o PATH esteja disponível mesmo após rebuild.

FLUTTER_ROOT="$HOME/flutter"
ANDROID_SDK_ROOT="$HOME/android-sdk"

export PATH="$FLUTTER_ROOT/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"

# Verifica se o Flutter está pronto
if [ -f "$FLUTTER_ROOT/bin/flutter" ]; then
  echo "✔ Flutter disponível: $(flutter --version --machine 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('frameworkVersion',''))" 2>/dev/null || echo 'ok')"
else
  echo "⚠ Flutter não encontrado. Execute: bash .devcontainer/post-create.sh"
fi
