import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/common/get_list/get_list_binds.dart';
import 'package:costeira/core/services/image_picker_service.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/services/notification_permission_service.dart';
import 'package:costeira/core/services/push_token_service.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/animals/animals_binds.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/features/notifications/repositories/notifications_repository.dart';
import 'package:costeira/features/utils/repositories/utils_repository.dart';
import 'package:costeira/features/auth/presentation/pages/register_credentials_page.dart';
import 'package:costeira/features/auth/presentation/pages/register_company_page.dart';
import 'package:costeira/features/auth/presentation/pages/register_responsible_page.dart';
import 'package:costeira/features/auth/presentation/pages/login_page.dart';
import 'package:costeira/features/auth/presentation/pages/pending_approval.dart';
import 'package:costeira/features/auth/presentation/pages/recivery_password_page.dart';
import 'package:costeira/views/navigationscreen/Menu/menu_page.dart';
import 'package:costeira/views/navigationscreen/Menu/Modulos/modulos.dart';
import 'package:costeira/views/navigationscreen/Menu/extras/extras.dart';
import 'package:costeira/views/navigationscreen/Menu/meusdados.dart';
import 'package:costeira/views/navigationscreen/Menu/minhaconta.dart';
import 'package:costeira/views/navigationscreen/Menu/updatepassword.dart';
import 'package:costeira/features/base/pages/main_navigation_page.dart';
import 'package:costeira/features/notifications/presentation/pages/notification_page.dart';
import 'package:costeira/features/auth/presentation/pages/onboarding.view.dart';
import 'package:costeira/features/auth/presentation/pages/splash.dart';
import 'package:costeira/features/auth/presentation/pages/welcome_page.dart';
import 'package:costeira/features/auth/presentation/pages/validation_code_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addInstance<ApiClient>(ApiClient.instance);
    i.addInstance<PushTokenService>(PushTokenService.instance);

    i.addLazySingleton<LocationService>(LocationService.new);
    i.addLazySingleton<NotificationPermissionService>(
      NotificationPermissionService.new,
    );
    i.addLazySingleton<ImagePickerService>(ImagePickerService.new);

    i.addLazySingleton<AuthRepository>(
      () => AuthRepository(client: Modular.get<ApiClient>()),
    );
    i.addLazySingleton<AccountRepository>(
      () => AccountRepository(client: Modular.get<ApiClient>()),
    );
    i.addLazySingleton<NotificationsRepository>(
      () => NotificationsRepository(client: Modular.get<ApiClient>()),
    );
    i.addLazySingleton<UtilsRepository>(
      () => UtilsRepository(client: Modular.get<ApiClient>()),
    );
    GetListBinds.register(i);
    AnimalsBinds.register(i);
  }

  @override
  void routes(RouteManager r) {
    r.child(AppRoutes.splash, child: (_) => const SplashPage());
    r.child(AppRoutes.onboarding, child: (_) => const OnboardingPage());
    r.child(AppRoutes.welcome, child: (_) => const WelcomePage());
    r.child(AppRoutes.login, child: (_) => const LoginPage());
    r.child(
      AppRoutes.recoverPassword,
      child: (_) => const RecoverPasswordPage(),
    );
    r.child(
      AppRoutes.registerCompany,
      child: (_) => const RegisterCompanyPage(),
    );
    r.child(
      AppRoutes.registerResponsible,
      child: (_) {
        final draft = _requireArgs<RegisterDraft>(r.args.data);
        return RegisterResponsiblePage(draft: draft);
      },
    );
    r.child(
      AppRoutes.registerCredentials,
      child: (_) {
        final draft = _requireArgs<RegisterDraft>(r.args.data);
        return RegisterCredentialsPage(draft: draft);
      },
    );
    r.child(
      AppRoutes.validationCode,
      child: (_) {
        final data = _requireArgs<ValidationCodeRouteData>(r.args.data);
        return ValidationCodePage(
          email: data.email,
          password: data.password,
          lat: data.latitude,
          long: data.longitude,
          tipo: data.userType,
        );
      },
    );
    r.child(
      AppRoutes.pendingApproval,
      child: (_) {
        final data = r.args.data as PendingApprovalRouteData?;
        return PendingApprovalPage(message: data?.message, email: data?.email);
      },
    );
    r.child(AppRoutes.appShell, child: (_) => const MainNavigationPage());
    r.child(AppRoutes.menu, child: (_) => const MenuPage());
    r.child(AppRoutes.notifications, child: (_) => const NotificationsPage());
    r.child(AppRoutes.myAccount, child: (_) => const MyAccountPage());
    r.child(AppRoutes.profile, child: (_) => const MeusDados());
    r.child(AppRoutes.updatePassword, child: (_) => const UpdatePasswordPage());
    r.child(AppRoutes.modules, child: (_) => const ModulesPage());
    r.child(AppRoutes.extras, child: (_) => const Extras());
  }

  T _requireArgs<T>(Object? data) {
    if (data is! T) {
      throw ArgumentError(
        'Expected route arguments of type $T, but received ${data.runtimeType}.',
      );
    }
    return data;
  }
}
