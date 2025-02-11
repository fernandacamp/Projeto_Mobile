class PetRepository {
  // Lista de dados simulados de pets
  List<Map<String, dynamic>> pets = [
    {
      'id': 1,
      'name': 'Max',
      'species': 'Cachorro',
      'age': 3,
      'owner': 'João Silva',
      'address': 'Rua A, 123',
      'service': 'Transporte'
    },
    {
      'id': 2,
      'name': 'Mabel',
      'species': 'Gato',
      'age': 10,
      'owner': 'Joana Alves',
      'address': 'Rua C, 1234',
      'service': 'Hospedagem'
    },
     {
      'id': 3,
      'name': 'Bella',
      'species': 'Gato',
      'age': 2,
      'owner': 'Maria Oliveira',
      'address': 'Rua B, 456',
      'service': 'Hospedagem'
    },
     {
      'id': 4,
      'name': 'Bella',
      'species': 'Gato',
      'age': 2,
      'owner': 'Maria Oliveira',
      'address': 'Rua B, 456',
      'service': 'Hospedagem'
    }, {
      'id': 5,
      'name': 'Bella',
      'species': 'Gato',
      'age': 2,
      'owner': 'Maria Oliveira',
      'address': 'Rua B, 456',
      'service': 'Hospedagem'
    },
     {
      'id': 6,
      'name': 'Bella',
      'species': 'Gato',
      'age': 2,
      'owner': 'Maria Oliveira',
      'address': 'Rua B, 456',
      'service': 'Hospedagem'
    },

  ];

  // Método para obter todos os pets
  List<Map<String, dynamic>> getAllPets() {
    return pets;
  }

  // Método para buscar um pet por ID
  Map<String, dynamic>? getPetById(int id) {
    return pets.firstWhere((pet) => pet['id'] == id);
  }
}