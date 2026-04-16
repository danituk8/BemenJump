import 'package:flutter/material.dart';
import '../game/bemenjump_game.dart';

// ============================================================
// 4b12: Pantalla de Configuraciones (Settings Screen)
// ============================================================

class SettingsScreen extends StatefulWidget {
  final BemenJumpGame game;
  const SettingsScreen({super.key, required this.game});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC0a0a2a), Color(0xEE0a0a12)],
        ),
      ),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF12122a),
            border: Border.all(color: const Color(0xFF333333)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFf0c040),
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 30),
              
              // Music volume
              _SettingSlider(
                label: 'Music Volume',
                value: widget.game.musicVolume,
                color: const Color(0xFF7a7aff),
                onChanged: (v) {
                  setState(() => widget.game.musicVolume = v);
                },
              ),
              const SizedBox(height: 16),
              
              // SFX volume
              _SettingSlider(
                label: 'SFX Volume',
                value: widget.game.sfxVolume,
                color: const Color(0xFF50c080),
                onChanged: (v) {
                  setState(() => widget.game.sfxVolume = v);
                },
              ),
              const SizedBox(height: 16),
              
              // Particles toggle
              _SettingToggle(
                label: 'Particles',
                value: widget.game.showParticles,
                color: const Color(0xFFf0c040),
                onChanged: (v) {
                  setState(() => widget.game.showParticles = v);
                },
              ),
              const SizedBox(height: 16),
              
              // Game speed
              _SettingSlider(
                label: 'Game Speed',
                value: widget.game.gameSpeed,
                min: 0.5,
                max: 2.0,
                color: const Color(0xFFff5050),
                onChanged: (v) {
                  setState(() => widget.game.gameSpeed = v);
                },
              ),
              
              const SizedBox(height: 30),
              
              // Character selector
              const Text(
                'CHARACTER',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CharBtn('EREN', const Color(0xFF8ab060), CharacterType.eren),
                  const SizedBox(width: 8),
                  _CharBtn('BERU', const Color(0xFF7a7aff), CharacterType.beru),
                  const SizedBox(width: 8),
                  _CharBtn('AI', const Color(0xFFed93b1), CharacterType.ai),
                ],
              ),
              
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  widget.game.overlays.remove('settings');
                  widget.game.overlays.add('main_menu');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF555555)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'BACK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFaaaaaa),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _CharBtn(String name, Color color, CharacterType type) {
    final selected = widget.game.selectedCharacter == type;
    return GestureDetector(
      onTap: () => setState(() => widget.game.selectedCharacter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: selected ? color : const Color(0xFF333333)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 10,
            color: selected ? color : const Color(0xFF666666),
            fontFamily: 'monospace',
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFaaaaaa),
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFaaaaaa),
              fontFamily: 'monospace',
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 44,
            height: 22,
            decoration: BoxDecoration(
              color: value ? color.withOpacity(0.2) : const Color(0xFF222222),
              border: Border.all(
                color: value ? color : const Color(0xFF444444),
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: value ? color : const Color(0xFF555555),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
