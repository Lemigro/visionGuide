# VisionGuide Flutter

Base Flutter criada para testar o VisionGuide com aparência e comportamento mais próximos de um app nativo de celular.

## O que esta base traz

- Tela inicial com atalhos do projeto
- Câmera assistiva em layout mobile
- Chat com IA
- Captura da câmera enviando imagem direto para o chat
- Galeria de mídia
- Perfil com ajustes rápidos
- Navegação inferior em estilo app
- Animações com flutter_animate

## Bibliotecas adicionadas

- flutter_animate
- image_picker

## Como usar

Em uma máquina com Flutter instalado:

```bash
cd flutter-app
flutter create .
flutter pub get
flutter run
```

## Backend

O app consome a API em `../backend` (FastAPI, porta 3001). Configure `OPENAI_API_KEY` no `.env` do backend para chat e descrição visual completos.

## Web (Chrome)

```bash
flutter run -d chrome
```

Para voz no navegador: aba IA → **Testar voz** (uma vez por sessão) → permitir microfone.
