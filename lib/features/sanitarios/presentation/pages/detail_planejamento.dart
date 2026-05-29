import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/pages/detail_execucoes.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class DetailPlanejamento extends StatelessWidget {
  const DetailPlanejamento({super.key, required this.sanitario});

  final SanitarioEntity sanitario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Detalhes do planejamento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              ReadOnlyDetailField(
                label: 'Tipo de manejo',
                value: sanitario.tipoManejo,
              ),
              if ((sanitario.tipoCarrapaticida ?? '').trim().isNotEmpty)
                ReadOnlyDetailField(
                  label: 'Tipo de carrapaticida',
                  value: sanitario.tipoCarrapaticida!,
                ),
              ReadOnlyDetailField(
                label: 'Data planejada',
                value: _emptyToDash(sanitario.dataPlanejada),
              ),
              ReadOnlyDetailField(
                label: 'Categoria',
                value: _join(sanitario.categorias.map((item) => item.nome)),
              ),
              ReadOnlyDetailField(
                label: 'Lote envolvido',
                value: _join(sanitario.lotes.map((item) => item.nome)),
              ),
              ReadOnlyDetailField(label: 'Status', value: sanitario.status),
              ReadOnlyDetailField(
                label: 'Observacoes',
                value: _emptyToDash(sanitario.obs),
                minHeight: 92,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _join(Iterable<String> values) {
  final result = values
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join(', ');
  return result.isEmpty ? '-' : result;
}

String _emptyToDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}
