import 'package:costeira/theme/colors.dart';
import 'package:costeira/views/navigationscreen/movimentacoes/nascimento/addnascimento/addnascimento.dart';
import 'package:costeira/views/navigationscreen/movimentacoes/nascimento/detailnascimento/detailnascimento.dart';
import 'package:costeira/views/navigationscreen/movimentacoes/nascimento/editanascimento/editarnascimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'graficosnascimento.dart';

class Nascimentos extends StatefulWidget {
  const Nascimentos({super.key});

  @override
  State<Nascimentos> createState() => _NascimentosState();
}

class _NascimentosState extends State<Nascimentos>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int index = 0;

  //floatingActionButton: SpeedDial(
  //         direction: SpeedDialDirection.up,
  //         icon: Icons.add_rounded,
  //         activeIcon: Icons.close_rounded,
  //
  //         backgroundColor: MyColors.colorPrimary2,
  //         foregroundColor: Colors.white,
  //         activeForegroundColor: Colors.white,
  //         children: [
  //
  //           SpeedDialChild(
  //             shape: CircleBorder(),
  //             child:  Icon(Icons.add_rounded, color: MyColors.colorPrimary2,),
  //             label: 'Registro de compra',
  //             labelStyle: TextStyle(
  //               color: MyColors.colorPrimary2,
  //               fontSize: 14,
  //               fontFamily: 'Montserrat',
  //               fontWeight: FontWeight.w700,
  //               height: 1.29,
  //             ),
  //             onTap: () {
  //
  //             },
  //           ),
  //           //     {'svg': 'icon/receita.svg', 'label': 'Nova receita'},
  //           //     {'svg': 'icon/vendas.svg', 'label': 'Nova compra'},
  //           //     {'svg': 'icon/fornecedores.svg', 'label': 'Novo orçamento'},
  //           //     {'svg': 'icon/pedidos.svg', 'label': 'Novo pedido'},
  //           SpeedDialChild(
  //             shape: CircleBorder(),
  //             child:  Icon(Icons.add_rounded, color: MyColors.colorPrimary2,),
  //             label: 'Registro de utilização',
  //             labelStyle: TextStyle(
  //               color: MyColors.colorPrimary2,
  //               fontSize: 14,
  //               fontFamily: 'Montserrat',
  //               fontWeight: FontWeight.w700,
  //               height: 1.29,
  //             ),
  //             onTap: () {
  //
  //             },
  //           ),
  //
  //           // SpeedDialChild(
  //           //   child: Icon(Icons.assignment),
  //           //   label: 'Solicitar Assinatura',
  //           //   onTap: () {
  //           //   //  solicitarassinatura(id: graus[0].numeroOsTicket!, type: '6');
  //           //   },
  //           // ),
  //         ],
  //         // Para usar seu ícone customizado:
  //         buttonSize: const Size(
  //           180,
  //           48,
  //         ), // Tamanho do botão estendido
  //       ),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 0
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(64)),
              ),

              onPressed: () {
                // final index = DefaultTabController.of(tabContext).index; // 0,1,2
                //
                // if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNascimento()),
                );

                // } else if (index == 1) {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (_) => const Addservice()));
                // } else if (index == 2) {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (_) => const AddCategoria()));
                // }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Vendas',
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
              Tab(text: "Lista"),
              Tab(text: "Gráfico"),
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
          if (index == 0)
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailNascimento(),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 8, left: 20, right: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFEBEBEB),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 24,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 16,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0x198C8C8C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(42.67),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 5.33,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: SvgPicture.asset(
                                        'icon/circle-star.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    '1 nascimento • Fêmea',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF313131),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Matriz prenhe',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF8C8C8C),
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        '12/03/2025 ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF8C8C8C),
                                          fontSize: 12,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                // mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showModalBottomSheetExcluir(context);
                                    },
                                    child: SvgPicture.asset('icon/trash.svg'),
                                  ),
                                  SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const EditNascimento(),
                                        ),
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      'icon/square-pen.svg',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (index == 1) GraficosNascimento(),
        ],
      ),
    );
  }

  void _showModalBottomSheetExcluir(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  Opacity(
                    opacity: 0.70,
                    child: Container(
                      width: 72,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFE2E2E2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.close)],
                    ),
                  ),
                  SizedBox(height: 16),
                  SvgPicture.asset(
                    'icon/danger-linear.svg',
                    width: 80,
                    height: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Excluir nascimento",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      "Tem certeza que deseja excluir esse\nnascimento permanentemente?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF8692A8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            //  desativeAccount(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                            side: BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            fontSize: 16,
                            color: MyColors.colorOnPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: MyColors.colorOnPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
