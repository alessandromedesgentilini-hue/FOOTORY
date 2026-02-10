// lib/models/scout/attribute_grade.dart
//
// Grade A–E para esconder os detalhes (scout).
// A é melhor, E é pior.

enum AttributeGrade { A, B, C, D, E }

extension AttributeGradeX on AttributeGrade {
  String get label {
    switch (this) {
      case AttributeGrade.A:
        return 'A';
      case AttributeGrade.B:
        return 'B';
      case AttributeGrade.C:
        return 'C';
      case AttributeGrade.D:
        return 'D';
      case AttributeGrade.E:
        return 'E';
    }
  }

  // range aproximado 1..10 que representa a letra
  int get min10 {
    switch (this) {
      case AttributeGrade.A:
        return 9;
      case AttributeGrade.B:
        return 7;
      case AttributeGrade.C:
        return 5;
      case AttributeGrade.D:
        return 3;
      case AttributeGrade.E:
        return 1;
    }
  }

  int get max10 {
    switch (this) {
      case AttributeGrade.A:
        return 10;
      case AttributeGrade.B:
        return 8;
      case AttributeGrade.C:
        return 6;
      case AttributeGrade.D:
        return 4;
      case AttributeGrade.E:
        return 2;
    }
  }
}
