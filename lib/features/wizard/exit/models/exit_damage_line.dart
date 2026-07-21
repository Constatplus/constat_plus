enum ExitDamageOriginType { room, general }

class ExitDamageLine {
  ExitDamageLine({
    required this.id,
    this.sourceRemarkId = '',
    this.sourceRemarkText = '',
    this.originType = ExitDamageOriginType.room,
    this.room,
    this.element,
    this.generalCategory,
    this.remark = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.labor = 0,
    this.depreciationPercent = 0,
    this.tenantSharePercent = 100,
    this.vatPercent = 21,
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? <String>[];

  final String id;
  String sourceRemarkId;
  String sourceRemarkText;
  ExitDamageOriginType originType;
  String? room;
  String? element;
  String? generalCategory;
  String remark;
  double quantity;
  double unitPrice;
  double labor;
  double depreciationPercent;
  double tenantSharePercent;
  double vatPercent;
  final List<String> photoPaths;

  double get totalIncVat {
    final gross = quantity * unitPrice + labor;
    final afterAge = gross * (1 - (depreciationPercent / 100).clamp(0, 1));
    final tenant = afterAge * (tenantSharePercent / 100).clamp(0, 1);
    return tenant * (1 + (vatPercent / 100).clamp(0, 1));
  }
}
