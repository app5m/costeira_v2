// import 'package:daf/views/navigation/dashboard/dashboard.dart';
// import 'package:daf/views/navigation/laudo/laudo.dart';
// import 'package:daf/views/navigation/perfil/perfil.dart';
// import 'package:daf/views/navigation/usuarios/usuarios.dart';
import 'package:costeira/views/navigationscreen/animais/animais.dart';
import 'package:costeira/views/navigationscreen/dashbord/dashboard.dart';
import 'package:costeira/views/navigationscreen/indicadores/indicadores.dart';
import 'package:costeira/views/navigationscreen/movimentacoes/movimentacoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/colors.dart';
import 'Menu/Menu.dart';
import 'home/home.dart';
import 'notification/notification.dart';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  bool isVisible = false;
  PageController _pageController = PageController(initialPage: 0);

  String getTitulo(int tela) {
    switch (tela) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Animais';
      case 2:
        return 'Movimentações';
      case 3:
        return 'Indicadores';
        case 4:
        return 'Menu';
    // Você pode adicionar outros cases aqui
      default:
        return ''; // retorno padrão caso não encontre o case
    }
  }

  PreferredSizeWidget customAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(90),
      child: AppBar(
        backgroundColor: MyColors.colorPrimary,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 65,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://thispersondoesnotexist.com/'),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Olá ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: 'Guilherme!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'guilherme@email.com',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [

          IconButton(
            icon: SvgPicture.asset("icon/noti.svg", color: Colors.white,),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacoesScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 ? customAppBar(context) : AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: Container(),
        titleSpacing: 0,
        leadingWidth: 20,
        centerTitle: false,
        title: Text(getTitulo(_selectedIndex),style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),),
        actions: [

          IconButton(
            icon: SvgPicture.asset("icon/noti.svg", color: Colors.white,),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacoesScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 12),

        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 0),
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (int onPageChanged) {
            setState(() {
              _selectedIndex = onPageChanged;
            });
          },
          children: [

            Dashboard(),
          Animais(),
            Movimentacoes(),
         Indicadores(),
            Menu(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: [
          _buildNavBarItem("icon/layout-dashboard.svg", 0),
          _buildNavBarItem("icon/cow-light.svg", 1),
          _buildNavBarItem("icon/arrow-left-right.svg", 2),
          _buildNavBarItem("icon/chart-column.svg", 3),
          _buildNavBarItem("icon/menu.svg", 4),
        ],
        showSelectedLabels: false,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Future<void> _onNavItemTapped(int index) async {
    // bool getLogin = await Preferences.getLogin();
    // if(getLogin){
    //   verificaUser(context);
    //   setState(() {
    //     _selectedIndex = index;
    //     _pageController.animateToPage(index,
    //         duration: Duration(milliseconds: 400), curve: Curves.linear);
    //   });
    // }else{
    //   if(index != 0){
    //     _showModalBottomSheetLogin(context);
    //   }
    // }
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 400), curve: Curves.linear);
    });

  }

  BottomNavigationBarItem _buildNavBarItem(String icon, int index) {
    return BottomNavigationBarItem(
      backgroundColor: Colors.white,
      icon: Column(
        children: [
          Container(
            margin: EdgeInsets.all(4),
            child: SvgPicture.asset(
              icon,
              color:
              _selectedIndex == index ? MyColors.colorPrimary : Colors.grey,
            ),
          ),
        ],
      ),
      label: '',
    );
  } //navegaÇao icones rodape
}

