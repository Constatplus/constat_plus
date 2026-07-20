class Person {
  final String name;
  final String phone;
  final String email;

  const Person({this.name = '', this.phone = '', this.email = ''});

  Person copyWith({String? name, String? phone, String? email}) {
    return Person(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
