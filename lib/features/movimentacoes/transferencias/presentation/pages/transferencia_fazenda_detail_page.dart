import 'package:costeira/features/movimentacoes/transferencias/add_transferencia_fazenda.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class TransferenciaFazendaDetailPage extends StatefulWidget {
  const TransferenciaFazendaDetailPage({
    super.key,
    required this.item,
    this.canEdit = false,
  });

  final TransferenciaFazendaListItem item;
  final bool canEdit;

  @override
  State<TransferenciaFazendaDetailPage> createState() =>
      _TransferenciaFazendaDetailPageState();
}

class _TransferenciaFazendaDetailPageState
    extends State<TransferenciaFazendaDetailPage> {
  static const _pageSize = 10;
  int _visible = _pageSize;

  Future<void> _openEdit() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransferenciaFazenda(item: widget.item),
      ),
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final shown = item.animais.take(_visible).toList(growable: false);
    final remaining = item.animais.length - shown.length;
    final origem = item.fazendaOrigem?.nome ?? 'Origem';
    final destino = item.fazendaDestino?.nome ?? 'Destino';
    final statusColor = switch (item.statusTransferencia) {
      1 => (bg: const Color(0xFFE7F6EC), fg: MyColors.colorPrimary),
      3 => (bg: const Color(0xFFFDECEC), fg: const Color(0xFFC62828)),
      _ => (bg: const Color(0xFFFFF4E5), fg: const Color(0xFFB86E00)),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          if (widget.canEdit)
            TextButton(
              onPressed: _openEdit,
              child: const Text(
                'Editar',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        title: Text(
          'Transferência #${item.id}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E6E6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.data,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF313131),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.statusString,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FarmRow(label: 'Origem', nome: origem),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  _FarmRow(label: 'Destino', nome: destino),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.gtaDocumento != null)
                        _Chip(label: 'GTA ${item.gtaDocumento}'),
                      _Chip(
                        label:
                            '${item.qtdAnimais} ${item.qtdAnimais == 1 ? 'cabeça' : 'cabeças'}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFEDEDED)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Money(
                          label: 'Por animal',
                          value: item.valorUnitario,
                        ),
                      ),
                      Expanded(
                        child: _Money(
                          label: 'Total',
                          value: item.valorTotal,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Animais (${item.qtdAnimais})',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 12),
            if (item.animais.isEmpty)
              const Text(
                'Nenhum animal nesta transferência.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color(0xFF8A8A8A),
                ),
              ),
            for (final animal in shown) ...[
              _AnimalCard(animal: animal),
              const SizedBox(height: 8),
            ],
            if (remaining > 0)
              OutlinedButton(
                onPressed: () => setState(() => _visible += _pageSize),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MyColors.colorPrimary,
                  side: const BorderSide(color: MyColors.colorPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Ver mais ($remaining)'),
              ),
          ],
        ),
      ),
    );
  }
}

class _FarmRow extends StatelessWidget {
  const _FarmRow({required this.label, required this.nome});

  final String label;
  final String nome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: Color(0xFF8A8A8A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          nome,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Color(0xFF3D5346),
        ),
      ),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: Color(0xFF8A8A8A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.animal});

  final TransferenciaFazendaAnimal animal;

  @override
  Widget build(BuildContext context) {
    final brinco = animal.brinco ?? 's/ brinco';
    final categoria = [
      animal.categoria,
      animal.fase,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  brinco,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MyColors.colorPrimary,
                  ),
                ),
              ),
              if (categoria.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoria,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF313131),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (animal.piquete != null ||
              animal.lote != null ||
              animal.peso != null) ...[
            const SizedBox(height: 8),
            if (animal.piquete != null)
              _Fact(label: 'Piquete', value: animal.piquete!),
            if (animal.lote != null) _Fact(label: 'Lote', value: animal.lote!),
            if (animal.peso != null)
              _Fact(label: 'Peso', value: '${_peso(animal.peso!)} kg'),
          ],
        ],
      ),
    );
  }

  static String _peso(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Color(0xFF5C5C5C),
        ),
      ),
    );
  }
}
