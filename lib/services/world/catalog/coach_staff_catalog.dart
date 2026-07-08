import 'package:footory26/models/coach_staff.dart';

class CoachStaffCatalog {
  static const all = <CoachStaff>[
    CoachStaff(
      id: 'gegenpress',
      tacticalIdentityId: 'gegenpress',
      name: 'Gegenpress',
      shortDescription:
          'Pressão intensa, recuperação rápida da bola e transições agressivas.',
      coach: CoachStaffMember(
        name: 'Sedjout Toure',
        role: 'Treinador',
        nationalityCode: 'ci',
        imageAsset: 'assets/faces/coaches/gegenpress/coach.png',
      ),
      assistant1: CoachStaffMember(
        name: 'Pieter Dekker',
        role: 'Auxiliar',
        nationalityCode: 'nl',
        imageAsset: 'assets/faces/coaches/gegenpress/assistant_1.png',
      ),
      assistant2: CoachStaffMember(
        name: 'Juan Luis Quispe',
        role: 'Assistente',
        nationalityCode: 'pe',
        imageAsset: 'assets/faces/coaches/gegenpress/assistant_2.png',
      ),
    ),
    CoachStaff(
      id: 'set_piece',
      tacticalIdentityId: 'set_piece',
      name: 'Bola Parada',
      shortDescription:
          'Especialistas em lances decisivos: escanteios, faltas, laterais e organização aérea.',
      coach: CoachStaffMember(
        name: 'Helmut Schuster',
        role: 'Treinador',
        nationalityCode: 'de',
        imageAsset: 'assets/faces/coaches/set_piece/coach.png',
      ),
      assistant1: CoachStaffMember(
        name: 'Alessio Guerra',
        role: 'Auxiliar',
        nationalityCode: 'it',
        imageAsset: 'assets/faces/coaches/set_piece/assistant_1.png',
      ),
      assistant2: CoachStaffMember(
        name: 'Luiz Roberto',
        role: 'Assistente',
        nationalityCode: 'br',
        imageAsset: 'assets/faces/coaches/set_piece/assistant_2.png',
      ),
    ),
    CoachStaff(
      id: 'support_play',
      tacticalIdentityId: 'support_play',
      name: 'Jogo Apoiado',
      shortDescription:
          'Equipe compacta, aproximação constante, paciência ofensiva e jogo coletivo em espaços curtos.',
      coach: CoachStaffMember(
        name: 'Alex Bianchi',
        role: 'Treinador',
        nationalityCode: 'br',
        imageAsset: 'assets/faces/coaches/support_play/coach.png',
      ),
      assistant1: CoachStaffMember(
        name: 'Gunnarsson',
        role: 'Auxiliar',
        nationalityCode: 'is',
        imageAsset: 'assets/faces/coaches/support_play/assistant_1.png',
      ),
      assistant2: CoachStaffMember(
        name: 'Daichi Kawa',
        role: 'Assistente',
        nationalityCode: 'jp',
        imageAsset: 'assets/faces/coaches/support_play/assistant_2.png',
      ),
    ),
    CoachStaff(
      id: 'tiki_taka',
      tacticalIdentityId: 'tiki_taka',
      name: 'Tiki-Taka',
      shortDescription:
          'Posse de bola, circulação rápida, domínio territorial e controle do ritmo da partida.',
      coach: CoachStaffMember(
        name: 'Andrés Uribe',
        role: 'Treinador',
        nationalityCode: 'co',
        imageAsset: 'assets/faces/coaches/tiki_taka/coach.png',
      ),
      assistant1: CoachStaffMember(
        name: 'Jun Yang',
        role: 'Auxiliar',
        nationalityCode: 'cn',
        imageAsset: 'assets/faces/coaches/tiki_taka/assistant_1.png',
      ),
      assistant2: CoachStaffMember(
        name: 'Iker Ibarra',
        role: 'Assistente',
        nationalityCode: 'es',
        imageAsset: 'assets/faces/coaches/tiki_taka/assistant_2.png',
      ),
    ),
    CoachStaff(
      id: 'tactical_periodization',
      tacticalIdentityId: 'tactical_periodization',
      name: 'Periodização Tática',
      shortDescription:
          'Treino estruturado, organização coletiva, evolução gradual e consistência ao longo da temporada.',
      coach: CoachStaffMember(
        name: 'Luis Uribe',
        role: 'Treinador',
        nationalityCode: 'co',
        imageAsset: 'assets/faces/coaches/tactical_periodization/coach.png',
      ),
      assistant1: CoachStaffMember(
        name: 'Fabio Campanini',
        role: 'Auxiliar',
        nationalityCode: 'it',
        imageAsset:
            'assets/faces/coaches/tactical_periodization/assistant_1.png',
      ),
      assistant2: CoachStaffMember(
        name: 'Tenoch Rivera',
        role: 'Assistente',
        nationalityCode: 'mx',
        imageAsset:
            'assets/faces/coaches/tactical_periodization/assistant_2.png',
      ),
    ),
  ];

  static CoachStaff? byId(String id) {
    for (final staff in all) {
      if (staff.id == id) return staff;
    }

    return null;
  }

  static CoachStaff fallback() {
    return all.first;
  }
}
