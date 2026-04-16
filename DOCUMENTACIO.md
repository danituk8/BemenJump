# BemenJump - Documentació Tècnica
## Videojoc estil JumpKing amb Flutter Flame

---

## 4b1. GameWidget i GameLoop

### GameWidget
El `GameWidget` es troba a **`lib/main.dart`** (línia 72). És el widget de Flutter que fa de pont entre el framework Flutter i el motor Flame. Embolcalla la instància de `BemenJumpGame` i la renderitza dins del arbre de widgets de Flutter.

```dart
GameWidget<BemenJumpGame>(
  game: game,
  loadingBuilder: ...,
  backgroundBuilder: ...,
  overlayBuilderMap: ...,
  initialActiveOverlays: const ['main_menu'],
)
```

### GameLoop
El `GameLoop` **sí existeix** — està integrat dins de `FlameGame` (la classe pare del nostre `BemenJumpGame` a **`lib/game/bemenjump_game.dart`**). El GameLoop és el bucle principal que s'executa contínuament i crida dues funcions cada frame:

1. **`update(double dt)`** — lògica del joc
2. **`render(Canvas canvas)`** — dibuixar a pantalla

El GameLoop es pot pausar amb `pauseEngine()` i reprendre amb `resumeEngine()`.

---

## 4b2. Render i Update del GameWidget

### Update (`update(double dt)`)
Ubicació: **`lib/game/bemenjump_game.dart`** línia 109 i **`lib/components/player.dart`** línia 195

La funció `update` es crida cada frame amb el delta time (`dt`) — el temps transcorregut des del frame anterior. Aquí es processa:
- **Física**: gravetat, velocitat, posició del jugador
- **Input**: tecles premudes, càrrega del salt
- **Lògica de joc**: detecció de caiguda, puntuació, càmera
- **Col·lisions**: comprovació d'interseccions amb plataformes

```dart
@override
void update(double dt) {
  // Aplicar gravetat
  velocity.y = (velocity.y + gravity * dt).clamp(-1000, maxFallSpeed);
  // Moure el jugador
  position.x += velocity.x * dt;
  position.y += velocity.y * dt;
}
```

### Render (`render(Canvas canvas)`)
Ubicació: **`lib/game/bemenjump_game.dart`** línia 124 i cada component individualment

La funció `render` es crida cada frame per dibuixar el joc. FlameGame itera tots els components fills i crida el seu `render()`:
- `BackgroundComponent.render()` — dibuixa el fons amb gradient i estrelles
- `PlatformBlock.render()` — dibuixa cada plataforma amb detalls pixel
- `Player.render()` — dibuixa el sprite animat del personatge (heretat de SpriteAnimationGroupComponent)
- `ParticleManager.render()` — dibuixa les partícules d'efectes

---

## 4b3. Components: Visibility, Position, Size, Scale, Anchor

### Position (`Vector2 position`)
Ubicació: Totes les classes que hereden de `PositionComponent`
- **Player** (`lib/components/player.dart` línia 62): `position: Vector2(200, 600)` — posició inicial del jugador al món
- **PlatformBlock** (`lib/components/platform_block.dart`): cada plataforma té la seva posició al món

### Size (`Vector2 size`)
- **Player**: `size: Vector2(48, 48)` — 48x48 píxels per sprite
- **PlatformBlock**: varia entre 40-140 d'ample i 14 d'alt

### Scale (`Vector2 scale`)
- **Player** (`lib/components/player.dart` línia 219): `scale.x = facing.toDouble()` — s'utilitza per girar l'sprite horitzontalment. Quan `facing = -1`, l'sprite es miralla per mirar a l'esquerra.

### Anchor (`Anchor`)
- **Player**: `anchor: Anchor.bottomCenter` — el punt de referència és al centre-baix, ideal per a plataformes ja que la posició Y coincideix amb els peus
- **PlatformBlock**: `anchor: Anchor.topLeft` — referència a dalt-esquerra

### Visibility
- En Flame, la visibilitat es controla amb la propietat `isVisible` heredada de `Component`. Quan `isVisible = false`, el mètode `render()` no es crida. No la sobreescrivim explícitament perquè tots els components són sempre visibles, però es podria usar per ocultar elements (ex: plataformes fora de pantalla).

---

## 4b4. SpriteComponent, Animation, AnimationGroup

### SpriteComponent
Base class de Flame per renderitzar un Sprite (imatge 2D). El nostre `PlatformBlock` actua com a SpriteComponent personalitzat renderitzant formes pixel art directament.

### SpriteAnimation
Ubicació: **`lib/components/player.dart`** línia 92-106

Una `SpriteAnimation` és una seqüència de sprites que es reprodueixen a una velocitat determinada. Creem les animacions proceduralment:

```dart
Future<SpriteAnimation> _createAnimation(
  PlayerState state, int frameCount, double stepTime,
) async {
  final sprites = <Sprite>[];
  for (int i = 0; i < frameCount; i++) {
    // Crea un sprite per cada frame
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    _drawCharacterFrame(canvas, state, i);
    final picture = recorder.endRecording();
    final image = await picture.toImage(48, 48);
    sprites.add(Sprite(image));
  }
  return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
}
```

### AnimationGroup
Ubicació: **`lib/components/player.dart`** línia 80-91 i línia 86

El `Player` hereta de `SpriteAnimationGroupComponent<PlayerState>` que permet agrupar múltiples animacions i canviar entre elles amb un enum:

```dart
// Definim les animacions per cada estat
animations = {
  PlayerState.idle: idle,   // 4 frames, 0.2s
  PlayerState.run: run,     // 6 frames, 0.1s
  PlayerState.jump: jump,   // 2 frames, 0.15s
  PlayerState.fall: fall,   // 2 frames, 0.15s
};

// Canviem d'animació segons l'estat
current = PlayerState.run; // Canvia a l'animació de córrer
```

---

## 4b5. Generació d'Elements

**Sí**, hi ha generació procedural d'elements en múltiples llocs:

1. **LevelManager** (`lib/components/level_manager.dart`): Genera les plataformes proceduralment segons el nivell. Utilitza `Random()` per variar posició, mida i tipus de plataforma.

2. **ParticleManager** (`lib/components/particle_manager.dart`): Genera partícules dinàmicament quan el jugador aterra, carrega el salt, o arriba a la meta.

3. **BackgroundComponent** (`lib/components/background_component.dart`): Genera 200 estrelles amb posicions aleatòries per l'efecte de fons parallax.

---

## 4b6. Shape, Circle, Arithmetic

### Shape (Rectangle)
Ubicació: **`lib/components/player.dart`** línia 82 i **`lib/components/platform_block.dart`** línia 33

S'utilitzen `RectangleHitbox` per la detecció de col·lisions. Aquesta és una forma geomètrica rectangular que el sistema de física utilitza per detectar superposicions.

```dart
add(RectangleHitbox(
  size: Vector2(28, 44),
  position: Vector2(10, 2),
));
```

### Circle
No s'utilitza `CircleHitbox` directament en el joc, ja que les plataformes i el jugador tenen formes rectangulars. Flame proporciona `CircleHitbox` per objectes circulars, però no és adequat per un plataformer.

### Arithmetic
Ubicació: Extensivament a tot el codi:

- **Física del jugador** (`player.dart` línia 200): `velocity.y = (velocity.y + gravity * dt)` — càlcul de gravetat
- **Càrrega del salt** (`player.dart` línia 207): `jumpForce = minJumpForce + (maxJumpForce - minJumpForce) * chargeAmount`
- **Generació de nivells** (`level_manager.dart`): Fórmules per espaiat, probabilitats, clamp de posicions
- **Partícules** (`particle_manager.dart`): `p.x += p.vx * dt; p.vy += 200 * dt` — física de partícules
- **Parallax** (`background_component.dart`): `star.y + cameraY * (1 - star.parallaxFactor)`

---

## 4b7. Comanda per a Desplegar a GitHub

Per desplegar el projecte Flutter a **GitHub Pages**:

```bash
# 1. Construir la versió web
flutter build web --release --base-href "/bemenjump/"

# 2. Inicialitzar git si no existeix
git init
git add .
git commit -m "BemenJump v1.0"

# 3. Afegir el repositori remot
git remote add origin https://github.com/USUARI/bemenjump.git

# 4. Pujar a la branca principal
git push -u origin main

# 5. Desplegar la carpeta build/web a GitHub Pages
# Opció A: Utilitzar el paquet peanut
dart pub global activate peanut
peanut --directory build/web

# Opció B: Manual amb gh-pages
git subtree push --prefix build/web origin gh-pages
```

Alternativament, es pot configurar **GitHub Actions** per fer el build automàticament.

---

## 4b8. loadingBuilder, backgroundBuilder, OverlayBuilderMap

Tots tres es troben a **`lib/main.dart`** dins del `GameWidget`:

### loadingBuilder (línia 76)
Es mostra mentre el joc carrega els assets. Renderitza un indicador de càrrega animat:
```dart
loadingBuilder: (context) => const Center(
  child: Column(
    children: [
      CircularProgressIndicator(color: Color(0xFFf0c040)),
      Text('Loading BemenJump...'),
    ],
  ),
),
```

### backgroundBuilder (línia 89)
Renderitza darrere del canvas del joc. Creem un gradient fosc:
```dart
backgroundBuilder: (context) => Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0a0a2a), Color(0xFF1a0a30), Color(0xFF0a0a12)],
    ),
  ),
),
```

### overlayBuilderMap (línia 100)
Mapeja claus de text a widgets Flutter que es superposen al joc:
```dart
overlayBuilderMap: {
  'main_menu': (context, game) => MainMenu(game: game),
  'level_select': (context, game) => LevelSelect(game: game),
  'settings': (context, game) => SettingsScreen(game: game),
  'pause_menu': (context, game) => PauseMenu(game: game),
  'game_over': (context, game) => GameOver(game: game),
  'hud': (context, game) => GameHud(game: game),
},
```

Per mostrar/amagar overlays: `game.overlays.add('pause_menu')` / `game.overlays.remove('pause_menu')`

---

## 4b9. Canvi de Personatges

Els personatges originals del tutorial (naus/EmberQuest) s'han canviat per **3 personatges personalitzats en pixel art**:

1. **Eren Yaeger** (Attack on Titan) — Estil pixel chibi amb jaqueta fosca, equip ODM, i cabell marró
2. **Beru** (Solo Leveling) — Soldat ombra insectoide amb brillantors blau/morat i urpes
3. **Ai Hoshino** (Oshi no Ko) — Idol chibi amb vestit rosa, cabell morat, i micròfon

Cada personatge es dibuixa proceduralment a **`lib/components/player.dart`** amb les funcions:
- `_drawEren()` (línia 115)
- `_drawBeru()` (línia 152)
- `_drawAi()` (línia 186)

El jugador pot seleccionar el personatge des del **menú principal** o la **pantalla de configuració**.

---

## 4b10. Canvi del Color de Fons

El color de fons es personalitza en **dos llocs**:

1. **`lib/game/bemenjump_game.dart`** línia 75:
```dart
@override
Color backgroundColor() => const Color(0xFF0a0a12); // Negre-blau fosc
```

2. **`lib/components/background_component.dart`**: Gradient dinàmic que canvia amb l'alçada del jugador, des de blau fosc (baix) fins a negre espacial (alt).

3. **`lib/main.dart`** línia 89: `backgroundBuilder` amb gradient de Flutter darrere del canvas.

---

## 4b11. Pausa del Joc

La pausa s'implementa a **`lib/game/bemenjump_game.dart`** línia 92-99:

```dart
// Pausar el joc
void pauseGame() {
  if (isGameActive) {
    pauseEngine();  // <-- ATURA EL GAMELOOP (update + render deixen d'executar-se)
    overlays.add('pause_menu');  // Mostra el menú de pausa
  }
}

// Reprendre el joc
void resumeGame() {
  overlays.remove('pause_menu');
  resumeEngine();  // <-- REINICIA EL GAMELOOP
}
```

- **`pauseEngine()`**: Mètode de FlameGame que atura el GameLoop completament
- **`resumeEngine()`**: Mètode que reinicia el GameLoop
- Es pot pausar amb **ESC** (teclat) o el botó **⏸** al HUD
- L'overlay `PauseMenu` (`lib/overlays/pause_menu.dart`) es mostra per sobre del joc congelat

---

## 4b12. Pantalla d'Inici, Selector de Nivell, Configuració

### Pantalla d'Inici (Main Menu)
**`lib/overlays/main_menu.dart`**
- Títol "BEMEN JUMP" amb efecte glow
- Selector visual dels 3 personatges (Eren, Beru, Ai)
- Botons: PLAY, SELECT LEVEL, SETTINGS
- Controls del joc explicats a baix

### Selector de Nivell (Level Select)
**`lib/overlays/level_select.dart`**
- 3 nivells amb targetes visuals:
  - **LV.1 "THE CLIMB"** — Fàcil, plataformes amples
  - **LV.2 "ICE TOWER"** — Mig, plataformes de gel
  - **LV.3 "HELL PEAK"** — Difícil estil JumpKing real
- Descripció de cada nivell amb dificultats

### Pantalla de Configuració (Settings)
**`lib/overlays/settings_screen.dart`**
- **Music Volume**: slider 0-100%
- **SFX Volume**: slider 0-100%
- **Particles**: toggle on/off
- **Game Speed**: slider 50-200%
- **Character Select**: botons per canviar personatge

---

## Estructura del Projecte

```
bemenjump/
├── lib/
│   ├── main.dart                          # Entry point + GameWidget
│   ├── game/
│   │   └── bemenjump_game.dart            # FlameGame principal
│   ├── components/
│   │   ├── player.dart                    # Jugador amb sprites i física
│   │   ├── platform_block.dart            # Plataformes amb col·lisió
│   │   ├── level_manager.dart             # Generació procedural de nivells
│   │   ├── background_component.dart      # Fons parallax
│   │   └── particle_manager.dart          # Sistema de partícules
│   ├── overlays/
│   │   ├── main_menu.dart                 # 4b12: Menú principal
│   │   ├── level_select.dart              # 4b12: Selector de nivell
│   │   ├── settings_screen.dart           # 4b12: Configuració
│   │   ├── pause_menu.dart                # 4b11: Menú de pausa
│   │   ├── game_over.dart                 # Pantalla de derrota
│   │   └── game_hud.dart                  # HUD en joc
│   └── utils/
└── pubspec.yaml                           # Dependències (Flame)
```
