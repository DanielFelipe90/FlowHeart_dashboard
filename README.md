# Admin Dashboard Flutter

Dashboard de monitoramento para administradores. Design minimalista preto e branco.

## Telas

| Tela | Descrição |
|------|-----------|
| 🔐 Login | Autenticação do admin |
| 🟢 Status | Monitor de Frontend, Backend e Banco |
| 👥 Usuários | Buscar, adicionar e deletar usuários |
| 📊 Métricas | KPIs, gráfico de atividade e distribuição |

**Credenciais demo:** `admin@admin.com` / `admin123`

---

## Como Buildar no GitHub Codespaces

### 1. Instalar o Flutter

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter --depth 1
export PATH="$PATH:$HOME/flutter/bin"
flutter precache
```

> Adicione ao `~/.bashrc` para persistir:
> ```bash
> echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
> source ~/.bashrc
> ```

### 2. Instalar dependências do Android (Java)

```bash
sudo apt-get update && sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$PATH:$JAVA_HOME/bin"
```

### 3. Instalar o Android SDK via `sdkmanager`

```bash
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip
unzip tools.zip -d latest
rm tools.zip

export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"

yes | sdkmanager --licenses
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"
```

### 4. Configurar Flutter

```bash
flutter config --android-sdk $ANDROID_SDK_ROOT
flutter doctor --android-licenses
flutter doctor
```

### 5. Instalar dependências do projeto

```bash
flutter pub get
```

### 6. Buildar o APK

```bash
# APK de debug (mais rápido)
flutter build apk --debug

# APK de release
flutter build apk --release
```

O APK gerado estará em:
```
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
```

### 7. Baixar o APK

No Codespaces, clique com botão direito no arquivo APK e escolha **Download**.

---

## Estrutura do Projeto

```
lib/
├── main.dart                  # Entrada do app
├── theme/
│   └── app_theme.dart         # Tema preto/branco
├── models/
│   └── user_model.dart        # Modelo de usuário
├── providers/
│   ├── auth_provider.dart     # Estado de login
│   ├── users_provider.dart    # CRUD de usuários
│   └── metrics_provider.dart  # Métricas e status
└── screens/
    ├── login_screen.dart      # Tela de login
    ├── home_screen.dart       # Shell com bottom nav
    ├── status_screen.dart     # Status dos serviços
    ├── users_screen.dart      # Gerenciar usuários
    └── metrics_screen.dart    # Dashboard de métricas
```

## Dependências

| Pacote | Versão | Uso |
|--------|--------|-----|
| `provider` | ^6.1.1 | Gerenciamento de estado |
| `fl_chart` | ^0.68.0 | Gráfico de linha de atividade |
| `google_fonts` | ^6.1.0 | Fonte Inter |
| `shared_preferences` | ^2.2.2 | Persistência local |
