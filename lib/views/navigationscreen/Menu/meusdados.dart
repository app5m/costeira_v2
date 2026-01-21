import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class MeusDados extends StatefulWidget {
  const MeusDados({super.key});

  @override
  State<MeusDados> createState() => _MeusDadosState();
}

class _MeusDadosState extends State<MeusDados> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },child: Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: Text(
          'Meus dados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Fazenda"),
              Tab(text: "Meus dados"),
            ],
            onTap: (int inde) {
              setState(() {
                index = inde;
              });
            },
            automaticIndicatorColorAdjustment: false,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              //   color: Colors.black,
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              // color: Colors.green,
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.grey,
            labelColor: Colors.black,
            indicatorColor: MyColors.colorPrimary2,
          ),
          const SizedBox(height: 16),
          if(index == 0)
            Expanded(child: FazendaTab()),
          if(index == 1)
            Expanded(child: MeusDadosTab())

        ],
      ),
    );
  }
}


class FazendaTab extends StatefulWidget {
  const FazendaTab({super.key});

  @override
  State<FazendaTab> createState() => _FazendaTabState();
}

class _FazendaTabState extends State<FazendaTab> {
  final _formKey = GlobalKey<FormState>();

  final _nomeFazendaCtrl = TextEditingController(text: 'Fazenda Santa Helena');
  final _produtoresCtrl =
  TextEditingController(text: 'João Mendes, Paulo Ribeiro');
  final _cidadeCtrl = TextEditingController(text: 'Uberaba');
  final _estadoCtrl = TextEditingController(text: 'MG');
  final _atividadesCtrl =
  TextEditingController(text: 'Lavoura e Pecuária');
  final _areaTotalCtrl = TextEditingController(text: '980 ha');
  final _areaVeraoCtrl = TextEditingController(text: '640 ha');
  final _areaInvernoCtrl = TextEditingController(text: '420 ha');
  final _sistemaProdutivoCtrl =
  TextEditingController(text: 'Cria e Engorda');

  @override
  void dispose() {
    _nomeFazendaCtrl.dispose();
    _produtoresCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _atividadesCtrl.dispose();
    _areaTotalCtrl.dispose();
    _areaVeraoCtrl.dispose();
    _areaInvernoCtrl.dispose();
    _sistemaProdutivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _campoInput(
                label: 'Nome da fazenda',
                controller: _nomeFazendaCtrl,
              ),
              const SizedBox(height: 16),

              _campoInput(
                label: 'Nome do(s) produtor(es)',
                controller: _produtoresCtrl,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _campoInput(
                      label: 'Cidade',
                      controller: _cidadeCtrl,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _campoInput(
                      label: 'Estado',
                      controller: _estadoCtrl,
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _campoInput(
                label: 'Atividades realizadas',
                controller: _atividadesCtrl,
              ),
              const SizedBox(height: 16),

              _campoInput(
                label: 'Área total',
                controller: _areaTotalCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _campoInput(
                label: 'Área utilizada para pecuária - verão',
                controller: _areaVeraoCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _campoInput(
                label: 'Área utilizada para pecuária - inverno',
                controller: _areaInvernoCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _campoInput(
                label: 'Sistema produtivo',
                controller: _sistemaProdutivoCtrl,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00823A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final dados = {
                        'nomeFazenda': _nomeFazendaCtrl.text,
                        'produtores': _produtoresCtrl.text,
                        'cidade': _cidadeCtrl.text,
                        'estado': _estadoCtrl.text,
                        'atividades': _atividadesCtrl.text,
                        'areaTotal': _areaTotalCtrl.text,
                        'areaVerao': _areaVeraoCtrl.text,
                        'areaInverno': _areaInvernoCtrl.text,
                        'sistemaProdutivo': _sistemaProdutivoCtrl.text,
                      };

                      debugPrint(dados.toString());
                    }
                  },
                  child: const Text(
                    'Salvar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  )
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }


  Widget _campoInput({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
    controller: controller,
    style: const TextStyle(
    color: Color(0xFF313131),
    fontSize: 14,
    ),
    decoration: const InputDecoration(
    counterText: '',
    ),
    )
      ],
    );
  }
}

class MeusDadosTab extends StatelessWidget {
  const MeusDadosTab({super.key});



  Widget buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          style: TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
            filled: true,
            fillColor: Color(0xFFEBEBEB),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(64),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        padding: EdgeInsets.all(20),
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://thispersondoesnotexist.com/'),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0xFFE6E6E6),
                            ),
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: (){
                            //requestPermissions();
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            child: Stack(
                              children: [

                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0xFFE6E6E6),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Icon(
                                    Icons.image, color: Colors.grey, size: 20,),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ],
            ),
            buildTextField('Nome completo', 'Maisa'),
            buildTextField('Email', 'Maisa@a.com'),
            buildTextField('WhatsApp', '(99) 99999-9999'),
            buildTextField('Data de nascimento', '00/00/0000'),
            buildTextField('CPF', '000.000.000-00'),
            SizedBox(height: 16,),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 48,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00823A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {


                  },
                  child: const Text(
                    'Salvar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  )
              ),
            ),
            SizedBox(height: 32,)
          ],
        ),
      ),
    );
  }
}
Widget _label(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: Color(0xFF313131),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.10,
    ),
  );
}
