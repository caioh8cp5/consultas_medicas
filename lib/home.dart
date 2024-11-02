import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendamento de Consulta', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.greenAccent[100], // Verde claro
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('consultas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhuma consulta agendada.', style: TextStyle(color: Colors.black)));
          }

          final consultas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: consultas.length,
            itemBuilder: (context, index) {
              final consulta = consultas[index];
              final title = consulta['title'];

              return ListTile(
                title: Text(title, style: TextStyle(color: Colors.black)), // Texto preto
                tileColor: Colors.white, // Fundo branco
                onTap: () {
                  _showConsultaDetails(context, consulta);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddConsultaDialog(context);
        },
        child: Icon(Icons.add, color: Colors.black), // Ícone preto
        backgroundColor: Colors.greenAccent[100], // Verde claro
      ),
    );
  }

  void _showAddConsultaDialog(BuildContext context, {QueryDocumentSnapshot? consulta}) {
    String title = consulta?['title'] ?? '';
    String name = consulta?['name'] ?? '';
    String telephone = consulta?['telephone'] ?? '';
    String description = consulta?['description'] ?? '';
    DateTime? selectedDate = consulta?['date']?.toDate();
    TimeOfDay? selectedTime = consulta != null ? TimeOfDay.fromDateTime(consulta['date'].toDate()) : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(consulta == null ? 'Adicionar Consulta' : 'Editar Consulta', style: TextStyle(color: Colors.black)), // Título preto
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: 'Título'),
                  onChanged: (value) {
                    title = value;
                  },
                  controller: TextEditingController(text: title),
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Nome'),
                  onChanged: (value) {
                    name = value;
                  },
                  controller: TextEditingController(text: name),
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Telefone'),
                  onChanged: (value) {
                    telephone = value;
                  },
                  controller: TextEditingController(text: telephone),
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Descrição'),
                  onChanged: (value) {
                    description = value;
                  },
                  controller: TextEditingController(text: description),
                  maxLines: 5, // Permite mais linhas para a descrição
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      selectedDate = picked;
                    }
                  },
                  child: Text(selectedDate == null
                      ? 'Escolher data'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      ,style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      selectedTime = picked;
                    }
                  },
                  child: Text(selectedTime == null
                      ? 'Escolher horário'
                      : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      ,style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(consulta == null ? 'Adicionar' : 'Salvar', style: TextStyle(color: Colors.black)), // Texto verde claro
              onPressed: () {
                if (title.isNotEmpty &&
                    name.isNotEmpty &&
                    telephone.isNotEmpty &&
                    description.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null) {
                  // Combina a data e a hora selecionadas
                  DateTime appointmentDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  if (consulta == null) {
                    // Adiciona nova consulta
                    FirebaseFirestore.instance.collection('consultas').add({
                      'title': title,
                      'name': name,
                      'telephone': telephone,
                      'date': appointmentDateTime,
                      'description': description,
                    });
                  } else {
                    // Edita consulta existente
                    FirebaseFirestore.instance
                        .collection('consultas')
                        .doc(consulta.id)
                        .update({
                      'title': title,
                      'name': name,
                      'telephone': telephone,
                      'date': appointmentDateTime,
                      'description': description,
                    }).then((_) {
                      print('Consulta atualizada com sucesso!');
                    }).catchError((error) {
                      print('Erro ao atualizar consulta: $error');
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  print('Por favor, preencha todos os campos!');
                }
              },
            ),
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.black)), // Texto preto
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConsultaDetails(BuildContext context, QueryDocumentSnapshot consulta) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(consulta['title'], style: TextStyle(color: Colors.black)), // Título preto
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${consulta['name']}', style: TextStyle(color: Colors.black)), // Texto preto
                Text('Telefone: ${consulta['telephone']}', style: TextStyle(color: Colors.black)), // Texto preto
                Text('Data: ${consulta['date'].toDate()}', style: TextStyle(color: Colors.black)), // Converte para DateTime
                Text('Descrição: ${consulta['description']}', style: TextStyle(color: Colors.black)), // Texto preto
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar', style: TextStyle(color: Colors.black)), // Texto preto
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAddConsultaDialog(context, consulta: consulta);
              },
              child: Text('Editar', style: TextStyle(color: Colors.black)), // Texto verde claro
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('consultas').doc(consulta.id).delete().then((_) {
                  print('Consulta deletada com sucesso!');
                }).catchError((error) {
                  print('Erro ao deletar consulta: $error');
                });
                Navigator.of(context).pop();
              },
              child: Text('Deletar', style: TextStyle(color: Colors.red)), // Texto vermelho
            ),
          ],
        );
      },
    );
  }
}