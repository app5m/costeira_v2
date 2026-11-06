import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SelecionarClienteWebPage extends StatefulWidget {
  const SelecionarClienteWebPage({
    super.key,
    this.obrigatorio = false,
    this.onEscolhido,
  });

  final bool obrigatorio;
  final VoidCallback? onEscolhido;

  @override
  State<SelecionarClienteWebPage> createState() =>
      _SelecionarClienteWebPageState();
}

class _SelecionarClienteWebPageState extends State<SelecionarClienteWebPage> {
  final _busca = TextEditingController();
  final _listScroll = ScrollController();
  List<ClienteLista> _clientes = const [];
  bool _loading = true;
  bool _selecionando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _busca.addListener(() => setState(() {}));
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    _listScroll.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final session = await SessionStorage.getUserSession();
      final lista = await Modular.get<GetListUsecase>()(
        GetListParamsEntity(sexo: 1, userId: session?.id),
      );
      if (!mounted) return;
      setState(() {
        _clientes = lista.clientes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _erro = 'Não foi possível listar os clientes.';
      });
    }
  }

  List<ClienteLista> get _filtrados =>
      _clientes.where((cliente) => cliente.combina(_busca.text)).toList();

  Future<void> _escolher(ClienteLista cliente) async {
    if (_selecionando) return;
    setState(() => _selecionando = true);
    try {
      final session = await SessionStorage.getUserSession();
      if (session == null) return;
      await SessionStorage.saveUserSession(
        session.withManagedClient(cliente.id),
      );
      await SessionStorage.clearSelectedFarmId();
      if (!mounted) return;
      if (widget.onEscolhido != null) {
        widget.onEscolhido!();
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _selecionando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewHeight = MediaQuery.sizeOf(context).height;
    final listMaxHeight = (viewHeight * 0.42).clamp(220.0, 340.0);

    return AuthWebFrame(
      title: 'Clientes',
      subtitle: 'Selecione o cliente para acessar o dashboard.',
      showBack: !widget.obrigatorio,
      showBrandHeader: false,
      contentMaxWidth: 520,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: 'Buscar',
            hintText: 'Nome ou CNPJ',
            controller: _busca,
            textInputAction: TextInputAction.search,
            suffixIcon: const Icon(Icons.search, color: Color(0xFF8C8C8C)),
          ),
          const SizedBox(height: 20),
          _corpo(_filtrados, maxHeight: listMaxHeight),
        ],
      ),
    );
  }

  Widget _corpo(List<ClienteLista> filtrados, {required double maxHeight}) {
    if (_loading) {
      return SizedBox(
        height: maxHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_erro != null) {
      return SizedBox(
        height: maxHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF727976),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _carregar,
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      );
    }
    if (filtrados.isEmpty) {
      return SizedBox(
        height: maxHeight,
        child: const Center(
          child: Text(
            'Nenhum cliente encontrado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF727976),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Scrollbar(
        controller: _listScroll,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _listScroll,
          primary: false,
          shrinkWrap: true,
          padding: const EdgeInsets.only(right: 14),
          itemCount: filtrados.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final cliente = filtrados[index];
            return _ClienteTile(
              cliente: cliente,
              enabled: !_selecionando,
              onTap: () => _escolher(cliente),
            );
          },
        ),
      ),
    );
  }
}

class _ClienteTile extends StatelessWidget {
  const _ClienteTile({
    required this.cliente,
    required this.onTap,
    required this.enabled,
  });

  final ClienteLista cliente;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final subtitulo = [
      if (cliente.nomeFantasia.isNotEmpty) cliente.nomeFantasia,
      if (cliente.cnpj.isNotEmpty) cliente.cnpj,
    ].join(' · ');

    return Material(
      color: const Color(0xFFF7F9F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MyColors.colorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  size: 20,
                  color: MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nome.isEmpty
                          ? 'Cliente ${cliente.id}'
                          : cliente.nome,
                      style: const TextStyle(
                        color: Color(0xFF252A28),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    if (subtitulo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          color: Color(0xFF727976),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8C8C8C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
