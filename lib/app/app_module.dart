import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/common/get_list/get_list_binds.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/cache/api_cache_storage.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/presentation/controllers/sync_controller.dart';
import 'package:costeira/core/offline/presentation/pages/sync_page.dart';
import 'package:costeira/core/offline/sync/post_sync_cache_refresh_service.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/offline/sync/sync_queue_storage.dart';
import 'package:costeira/core/offline/sync/sync_service.dart';
import 'package:costeira/core/services/image_picker_service.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/services/notification_permission_service.dart';
import 'package:costeira/core/services/push_token_service.dart';
import 'package:costeira/features/climate_and_rain/climate_and_rain_binds.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/pages/climate_add.dart';
import 'package:costeira/features/climate_and_rain/presentation/pages/climate_edit.dart';
import 'package:costeira/features/climate_and_rain/presentation/pages/climate_page.dart';
import 'package:costeira/features/dashboard/dashboard_binds.dart';
import 'package:costeira/features/fazendas/fazendas_binds.dart';
import 'package:costeira/features/cadastros/cadastros_binds.dart';
import 'package:costeira/features/usuarios/presentation/pages/sub_usuario_form_page.dart';
import 'package:costeira/features/usuarios/presentation/pages/sub_usuarios_list_page.dart';
import 'package:costeira/features/usuarios/usuarios_binds.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/presentation/pages/parceiro_form_page.dart';
import 'package:costeira/features/cadastros/presentation/pages/parceiros_list_page.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/presentation/pages/fazenda_form_page.dart';
import 'package:costeira/features/base/pages/coming_soon_page.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/animals/animals_binds.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/features/notifications/repositories/notifications_repository.dart';
import 'package:costeira/features/movimentacoes/movimentacoes_binds.dart';
import 'package:costeira/features/movimentacoes/movimentacoes.dart';
import 'package:costeira/features/utils/repositories/utils_repository.dart';
import 'package:costeira/features/animals/presentation/pages/animals/add_animal.dart';
import 'package:costeira/features/animals/presentation/pages/animals/animal_detail.dart';
import 'package:costeira/features/animals/presentation/pages/animals/animal_edit.dart';
import 'package:costeira/features/animals/presentation/pages/animals_page.dart';
import 'package:costeira/features/insumos/presentation/pages/estoque_insumos.dart';
import 'package:costeira/features/tasks/presentation/pages/task_page.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/add_lote.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/edit_lote.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/lotes_page.dart';
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
import 'package:costeira/features/potreiros/presentation/pages/carga_animal/cargaanimal.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/potreiros_binds.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/protreiro_add.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/protreiro_detail.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/potreiro_edit.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/potreiros_page.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros_e_carga_animal.dart';
import 'package:costeira/features/sanitarios/sanitarios_binds.dart';
import 'package:costeira/features/tasks/tasks_binds.dart';
import 'package:costeira/features/auth/presentation/pages/onboarding.view.dart';
import 'package:costeira/features/auth/presentation/pages/splash.dart';
import 'package:costeira/features/auth/presentation/pages/welcome_page.dart';
import 'package:costeira/features/auth/presentation/pages/validation_code_page.dart';
import 'package:costeira/features/insumos/insumos_binds.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/pastagem_nutricao_suplemento_binds.dart';
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
    i.addLazySingleton<NetworkStatusService>(NetworkStatusService.new);
    i.addLazySingleton<ApiCacheStorage>(ApiCacheStorage.new);
    i.addLazySingleton<ApiCacheService>(ApiCacheService.new);
    i.addLazySingleton<OfflineMutationCacheService>(
      OfflineMutationCacheService.new,
    );
    i.addLazySingleton<SyncQueueStorage>(SyncQueueStorage.new);
    i.addLazySingleton<SyncQueueService>(SyncQueueService.new);
    i.addLazySingleton<OfflineApiService>(OfflineApiService.new);

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
      () => UtilsRepository(
        client: Modular.get<ApiClient>(),
        offlineApiService: Modular.get<OfflineApiService>(),
      ),
    );
    GetListBinds.register(i);
    ClimateAndRainBinds.register(i);
    FazendasBinds.register(i);
    PotreirosBinds.register(i);
    AnimalsBinds.register(i);
    DashboardBinds.register(i);
    InsumosBinds.register(i);
    MovimentacoesBinds.register(i);
    PastagemNutricaoSuplementoBinds.register(i);
    SanitariosBinds.register(i);
    TasksBinds.register(i);
    CadastrosBinds.register(i);
    UsuariosBinds.register(i);
    i.addLazySingleton<PostSyncCacheRefreshService>(
      PostSyncCacheRefreshService.new,
    );
    i.addLazySingleton<FormDependenciesCacheService>(
      FormDependenciesCacheService.new,
    );
    i.addLazySingleton<SyncService>(SyncService.new);
    i.add<SyncController>(SyncController.new);
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
          pendingUser: data.pendingUser,
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
    r.child(AppRoutes.sync, child: (_) => const SyncPage());
    r.child(AppRoutes.climateRain, child: (_) => const ClimatePage());
    r.child(AppRoutes.estoque, child: (_) => const Insumos());
    r.child(AppRoutes.tasks, child: (_) => const TaskPage());
    r.child(
      AppRoutes.comingSoon,
      child: (_) {
        final data = r.args.data;
        if (data is ComingSoonRouteData) {
          return ComingSoonPage(
            title: data.title,
            message: data.message,
            menu: data.menu,
          );
        }
        return const ComingSoonPage(title: 'Em breve');
      },
    );
    r.child(AppRoutes.fazendasAdd, child: (_) => const FazendaFormPage());
    r.child(
      AppRoutes.fazendasEdit,
      child: (_) {
        final fazenda = _requireArgs<FazendaEntity>(r.args.data);
        return FazendaFormPage(fazenda: fazenda);
      },
    );
    r.child(
      AppRoutes.fornecedores,
      child: (_) => const ParceirosListPage(kind: ParceiroKind.fornecedor),
    );
    r.child(
      AppRoutes.compradores,
      child: (_) => const ParceirosListPage(kind: ParceiroKind.comprador),
    );
    r.child(
      AppRoutes.fornecedoresAdd,
      child: (_) {
        final data = _requireArgs<ParceiroFormRouteData>(r.args.data);
        return ParceiroFormPage(data: data);
      },
    );
    r.child(
      AppRoutes.compradoresAdd,
      child: (_) {
        final data = _requireArgs<ParceiroFormRouteData>(r.args.data);
        return ParceiroFormPage(data: data);
      },
    );
    r.child(
      AppRoutes.fornecedoresEdit,
      child: (_) {
        final data = _requireArgs<ParceiroFormRouteData>(r.args.data);
        return ParceiroFormPage(data: data);
      },
    );
    r.child(
      AppRoutes.compradoresEdit,
      child: (_) {
        final data = _requireArgs<ParceiroFormRouteData>(r.args.data);
        return ParceiroFormPage(data: data);
      },
    );
    r.child(AppRoutes.usuarios, child: (_) => const SubUsuariosListPage());
    r.child(AppRoutes.usuariosAdd, child: (_) => const SubUsuarioFormPage());
    r.child(
      AppRoutes.usuariosEdit,
      child: (_) {
        final data = r.args.data;
        if (data is SubUsuarioFormRouteData) {
          return SubUsuarioFormPage(data: data);
        }
        return const SubUsuarioFormPage();
      },
    );
    r.child(AppRoutes.movimentacoes, child: (_) => const Movimentacoes());
    r.child(AppRoutes.climateRainAdd, child: (_) => const ClimateAdd());
    r.child(
      AppRoutes.climateRainEdit,
      child: (_) {
        final climate = _requireArgs<ClimateEntity>(r.args.data);
        return ClimateEdit(climate: climate);
      },
    );
    r.child(AppRoutes.animals, child: (_) => const AnimalsPage());
    r.child(AppRoutes.animalsAdd, child: (_) => const AnimalAdd());
    r.child(
      AppRoutes.animalsEdit,
      child: (_) {
        final animal = _requireArgs<AnimalEntity>(r.args.data);
        return EditAnimal(animal: animal);
      },
    );
    r.child(
      AppRoutes.animalsDetail,
      child: (_) {
        final animal = _requireArgs<AnimalEntity>(r.args.data);
        return DetailAnimal(animal: animal);
      },
    );
    r.child(AppRoutes.animalLots, child: (_) => const LotesPage());
    r.child(AppRoutes.animalLotsAdd, child: (_) => const AddLote());
    r.child(
      AppRoutes.animalLotsEdit,
      child: (_) {
        final lot = _requireArgs<AnimalLotEntity>(r.args.data);
        return EditLote(lot: lot);
      },
    );
    r.child(
      AppRoutes.potreirosHub,
      child: (_) => const PotreirosECargaAnimal(),
    );
    r.child(AppRoutes.potreiros, child: (_) => const Potreiros());
    r.child(AppRoutes.potreirosAdd, child: (_) => const PotreiroAdd());
    r.child(
      AppRoutes.potreirosEdit,
      child: (_) {
        final potreiro = _requireArgs<PotreiroEntity>(r.args.data);
        return PotreiroEdit(potreiro: potreiro);
      },
    );
    r.child(
      AppRoutes.potreirosDetail,
      child: (_) {
        final potreiro = _requireArgs<PotreiroEntity>(r.args.data);
        return PoteiroDetail(potreiro: potreiro);
      },
    );
    r.child(AppRoutes.cargaAnimal, child: (_) => const CargaAnimal());
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
