import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencias_fazenda_list_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class TransferenciaFazendaCard extends StatelessWidget {
  const TransferenciaFazendaCard({
    super.key,
    required this.item,
    required this.recebidas,
    required this.onOpen,
    required this.onDecidir,
  });

  final TransferenciaFazendaListItem item;
  final bool recebidas;
  final VoidCallback onOpen;
  final Future<void> Function(int id, int status) onDecidir;

  @override
  Widget build(BuildContext context) {
    final origem = item.fazendaOrigem?.nome ?? 'Origem';
    final destino = item.fazendaDestino?.nome ?? 'Destino';
    final pendente = recebidas && item.pendente && item.id > 0;
    final statusColor = switch (item.statusTransferencia) {
      1 => (bg: const Color(0xFFE7F6EC), fg: MyColors.colorPrimary),
      3 => (bg: const Color(0xFFFDECEC), fg: const Color(0xFFC62828)),
      _ => (bg: const Color(0xFFFFF4E5), fg: const Color(0xFFB86E00)),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _FarmName(nome: origem)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  Expanded(child: _FarmName(nome: destino, alignEnd: true)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.gtaDocumento != null)
                    _MetaChip(label: 'GTA ${item.gtaDocumento}'),
                  _MetaChip(
                    label:
                        '${item.qtdAnimais} ${item.qtdAnimais == 1 ? 'cabeça' : 'cabeças'}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEDEDED)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Money(label: 'Por animal', value: item.valorUnitario),
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
              if (pendente) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onDecidir(
                          item.id,
                          TransferenciasFazendaListPageController.recusado,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFC62828)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Recusar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => onDecidir(
                          item.id,
                          TransferenciasFazendaListPageController.aprovado,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: MyColors.colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Aceitar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmName extends StatelessWidget {
  const _FarmName({required this.nome, this.alignEnd = false});

  final String nome;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Text(
      nome,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: Color(0xFF1C1C1C),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }
}
