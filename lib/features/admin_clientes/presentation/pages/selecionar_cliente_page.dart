import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SelecionarClientePage extends StatefulWidget {
  const SelecionarClientePage({
    super.key,
    this.obrigatorio = false,
    this.onEscolhido,
  });

  final bool obrigatorio;
  final VoidCallback? onEscolhido;

  @override
  State<SelecionarClientePage> createState() => _SelecionarClientePageState();
}

class _SelecionarClientePageState extends State<SelecionarClientePage> {
  final _busca = TextEditingController();
  List<ClienteLista> _clientes = const [];
  bool _loading = true;
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
      if (!mounted) {
        return;
      }
      setState(() {
        _clientes = lista.clientes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _erro = 'Nao foi possivel listar os clientes.';
      });
    }
  }

  List<ClienteLista> get _filtrados =>
      _clientes.where((cliente) => cliente.combina(_busca.text)).toList();

  Future<void> _escolher(ClienteLista cliente) async {
    final session = await SessionStorage.getUserSession();
    if (session == null) {
      return;
    }
    await SessionStorage.saveUserSession(session.withManagedClient(cliente.id));
    await SessionStorage.clearSelectedFarmId();
    if (!mounted) {
      return;
    }
    if (widget.onEscolhido != null) {
      widget.onEscolhido!();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        automaticallyImplyLeading: !widget.obrigatorio,
        leading: widget.obrigatorio
            ? null
            : IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
        title: const Text(
          'Clientes',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _busca,
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nome ou CNPJ',
                hintStyle: const TextStyle(
                  color: Color(0xFF8C8C8C),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8C8C8C)),
                filled: true,
                fillColor: const Color(0xFFEBEBEB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _corpo(filtrados)),
        ],
      ),
    );
  }

  Widget _corpo(List<ClienteLista> filtrados) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Color(0xFF8C8C8C),
                ),
              ),
              TextButton(onPressed: _carregar, child: const Text('Tentar de novo')),
            ],
          ),
        ),
      );
    }
    if (filtrados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum cliente encontrado.',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: Color(0xFF8C8C8C),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final cliente = filtrados[index];
        final subtitulo = [
          if (cliente.nomeFantasia.isNotEmpty) cliente.nomeFantasia,
          if (cliente.cnpj.isNotEmpty) cliente.cnpj,
        ].join(' · ');
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: const Color(0xFFF7F8F8),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _escolher(cliente),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cliente.nome.isEmpty ? 'Cliente ${cliente.id}' : cliente.nome,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF313131),
                            ),
                          ),
                          if (subtitulo.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitulo,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: Color(0xFF8C8C8C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF8C8C8C)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
