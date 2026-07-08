class FormationAssetService {
  const FormationAssetService();

  String assetPath(String formationId) {
    final normalized = formationId.trim().toLowerCase();

    final family = normalized.split('_').first;

    return 'assets/tactical/formations/$family/$normalized.png';
  }
}
