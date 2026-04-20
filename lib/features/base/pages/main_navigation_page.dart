import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/features/animals/presentation/pages/animals_page.dart';
import 'package:costeira/views/navigationscreen/dashbord/dashboard.dart';
import 'package:costeira/views/navigationscreen/indicadores/indicadores.dart';
import 'package:costeira/views/navigationscreen/movimentacoes/movimentacoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/colors.dart';
import '../../../views/navigationscreen/Menu/menu_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  UserSession? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionStorage.getUserSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_selectedIndex) {
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
      default:
        return '';
    }
  }

  PreferredSizeWidget _customAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: AppBar(
        backgroundColor: MyColors.colorPrimary,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 65,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              Modular.to.pushNamed(AppRoutes.menu);
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFEBEBEB),
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: 'Olá ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: _user?.name.isNotEmpty == true ? _user!.name : 'Usuário',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Text(
              _user?.email ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'icon/noti.svg',
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () {
              Modular.to.pushNamed(AppRoutes.notifications);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultAppBar = AppBar(
      backgroundColor: MyColors.colorPrimary,
      leadingWidth: 20,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          _title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'icon/noti.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () {
            Modular.to.pushNamed(AppRoutes.notifications);
          },
        ),
        const SizedBox(width: 12),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 ? _customAppBar(context) : defaultAppBar,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
        children: const [Dashboard(), AnimalsPage(), Movimentacoes(), Indicadores(), Menu()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        items: [
          _buildNavBarItem('icon/layout-dashboard.svg', 0),
          _buildNavBarItem('icon/cow-light.svg', 1),
          _buildNavBarItem('icon/arrow-left-right.svg', 2),
          _buildNavBarItem('icon/chart-column.svg', 3),
          _buildNavBarItem('icon/menu.svg', 4),
        ],
        onTap: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  BottomNavigationBarItem _buildNavBarItem(String icon, int index) {
    return BottomNavigationBarItem(
      label: '',
      icon: Padding(
        padding: const EdgeInsets.all(4),
        child: SvgPicture.asset(
          icon,
          colorFilter: ColorFilter.mode(
            _selectedIndex == index ? MyColors.colorPrimary : Colors.grey,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

typedef NavigationScreen = MainNavigationPage;
