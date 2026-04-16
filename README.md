# BemenJump 🎮

Un videojoc estil **JumpKing** desenvolupat amb **Flutter Flame** com a pràctica de desenvolupament de videojocs.

## Personatges

| Personaje | Origen | Estilo |
|-----------|--------|--------|
| **Eren Yaeger** | Attack on Titan | Pixel art clásico |
| **Beru** | Solo Leveling | Sombra insectoide con aura |
| **Ai Hoshino** | Oshi no Ko | Chibi kawaii con micrófono |

## Mecánicas

- **Salto cargado** estilo JumpKing: mantén SPACE para cargar, suelta para saltar
- **Sin control aéreo**: una vez saltas, no puedes cambiar de dirección (¡como JumpKing!)
- **3 niveles** de dificultad progresiva
- **Plataformas especiales**: normales, hielo, trampolín, desmoronables, y meta dorada

## Controles

| Acción | Tecla |
|--------|-------|
| Mover | ← → / A D |
| Cargar salto | SPACE (mantener) |
| Saltar | SPACE (soltar) |
| Pausa | ESC |

## Ejecutar

```bash
flutter pub get
flutter run -d chrome
```

## Deploy a GitHub Pages

```bash
flutter build web --release --base-href "/BemenJump/"
git subtree push --prefix build/web origin gh-pages
```

## Estructura

```
lib/
├── main.dart                    # Entry point + GameWidget
├── game/
│   └── bemenjump_game.dart      # FlameGame principal
├── components/
│   ├── player.dart              # Jugador con sprites y física
│   ├── platform_block.dart      # Plataformas con colisión
│   ├── level_manager.dart       # Generación procedural
│   ├── background_component.dart # Fondo parallax
│   └── particle_manager.dart    # Sistema de partículas
└── overlays/
    ├── main_menu.dart           # Menú principal
    ├── level_select.dart        # Selector de nivel
    ├── settings_screen.dart     # Configuración
    ├── pause_menu.dart          # Pausa
    ├── game_over.dart           # Game Over / Win
    └── game_hud.dart            # HUD en juego
```

## Documentación Técnica

Ver [DOCUMENTACIO.md](DOCUMENTACIO.md) para las respuestas detalladas a los puntos 4b1-4b12 de la práctica.

## Demo

Abrir `bemenjump_playable.html` en cualquier navegador para jugar la versión web standalone.
