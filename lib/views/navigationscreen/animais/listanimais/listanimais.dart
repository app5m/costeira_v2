

import 'package:costeira/views/navigationscreen/animais/listanimais/detailanimal/detailanimal.dart';
import 'package:costeira/views/navigationscreen/animais/listanimais/editaanimal/editaranimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../theme/colors.dart';

class ListAnimais extends StatefulWidget {
  const ListAnimais({super.key});

  @override
  State<ListAnimais> createState() => _ListAnimaisState();
}

class _ListAnimaisState extends State<ListAnimais> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        SizedBox(height: 16,),
        Row(children: [
          SizedBox(width: 20,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFFE6E6E6),
                ),
                borderRadius: BorderRadius.circular(64),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                Text(
                  'Filtro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF8C8C8C),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
                SizedBox(width: 8,),
                SvgPicture.asset('icon/header.svg', width: 16, height: 16,),
              ],
            ),
          )
        ],),
        SizedBox(height: 16,),
        Expanded(child: ListView.builder(
          itemCount: 3,
            itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DetailAnimal()));
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              margin: EdgeInsets.only(bottom: 8, left: 20, right: 20),
              padding: const EdgeInsets.all(16),
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
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
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
                          SvgPicture.asset('icon/cow-light.svg',width: 16,height: 16,),
                        ],
                      ),
                    ),
                    SizedBox(width:16,),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              '2035',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF313131),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              'Novilha • 345 kg',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF313131),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  'Lote',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF8C8C8C),
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'A',
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  'Potreiro',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF8C8C8C),
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'P1',
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
                    )
                  ],),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        GestureDetector(
                            onTap: (){
                              _showModalBottomSheetExcluir(context);
                            },
                            child: SvgPicture.asset('icon/trash.svg')),

                        GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const EditAnimal()));
                            },
                            child: SvgPicture.asset('icon/square-pen.svg')),
                      ],
                    )
                  ],)
                ],
              ),
            ),
          );
        }))
      ],),
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
          )),
      builder: (BuildContext bc) {
        return Container(
          child: Column(
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
                        children: [
                          Icon(
                            Icons.close,
                          ),
                        ],
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
                          "Excluir animal",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xff000000)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        "Tem certeza que deseja excluir esse\nanimal permanentemente?",
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
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              //  desativeAccount(context);
                            },
                            child: Text(
                              "Excluir",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
                              side: BorderSide(color: Colors.red),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
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
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                    SizedBox(height: 16)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
