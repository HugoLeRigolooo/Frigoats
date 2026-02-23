import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MinuteurPage extends StatefulWidget {
  final int dureeInitiale;

  const MinuteurPage({super.key, required this.dureeInitiale});

  @override
  State<MinuteurPage> createState() => _MinuteurPageState();
}

class _MinuteurPageState extends State<MinuteurPage> {
  late int _secondesRestantes;
  Timer? _timer;
  bool _estEnCours = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _sonEnCours = false;
  late int _duree;

  @override
  void initState() {
    super.initState();
    _duree = widget.dureeInitiale;
    _secondesRestantes = _duree * 60;
  }

  void _demarrerOuArreter() async {
    if (_sonEnCours) {
      await _audioPlayer.stop();
      setState(() {
        _sonEnCours = false;
        _secondesRestantes = _duree * 60;
      });
      return;
    }

    if (_estEnCours) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondesRestantes > 0) {
            _secondesRestantes--;
          } else {
            _timer?.cancel();
            _estEnCours = false;
            _declencherAlarme();
          }
        });
      });
    }
    setState(() => _estEnCours = !_estEnCours);
  }

  void _declencherAlarme() async {
    setState(() => _sonEnCours = true);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/alarme.mp3'));
  }

  String _formaterTemps() {
    int minutes = _secondesRestantes ~/ 60;
    int secondes = _secondesRestantes % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondes.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Minuteur', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Choisissez la durée :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            
            // Compteur compact
            Center(
              child: SizedBox(
                width: 150,
                child: _buildCounterCard(
                  "⏳ Durée", 
                  _duree, 
                  "min", 
                  (v) => setState(() {
                    _duree = v;
                    if (!_estEnCours) _secondesRestantes = v * 60;
                  })
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Cercle de progression
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: CircularProgressIndicator(
                    value: _secondesRestantes / (_duree * 60),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  ),
                ),
                Text(
                  _formaterTemps(),
                  style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: _demarrerOuArreter,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_estEnCours || _sonEnCours) ? Colors.redAccent : Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: Icon(
                _sonEnCours ? Icons.stop : (_estEnCours ? Icons.pause : Icons.play_arrow), 
                color: Colors.white
              ),
              label: Text(
                _sonEnCours 
                    ? "ARRÊTER L'ALARME" 
                    : (_estEnCours ? "PAUSE" : "LANCER LE MINUTEUR"),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(String title, int value, String unit, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  constraints: const BoxConstraints(), 
                  padding: const EdgeInsets.all(4), 
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.orangeAccent, size: 20),
                ),
                const SizedBox(width: 4),
                Text(
                  "$value$unit",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => onChanged(value + 1),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.orangeAccent, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}