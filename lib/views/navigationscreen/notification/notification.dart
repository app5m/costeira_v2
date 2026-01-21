import 'package:flutter/material.dart';

class NotificacoesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notificacoes = [
    {
      'titulo': 'Chuva acumulada atualizada ',
      'icone': '🌧️',
      'hora': '18:52',
      'descricao': 'Novo registro de chuva disponível.',
    },
    {
      'titulo': 'Alerta de estiagem ',
      'icone': '☀️',
      'hora': '18:52',
      'descricao': 'Volume de chuva abaixo da média.',
    },
    {
      'titulo': 'Novo nascimento registrado ',
      'icone': '🐮',
      'hora': '25 de set.',
      'descricao':
      'Um novo bezerro foi adicionado ao rebanho.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Garante fundo branco na tela toda
      appBar: AppBar(
        backgroundColor: Color(0xFF1B7A45),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);

          },
          color: Colors.white,
        ),
        title: Text(
          'Notificações ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),

      ),
      body: Container(
        color: Colors.white, // Fundo branco reforçado
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: notificacoes.length,
          itemBuilder: (context, index) {
            final notificacao = notificacoes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        notificacao['titulo'],
                        style: TextStyle(
                          color: const Color(0xFF22222C),
                          fontSize: 12,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      if (notificacao['icone'] != null)
                        Text(
                          notificacao['icone'],
                          style: TextStyle(
                            color: const Color(0xFF22222C),
                            fontSize: 12,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      SizedBox(width: 8),
                      Text(
                        notificacao['hora'],
                        style: TextStyle(
                          color: const Color(0xFF525252),
                          fontSize: 12,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    notificacao['descricao'],
                    style: TextStyle(
                      color: const Color(0xFF525252),
                      fontSize: 12,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
