class Profile{
  String? id;
  String? email;
  String? name;

  Profile();

  Profile.fromMap(r) {
    id=r['id'];
    email=r['email'];
    name=r['name'];
  }

  @override
  String toString() {
    return 'id: $id,  email: $email, name: $name ';
  }
}