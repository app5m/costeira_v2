import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/get_climates_usecase.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_tipo_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_compras_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_manejos_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_suplementos_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/usecases/get_sanitarios_usecase.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/usecases/get_tasks_usecase.dart';

class FormDependenciesCacheService {
  FormDependenciesCacheService(
    this._networkStatusService,
    this._getListUsecase,
    this._getPotreirosUsecase,
    this._getAnimalLotsUsecase,
    this._getAnimalsUsecase,
    this._getClimatesUsecase,
    this._getInsumosUsecase,
    this._getInsumosTipoUsecase,
    this._getSuplementosUsecase,
    this._getManejosUsecase,
    this._getSanitariosUsecase,
    this._getTasksUsecase,
    this._getComprasUsecase,
    this._resolveCurrentFarmId,
  );

  final NetworkStatusService _networkStatusService;
  final GetListUsecase _getListUsecase;
  final GetPotreirosUsecase _getPotreirosUsecase;
  final GetAnimalLotsUsecase _getAnimalLotsUsecase;
  final GetAnimalsUsecase _getAnimalsUsecase;
  final GetClimatesUsecase _getClimatesUsecase;
  final GetInsumosUsecase _getInsumosUsecase;
  final GetInsumosTipoUsecase _getInsumosTipoUsecase;
  final GetSuplementosUsecase _getSuplementosUsecase;
  final GetManejosUsecase _getManejosUsecase;
  final GetSanitariosUsecase _getSanitariosUsecase;
  final GetTasksUsecase _getTasksUsecase;
  final GetComprasUsecase _getComprasUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isRunning = false;
  bool _hasCompleted = false;

  Future<void> preloadEssentialLists({bool force = false}) async {
    if (_isRunning || (_hasCompleted && !force)) {
      return;
    }

    if (!await _networkStatusService.hasConnection()) {
      AppLogger.info('FORM DEPENDENCIES CACHE: sem conexao, preload ignorado');
      return;
    }

    final session = await SessionStorage.getUserSession();
    final userId = session?.id ?? 0;
    if (userId <= 0) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: usuario nao autenticado, preload ignorado',
      );
      return;
    }

    _isRunning = true;
    try {
      await _safe('util/lista macho', () {
        return _getListUsecase(GetListParamsEntity(sexo: 1, userId: userId));
      });
      await _safe('util/lista femea', () {
        return _getListUsecase(GetListParamsEntity(sexo: 2, userId: userId));
      });
      final farmId = await _resolveCurrentFarmId(userId: userId);
      if (farmId != null) {
        await _safe('potreiros', () {
          return _getPotreirosUsecase(
            PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
          );
        });
        await _safe('lotes', () {
          return _getAnimalLotsUsecase(
            AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
          );
        });
        await _safe('animais', () {
          return _getAnimalsUsecase(
            AnimalsFilterEntity(appUsersId: userId, appFazendasId: farmId),
          );
        });
      }
      await _safe('clima e chuva', () {
        return _getClimatesUsecase(ClimateFilterEntity(appUsersId: userId));
      });
      await _safe('insumos', () {
        return _getInsumosUsecase(InsumosFilterEntity(appUsersId: userId));
      });
      await _safe('tipos de insumos', () {
        return _getInsumosTipoUsecase(
          InsumosTipoFilterEntity(appUsersId: userId),
        );
      });
      await _safe('suplementos para formulario de suplementacao', () {
        return _getInsumosTipoUsecase(
          InsumosTipoFilterEntity(appUsersId: userId, tipo: 'suplementos'),
        );
      });
      await _safe('suplemento para formulario de suplementacao', () {
        return _getInsumosTipoUsecase(
          InsumosTipoFilterEntity(appUsersId: userId, tipo: 'suplemento'),
        );
      });
      await _safe('medicamentos para executar sanitario', () {
        return _getInsumosTipoUsecase(
          InsumosTipoFilterEntity(appUsersId: userId, tipo: 'medicamentos'),
        );
      });
      await _safe('medicamento para executar sanitario', () {
        return _getInsumosTipoUsecase(
          InsumosTipoFilterEntity(appUsersId: userId, tipo: 'medicamento'),
        );
      });
      await _safe('suplementacao', () {
        return _getSuplementosUsecase(
          SuplementoFilterEntity(appUsersId: userId),
        );
      });
      await _safe('pastagens', () {
        return _getManejosUsecase(ManejoFilterEntity(appUsersId: userId));
      });
      await _safe('sanitarios', () {
        return _getSanitariosUsecase(
          SanitariosFilterEntity(appUsersId: userId),
        );
      });
      await _safe('tarefas', () {
        return _getTasksUsecase(TaskFilterEntity(appUsersId: userId));
      });
      await _safe('movimentacoes', () {
        return _getComprasUsecase(MovimentacaoFilterEntity(appUsersId: userId));
      });

      _hasCompleted = true;
      AppLogger.success('FORM DEPENDENCIES CACHE: preload concluido');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> preloadAnimalFormDependencies() async {
    if (!await _networkStatusService.hasConnection()) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: sem conexao, preload do formulario de animal ignorado',
      );
      return;
    }

    final userId = await _currentUserId();
    if (userId <= 0) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: usuario nao autenticado, preload do formulario de animal ignorado',
      );
      return;
    }

    AppLogger.info(
      'FORM DEPENDENCIES CACHE: preload do formulario de animal userId=$userId',
    );

    await _safe('animal form util/lista macho', () {
      return _getListUsecase(GetListParamsEntity(sexo: 1, userId: userId));
    });
    await _safe('animal form util/lista femea', () {
      return _getListUsecase(GetListParamsEntity(sexo: 2, userId: userId));
    });
    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId != null) {
      await _safe('animal form lotes', () {
        return _getAnimalLotsUsecase(
          AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
      await _safe('animal form potreiros', () {
        return _getPotreirosUsecase(
          PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
    }
  }

  Future<void> preloadNascimentoFormDependencies() async {
    if (!await _networkStatusService.hasConnection()) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: sem conexao, preload do formulario de nascimento ignorado',
      );
      return;
    }

    final userId = await _currentUserId();
    if (userId <= 0) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: usuario nao autenticado, preload do formulario de nascimento ignorado',
      );
      return;
    }

    AppLogger.info(
      'FORM DEPENDENCIES CACHE: preload do formulario de nascimento userId=$userId',
    );

    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId != null) {
      await _safe('nascimento form animais', () {
        return _getAnimalsUsecase(
          AnimalsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
      await _safe('nascimento form lotes', () {
        return _getAnimalLotsUsecase(
          AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
      await _safe('nascimento form potreiros', () {
        return _getPotreirosUsecase(
          PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
    }
  }

  Future<void> preloadAbortoFormDependencies() async {
    if (!await _networkStatusService.hasConnection()) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: sem conexao, preload do formulario de aborto ignorado',
      );
      return;
    }

    final userId = await _currentUserId();
    if (userId <= 0) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: usuario nao autenticado, preload do formulario de aborto ignorado',
      );
      return;
    }

    AppLogger.info(
      'FORM DEPENDENCIES CACHE: preload do formulario de aborto userId=$userId',
    );

    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId != null) {
      await _safe('aborto form animais', () {
        return _getAnimalsUsecase(
          AnimalsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
      await _safe('aborto form lotes', () {
        return _getAnimalLotsUsecase(
          AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
      await _safe('aborto form potreiros', () {
        return _getPotreirosUsecase(
          PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
    }
  }

  Future<void> preloadSuplementoFormDependencies() async {
    if (!await _networkStatusService.hasConnection()) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: sem conexao, preload do formulario de suplemento ignorado',
      );
      return;
    }

    final userId = await _currentUserId();
    if (userId <= 0) {
      AppLogger.info(
        'FORM DEPENDENCIES CACHE: usuario nao autenticado, preload do formulario de suplemento ignorado',
      );
      return;
    }

    AppLogger.info(
      'FORM DEPENDENCIES CACHE: preload do formulario de suplemento userId=$userId',
    );

    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId != null) {
      await _safe('suplemento form potreiros', () {
        return _getPotreirosUsecase(
          PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
      await _safe('suplemento form lotes', () {
        return _getAnimalLotsUsecase(
          AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        );
      });
    }
    await _safe('suplemento form produtos plural', () {
      return _getInsumosTipoUsecase(
        InsumosTipoFilterEntity(appUsersId: userId, tipo: 'suplementos'),
      );
    });
    await _safe('suplemento form produtos singular', () {
      return _getInsumosTipoUsecase(
        InsumosTipoFilterEntity(appUsersId: userId, tipo: 'suplemento'),
      );
    });
  }

  Future<int> _currentUserId() async {
    final session = await SessionStorage.getUserSession();
    return session?.id ?? 0;
  }

  Future<void> _safe(
    String description,
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
      AppLogger.success(
        'FORM DEPENDENCIES CACHE: cache atualizado para $description',
      );
    } catch (error) {
      AppLogger.warning(
        'FORM DEPENDENCIES CACHE: falha ao carregar $description: $error',
      );
    }
  }
}
