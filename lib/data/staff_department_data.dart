import 'package:footory26/models/staff_department.dart';

const List<StaffDepartment> staffDepartments = [
  StaffDepartment(
    name: 'Fábio Henrique',
    role: 'Diretor da Base',
    faceAsset: 'assets/faces/staff/staff_01.png',
    departmentType: DepartmentType.academy,
  ),
  StaffDepartment(
    name: 'Bárbara Lima',
    role: 'Chefe Médica',
    faceAsset: 'assets/faces/staff/staff_02.png',
    departmentType: DepartmentType.medical,
  ),
  StaffDepartment(
    name: 'Cíntia Ogawa',
    role: 'Diretora de Marketing',
    faceAsset: 'assets/faces/staff/staff_03.png',
    departmentType: DepartmentType.marketing,
  ),
  StaffDepartment(
    name: 'Luciana Pontes',
    role: 'Assessora de Imprensa',
    faceAsset: 'assets/faces/staff/staff_04.png',
    departmentType: DepartmentType.communication,
  ),
  StaffDepartment(
    name: 'Débora Dutra',
    role: 'Diretora Financeira',
    faceAsset: 'assets/faces/staff/staff_05.png',
    departmentType: DepartmentType.finance,
  ),
  StaffDepartment(
    name: 'Jorge Silveira',
    role: 'Chefe de Observação',
    faceAsset: 'assets/faces/staff/staff_06.png',
    departmentType: DepartmentType.scouting,
  ),
  StaffDepartment(
    name: 'Denise Moretti',
    role: 'Diretora de Infraestrutura',
    faceAsset: 'assets/faces/staff/staff_07.png',
    departmentType: DepartmentType.sportsComplex,
  ),
  StaffDepartment(
    name: 'Eduardo Schuster',
    role: 'Diretor do Estádio',
    faceAsset: 'assets/faces/staff/staff_08.png',
    departmentType: DepartmentType.stadium,
  ),
  StaffDepartment(
    name: 'Fernando Costa',
    role: 'Diretor de Treinamento',
    faceAsset: 'assets/faces/staff/staff_09.png',
    departmentType: DepartmentType.trainingCenter,
  ),
];

const StaffDepartment _fallbackStaffDepartment = StaffDepartment(
  name: 'Departamento Interno',
  role: 'Responsável do Setor',
  faceAsset: '',
  departmentType: DepartmentType.communication,
);

StaffDepartment getStaffByDepartment(DepartmentType departmentType) {
  for (final staff in staffDepartments) {
    if (staff.departmentType == departmentType) {
      return staff;
    }
  }
  return _fallbackStaffDepartment;
}
