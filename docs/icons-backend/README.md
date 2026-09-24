# Ícones dos menus (pra backend)

SVG Lucide — o mesmo visual que o app usa hoje no default.
Sobe em `https://costeira.app.br/uploads/icones`. No `/util/lista` manda **só o nome**:

```json
"icon": "compra.svg"
```

App concatena → `https://costeira.app.br/uploads/icones/compra.svg`

`icon: null` = sem ícone. App deixa vazio.

Pasta: `docs/icons-backend/`

| arquivo | action | Lucide |
|---|---|---|
| `dashboard.svg` | `dashboard` | layout-dashboard |
| `fazendas.svg` | `fazendas` | warehouse |
| `animais.svg` | `animais` | beef |
| `manejos.svg` | `manejos` | clipboard-list |
| `movimentacoes.svg` | `movimentacoes` | arrow-left-right |
| `perfil.svg` | `perfil` | user |
| `potreiros.svg` | `potreiros` | map |
| `estoque.svg` | `estoque` | package |
| `tarefas.svg` | `tarefas` | square-check |
| `pluviosidade.svg` | `pluviosidade` | cloud-rain |
| `fornecedores.svg` | `fornecedores` | truck |
| `compradores.svg` | `compradores` | shopping-bag |
| `usuarios.svg` | `usuarios` | users |
| `compra.svg` | `compra` | shopping-cart |
| `venda.svg` | `venda` | banknote |
| `nascimento.svg` | `nascimento` | baby |
| `morte.svg` | `morte` | skull |
| `manejo_animal.svg` | `manejo_animal` | stethoscope |
| `entrada.svg` | (pai Entradas) | plus |
| `saida.svg` | (pai Saídas) | minus |
| `manejo.svg` | (pai Manejo) | clipboard-list |
| `transferencia_recebida.svg` | `transferencia_recebida` | import |
| `transferencia_enviada.svg` | `transferencia_enviada` | upload |
| `movimentacao_de_piquete.svg` | `movimentacao_de_piquete` | move |
| `baixa_estoque.svg` | `baixa_estoque` | package-minus |
| `manejo_campo.svg` | `manejo_campo` | sprout |
| `manejo_reprodutivo.svg` | `manejo_reprodutivo` | heart |
| `indicadores.svg` | `indicadores` | chart-column |
| `relatorios.svg` | `relatorios` | file-text |
| `parto.svg` | `parto` | baby |
| `abigeato.svg` | `abigeato` | shield-alert |
| `consumo.svg` | `consumo` | utensils |
| `sanitario.svg` | `sanitario` | syringe |
| `suplementacao.svg` | `suplementacao` | wheat |
| `troca_de_categoria.svg` | `troca_de_categoria` | replace |
| `aborto.svg` | `aborto` | heart-crack |
| `financeiro.svg` | `financeiro` | wallet |

A pasta `icon/` do app **não** é este catálogo. Lá tem lixeira, seta, noti, etc. da UI.

Stroke = `currentColor`. Dá pra pintar no app/web.
