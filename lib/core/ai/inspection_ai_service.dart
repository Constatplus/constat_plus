import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum InspectionAiMode { automatic, online, offline }

enum InspectionAiEngine { online, offline }

enum InspectionConfidence { high, medium, low }

extension InspectionAiModeLabel on InspectionAiMode {
  String get label => switch (this) {
    InspectionAiMode.automatic => 'Automatique',
    InspectionAiMode.online => 'En ligne',
    InspectionAiMode.offline => 'Hors ligne',
  };
}

extension InspectionAiEngineLabel on InspectionAiEngine {
  String get label => switch (this) {
    InspectionAiEngine.online => 'IA en ligne',
    InspectionAiEngine.offline => 'IA hors ligne',
  };
}

class InspectionAnalysis {
  final Map<String, String> sections;
  final bool hasKitchen;
  final String kitchenGeneral;
  final String worktop;
  final Map<String, String> worktopEquipment;
  final List<Map<String, String>> upperUnits;
  final List<Map<String, String>> lowerUnits;
  final InspectionAiEngine engine;
  final InspectionConfidence confidence;

  const InspectionAnalysis({
    required this.sections,
    required this.hasKitchen,
    required this.kitchenGeneral,
    required this.worktop,
    required this.worktopEquipment,
    required this.upperUnits,
    required this.lowerUnits,
    required this.engine,
    required this.confidence,
  });
}

class TechnicalSuggestion {
  final String termId;
  final String label;
  final String simpleDefinition;
  final String proposedSentence;
  final InspectionConfidence confidence;

  const TechnicalSuggestion({
    required this.termId,
    required this.label,
    required this.simpleDefinition,
    required this.proposedSentence,
    required this.confidence,
  });
}

abstract interface class InspectionAiService {
  InspectionAiEngine get engine;

  Future<InspectionAnalysis> analyzePhotos({
    required String missionId,
    required String missionType,
    required String idempotencyKey,
    required String roomName,
    required String roomType,
    required List<XFile> photos,
  });

  Future<String> improveDescription({
    required String description,
    required String missionType,
  });

  Future<List<TechnicalSuggestion>> suggestVocabulary({
    required String query,
    required String missionType,
    String? element,
  });
}

class InspectionAiServiceSelector {
  final InspectionAiService online;
  final InspectionAiService offline;
  final Future<bool> Function() networkAvailable;

  InspectionAiServiceSelector({
    required this.online,
    required this.offline,
    Future<bool> Function()? networkAvailable,
  }) : networkAvailable = networkAvailable ?? defaultNetworkAvailable;

  Future<InspectionAiService> select(InspectionAiMode mode) async {
    return switch (mode) {
      InspectionAiMode.online => online,
      InspectionAiMode.offline => offline,
      InspectionAiMode.automatic => await networkAvailable() ? online : offline,
    };
  }

  static Future<bool> defaultNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup(
        'supabase.co',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}

class InspectionAiPreferences {
  static const _modeKey = 'inspection_ai_mode';
  static const _onlineConsentKey = 'inspection_ai_online_consent';

  Future<InspectionAiMode> loadMode() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_modeKey);
    return InspectionAiMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => InspectionAiMode.automatic,
    );
  }

  Future<void> saveMode(InspectionAiMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_modeKey, mode.name);
  }

  Future<bool> hasOnlineConsent() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onlineConsentKey) ?? false;
  }

  Future<void> grantOnlineConsent() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onlineConsentKey, true);
  }
}
