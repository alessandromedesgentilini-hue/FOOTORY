import 'package:footory26/models/institutional_staff_member.dart';

class InstitutionalStaffCatalog {
  InstitutionalStaffCatalog._();

  static const InstitutionalStaffMember president = InstitutionalStaffMember(
    id: 'club_president',
    name: 'Cíntia Sánchez',
    role: InstitutionalStaffRole.president,
    portraitAsset: 'assets/faces/permanent_staff/president.png',
    biography:
        'Cíntia Sánchez construiu sua carreira liderando grandes empresas e '
        'ganhou reconhecimento por transformar organizações através de '
        'planejamento, disciplina financeira e visão de longo prazo. Ao '
        'assumir a presidência do clube, trouxe a mesma filosofia para o '
        'futebol: crescimento sustentável, responsabilidade e decisões bem '
        'fundamentadas. Acredita que um clube vencedor precisa evoluir dentro '
        'e fora das quatro linhas.',
    jobDescription:
        'Representa a presidência do clube e acompanha a evolução do projeto '
        'esportivo. Valoriza investimentos inteligentes, reconhece conquistas '
        'importantes e mantém uma relação próxima com o Diretor de Futebol.',
  );

  static const InstitutionalStaffMember chiefScout = InstitutionalStaffMember(
    id: 'chief_scout',
    name: 'Martín Suárez',
    role: InstitutionalStaffRole.chiefScout,
    portraitAsset: 'assets/faces/permanent_staff/chief_scout.png',
    biography:
        'Martín Suárez era considerado um meia extremamente técnico e dono de '
        'uma leitura de jogo rara. Antes mesmo da bola chegar, parecia saber '
        'como cada jogada terminaria. Uma grave lesão no joelho interrompeu '
        'sua carreira ainda muito jovem, mas revelou outro talento igualmente '
        'especial: identificar jogadores promissores. Desde então percorreu a '
        'América do Sul observando atletas e tornou-se uma das referências em '
        'recrutamento e prospecção de talentos.',
    jobDescription:
        'Coordena todo o processo de observação e recrutamento do clube. Seus '
        'relatórios ajudam a identificar talentos, avaliar riscos e encontrar '
        'o perfil ideal para fortalecer o elenco.',
  );

  static const List<InstitutionalStaffMember> all = <InstitutionalStaffMember>[
    president,
    chiefScout,
  ];

  static InstitutionalStaffMember? byId(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) return null;

    for (final member in all) {
      if (member.id == normalizedId) {
        return member;
      }
    }

    return null;
  }

  static InstitutionalStaffMember? byRole(
    InstitutionalStaffRole role,
  ) {
    for (final member in all) {
      if (member.role == role) {
        return member;
      }
    }

    return null;
  }

  static List<InstitutionalStaffMember> validateCatalog() {
    return all
        .where((member) => !member.hasRequiredData)
        .toList(growable: false);
  }
}
