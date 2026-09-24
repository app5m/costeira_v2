# Contrato de menus — `action` e `icon` (`/util/lista`)

App já lê `dashboard_menu`, `menu` e `menu_navigation`.
Hoje a API manda `action: null` e o app **infere pelo nome**.
Quando o `action` vier preenchido, o app usa o slug (não adivinha).

**Não enviar rota Flutter** (`/animals`, `/app`, `/potreiros/add`).

`animais_categorias`, `animais_bases_raciais` e `animais_sistemas_producoes` **não mudam**.

---

## O que o backend precisa fazer agora

1. Preencher `action` nas **folhas** com os slugs da seção 2 (ordem do JSON atual).
2. Pai com filhos (`menus_n1` / `menus_n2`) fica `action: null`.
3. Preencher `icon` com o **nome do arquivo** (ex: `compra.svg`). App concatena `https://costeira.app.br/uploads/icones/` + nome. Pais: `entrada.svg`, `saida.svg`, `manejo.svg`, `animais.svg`.
4. Item novo (nav, perfil ou FAB) + `status: 1` + `action` → o app mostra. Slug desconhecido → tela Em breve.

---

## 1. Gabarito

### Regras

| Campo | Contrato |
|---|---|
| `action` | slug snake_case, sem acento. Ex: `compra`, `transferencia_recebida` |
| `action` em **pai** (tem `menus_n1` / `menus_n2`) | `null` — toque abre a lista de filhos |
| `action` em **folha** | **obrigatório** — abre a tela |
| `action` `null` / `""` na folha | app tenta inferir pelo `nome` (provisório; não depender) |
| slug desconhecido | tela **Em breve** |
| `icon` | **só o nome do arquivo**: `compra.svg`. App monta `https://costeira.app.br/uploads/icones/compra.svg`. Também aceita URL absoluta. GET sem login. |
| `icon` `null` / `""` | sem ícone. App deixa vazio. |
| `status = 1` | visível |
| `status != 1` | esconde |
| exceção | item nav `dashboard` permanece mesmo com `status: 2` |
| `app_permissoes_id` | id de `POST /usuarios/listarPermissoes` (sub-usuário) |

`estoque` no FAB = entrada de insumo. `estoque` no perfil = lista de estoque. Mesmo slug, o app decide pelo menu (dashboard vs perfil).

### Dashboard FAB (`dashboard_menu`) — folha abre formulário

Slugs da árvore **atual** (preencher agora): `compra`, `nascimento`, `transferencia_recebida`, `estoque`, `venda`, `morte`, `transferencia_enviada`, `baixa_estoque`, `manejo_animal`, `manejo_reprodutivo`, `manejo_campo`.

`Morte/Baixa` com `action: morte` abre só o form de morte. Para abigeato/consumo, criar `menus_n2` com esses slugs.

`Manejo Animal` com `action: manejo_animal` abre sanitário. Para suplementação / piquete / categoria, criar `menus_n2`.

`Manejo Reprodutivo` hoje → Em breve, até ter filhos n2.

Todos os slugs que o app já entende no FAB (atuais + se criar filhos):

| action | Abre |
|---|---|
| `compra` | Compra de animais |
| `nascimento` | Nascimento |
| `parto` | Nascimento (mesmo form) |
| `transferencia_recebida` | Transferência recebida |
| `transferencia_enviada` | Transferência enviada |
| `movimentacao_de_piquete` | Movimentação de piquete |
| `venda` | Venda |
| `morte` | Morte |
| `abigeato` | Abigeato |
| `consumo` | Consumo / carnear |
| `estoque` | Entrada de estoque |
| `estoque_entrada` | Entrada de estoque |
| `baixa_estoque` | Baixa de estoque |
| `manejo_animal` | Manejo sanitário |
| `sanitario` | Manejo sanitário |
| `suplementacao` | Suplementação |
| `troca_de_categoria` | Troca de categoria |
| `aborto` | Aborto |
| `manejo_campo` | Manejo de campo |
| `manejo_reprodutivo` | Em breve (até ter filhos n2: parto, aborto, iatf…) |

### Perfil (`menu`) — folha abre lista / módulo

| action | Abre |
|---|---|
| `potreiros` | Potreiros e carga animal |
| `estoque` | Estoque |
| `tarefas` | Tarefas |
| `pluviosidade` | Clima e chuva |
| `fornecedores` | Fornecedores |
| `compradores` | Compradores |
| `usuarios` | Usuários e acessos |
| `indicadores` | Em breve |
| `relatorios` | Em breve |

Não enviar no JSON: alterar dados, senha, desativar conta. Ficam fixos no app.

### Bottom bar (`menu_navigation`)

| action | Aba |
|---|---|
| `dashboard` | Dashboard |
| `fazendas` | Fazendas |
| `animais` | Animais |
| `manejos` | Manejos |
| `perfil` | Perfil |

### `icon` — nome do arquivo em `https://costeira.app.br/uploads/icones`

Sobe os SVG de `docs/icons-backend/` nessa pasta. No JSON manda **só o nome**. App concatena.

```json
"icon": "compra.svg"
```

vira `https://costeira.app.br/uploads/icones/compra.svg`

Sem extensão (`"icon": "compra"`) o app acrescenta `.svg`. URL absoluta também vale.

Ícone **público** (GET sem token). Stroke `currentColor`.

| item | icon (JSON) | URL final |
|---|---|---|
| Entradas (pai) | `entrada.svg` | `https://costeira.app.br/uploads/icones/entrada.svg` |
| Saídas (pai) | `saida.svg` | `https://costeira.app.br/uploads/icones/saida.svg` |
| Manejo (pai) | `manejo.svg` | `https://costeira.app.br/uploads/icones/manejo.svg` |
| Animais (n1 / nav) | `animais.svg` | `https://costeira.app.br/uploads/icones/animais.svg` |
| Compra | `compra.svg` | `https://costeira.app.br/uploads/icones/compra.svg` |
| Nascimento | `nascimento.svg` | `https://costeira.app.br/uploads/icones/nascimento.svg` |
| Transferência Recebida | `transferencia_recebida.svg` | `https://costeira.app.br/uploads/icones/transferencia_recebida.svg` |
| Estoque (FAB e perfil) | `estoque.svg` | `https://costeira.app.br/uploads/icones/estoque.svg` |
| Venda | `venda.svg` | `https://costeira.app.br/uploads/icones/venda.svg` |
| Morte/Baixa | `morte.svg` | `https://costeira.app.br/uploads/icones/morte.svg` |
| Transferência Enviada | `transferencia_enviada.svg` | `https://costeira.app.br/uploads/icones/transferencia_enviada.svg` |
| Baixa de Estoque | `baixa_estoque.svg` | `https://costeira.app.br/uploads/icones/baixa_estoque.svg` |
| Manejo Animal | `manejo_animal.svg` | `https://costeira.app.br/uploads/icones/manejo_animal.svg` |
| Manejo Reprodutivo | `manejo_reprodutivo.svg` | `https://costeira.app.br/uploads/icones/manejo_reprodutivo.svg` |
| Manejo de Campo | `manejo_campo.svg` | `https://costeira.app.br/uploads/icones/manejo_campo.svg` |
| Potreiros | `potreiros.svg` | `https://costeira.app.br/uploads/icones/potreiros.svg` |
| Tarefas | `tarefas.svg` | `https://costeira.app.br/uploads/icones/tarefas.svg` |
| Pluviosidade | `pluviosidade.svg` | `https://costeira.app.br/uploads/icones/pluviosidade.svg` |
| Indicadores | `indicadores.svg` | `https://costeira.app.br/uploads/icones/indicadores.svg` |
| Relatórios | `relatorios.svg` | `https://costeira.app.br/uploads/icones/relatorios.svg` |
| Fornecedores | `fornecedores.svg` | `https://costeira.app.br/uploads/icones/fornecedores.svg` |
| Compradores | `compradores.svg` | `https://costeira.app.br/uploads/icones/compradores.svg` |
| Usuários | `usuarios.svg` | `https://costeira.app.br/uploads/icones/usuarios.svg` |
| Dashboard | `dashboard.svg` | `https://costeira.app.br/uploads/icones/dashboard.svg` |
| Fazendas | `fazendas.svg` | `https://costeira.app.br/uploads/icones/fazendas.svg` |
| Manejos (nav) | `manejos.svg` | `https://costeira.app.br/uploads/icones/manejos.svg` |
| Perfil | `perfil.svg` | `https://costeira.app.br/uploads/icones/perfil.svg` |

Slugs extras (se criar `menus_n2`): `parto.svg`, `abigeato.svg`, `consumo.svg`, `sanitario.svg`, `suplementacao.svg`, `troca_de_categoria.svg`, `aborto.svg`, `movimentacao_de_piquete.svg`, `financeiro.svg`.

Pais **Módulos** e **Cadastros** (só agrupam): `icon: null`.

---

## 2. O que colocar em cada `action` + `icon` (ordem do `/util/lista`)

Pai = `action: null` + ícone do grupo. Folha = slug + ícone do slug.

### `dashboard_menu`

1. Entradas → `action: null` · `entrada.svg`
   1. Animais → `action: null` · `animais.svg`
      1. Compra → `compra` · `compra.svg`
      2. Nascimento → `nascimento` · `nascimento.svg`
      3. Transferência Recebida → `transferencia_recebida` · `transferencia_recebida.svg`
   2. Estoque → `estoque` · `estoque.svg`
2. Saídas → `action: null` · `saida.svg`
   1. Venda de Animais → `venda` · `venda.svg`
   2. Morte/Baixa → `morte` · `morte.svg`
   3. Transferência Enviada → `transferencia_enviada` · `transferencia_enviada.svg`
   4. Baixa de Estoque → `baixa_estoque` · `baixa_estoque.svg`
3. Manejo → `action: null` · `manejo.svg`
   1. Manejo Animal → `manejo_animal` · `manejo_animal.svg`
   2. Manejo Reprodutivo → `manejo_reprodutivo` · `manejo_reprodutivo.svg`
   3. Manejo de Campo → `manejo_campo` · `manejo_campo.svg`

### `menu`

1. Módulos → `action: null` · `icon: null`
   1. Potreiros → `potreiros` · `potreiros.svg`
   2. Estoque → `estoque` · `estoque.svg`
   3. Tarefas → `tarefas` · `tarefas.svg`
   4. Pluviosidade → `pluviosidade` · `pluviosidade.svg`
   5. Indicadores → `indicadores` · `indicadores.svg`
   6. Relatórios → `relatorios` · `relatorios.svg`
2. Cadastros → `action: null` · `icon: null`
   1. Fornecedores → `fornecedores` · `fornecedores.svg`
   2. Compradores → `compradores` · `compradores.svg`
   3. Usuários e Acessos → `usuarios` · `usuarios.svg`

### `menu_navigation`

1. Dashboard → `dashboard` · `dashboard.svg`
2. Fazendas → `fazendas` · `fazendas.svg`
3. Animais → `animais` · `animais.svg`
4. Manejos → `manejos` · `manejos.svg`
5. Perfil → `perfil` · `perfil.svg`

---

## 3. JSON alvo (mesma árvore, `action` preenchido)

JSON alvo com `icon` = nome do arquivo. Sobe `docs/icons-backend/*.svg` em `https://costeira.app.br/uploads/icones`.

```json
{
    "dashboard_menu": {
        "menus": [
            {
                "id": 1,
                "app_permissoes_id": null,
                "categoria": "dashboard",
                "nome": "Entradas",
                "descricao": "Compra - Nascimento - Transferência",
                "action": null,
                "icon": "entrada.svg",
                "ordem": 1,
                "status": 1,
                "menus_n1": [
                    {
                        "id": 1,
                        "app_menus_id": 1,
                        "app_permissoes_id": 2,
                        "nome": "Animais",
                        "descricao": "Registre a entrada de animais vivos no rebanho: compra, nascimento ou transferência recebida de outra propriedade.",
                        "action": null,
                        "icon": "animais.svg",
                        "ordem": 1,
                        "status": 1,
                        "menus_n2": [
                            {
                                "id": 1,
                                "app_menus_nivel1_id": 1,
                                "app_permissoes_id": null,
                                "nome": "Compra",
                                "descricao": "Animais adquiridos de terceiros com nota fiscal e documentação de transporte.",
                                "action": "compra",
                                "icon": "compra.svg",
                                "ordem": 1,
                                "status": 1
                            },
                            {
                                "id": 2,
                                "app_menus_nivel1_id": 1,
                                "app_permissoes_id": null,
                                "nome": "Nascimento",
                                "descricao": "Cria nascida na propriedade, vinculada ao brinco e registro da mãe.",
                                "action": "nascimento",
                                "icon": "nascimento.svg",
                                "ordem": 2,
                                "status": 1
                            },
                            {
                                "id": 3,
                                "app_menus_nivel1_id": 1,
                                "app_permissoes_id": null,
                                "nome": "Transferência Recebida",
                                "descricao": "Animal transferido de outra propriedade com importação do histórico de manejos.",
                                "action": "transferencia_recebida",
                                "icon": "transferencia_recebida.svg",
                                "ordem": 3,
                                "status": 1
                            }
                        ]
                    },
                    {
                        "id": 2,
                        "app_menus_id": 1,
                        "app_permissoes_id": 4,
                        "nome": "Estoque",
                        "descricao": "Entrada de medicamentos, rações, suplementos e outros insumos do almoxarifado da fazenda.",
                        "action": "estoque",
                        "icon": "estoque.svg",
                        "ordem": 2,
                        "status": 1,
                        "menus_n2": []
                    }
                ]
            },
            {
                "id": 2,
                "app_permissoes_id": null,
                "categoria": "dashboard",
                "nome": "Saídas",
                "descricao": "Venda - Abate - Baixa",
                "action": null,
                "icon": "saida.svg",
                "ordem": 2,
                "status": 1,
                "menus_n1": [
                    {
                        "id": 3,
                        "app_menus_id": 2,
                        "app_permissoes_id": 2,
                        "nome": "Venda de Animais",
                        "descricao": "Animais vendidos para terceiros com registro de nota e valores.",
                        "action": "venda",
                        "icon": "venda.svg",
                        "ordem": 1,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 4,
                        "app_menus_id": 2,
                        "app_permissoes_id": 2,
                        "nome": "Morte/Baixa",
                        "descricao": "Morte, abigeato ou consumo interno com rastreabilidade.",
                        "action": "morte",
                        "icon": "morte.svg",
                        "ordem": 2,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 5,
                        "app_menus_id": 2,
                        "app_permissoes_id": 2,
                        "nome": "Transferência Enviada",
                        "descricao": "Animal transferido para outra propriedade do mesmo titular — sem movimentação bancária.",
                        "action": "transferencia_enviada",
                        "icon": "transferencia_enviada.svg",
                        "ordem": 3,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 6,
                        "app_menus_id": 2,
                        "app_permissoes_id": 4,
                        "nome": "Baixa de Estoque",
                        "descricao": "Uso de insumos fora de um manejo registrado.",
                        "action": "baixa_estoque",
                        "icon": "baixa_estoque.svg",
                        "ordem": 4,
                        "status": 1,
                        "menus_n2": []
                    }
                ]
            },
            {
                "id": 3,
                "app_permissoes_id": null,
                "categoria": "dashboard",
                "nome": "Manejo",
                "descricao": "Pesagem - Vacina - IATF",
                "action": null,
                "icon": "manejo.svg",
                "ordem": 3,
                "status": 1,
                "menus_n1": [
                    {
                        "id": 7,
                        "app_menus_id": 3,
                        "app_permissoes_id": 2,
                        "nome": "Manejo Animal",
                        "descricao": "Pesagem, vacinação, vermifugação, suplementação, movimentação de piquete, troca de categoria, castração e identificação.",
                        "action": "manejo_animal",
                        "icon": "manejo_animal.svg",
                        "ordem": 1,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 8,
                        "app_menus_id": 3,
                        "app_permissoes_id": 2,
                        "nome": "Manejo Reprodutivo",
                        "descricao": "Entrada/retirada de touro, IATF, diagnóstico de gestação, parto e aborto.",
                        "action": "manejo_reprodutivo",
                        "icon": "manejo_reprodutivo.svg",
                        "ordem": 2,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 9,
                        "app_menus_id": 3,
                        "app_permissoes_id": 5,
                        "nome": "Manejo de Campo",
                        "descricao": "Adubação, calagem, roçada, implantação de pastagem, controle de invasoras e irrigação por piquete.",
                        "action": "manejo_campo",
                        "icon": "manejo_campo.svg",
                        "ordem": 3,
                        "status": 1,
                        "menus_n2": []
                    }
                ]
            }
        ]
    },
    "menu": {
        "menus": [
            {
                "id": 9,
                "app_permissoes_id": null,
                "categoria": "perfil",
                "nome": "Módulos",
                "descricao": null,
                "action": null,
                "icon": null,
                "ordem": 1,
                "status": 1,
                "menus_n1": [
                    {
                        "id": 10,
                        "app_menus_id": 9,
                        "app_permissoes_id": 3,
                        "nome": "Potreiros",
                        "descricao": null,
                        "action": "potreiros",
                        "icon": "potreiros.svg",
                        "ordem": 1,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 11,
                        "app_menus_id": 9,
                        "app_permissoes_id": 4,
                        "nome": "Estoque",
                        "descricao": null,
                        "action": "estoque",
                        "icon": "estoque.svg",
                        "ordem": 2,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 12,
                        "app_menus_id": 9,
                        "app_permissoes_id": 13,
                        "nome": "Tarefas",
                        "descricao": null,
                        "action": "tarefas",
                        "icon": "tarefas.svg",
                        "ordem": 3,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 13,
                        "app_menus_id": 9,
                        "app_permissoes_id": 12,
                        "nome": "Pluviosidade",
                        "descricao": null,
                        "action": "pluviosidade",
                        "icon": "pluviosidade.svg",
                        "ordem": 4,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 14,
                        "app_menus_id": 9,
                        "app_permissoes_id": 7,
                        "nome": "Indicadores",
                        "descricao": null,
                        "action": "indicadores",
                        "icon": "indicadores.svg",
                        "ordem": 5,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 15,
                        "app_menus_id": 9,
                        "app_permissoes_id": 14,
                        "nome": "Relatórios",
                        "descricao": null,
                        "action": "relatorios",
                        "icon": "relatorios.svg",
                        "ordem": 6,
                        "status": 1,
                        "menus_n2": []
                    }
                ]
            },
            {
                "id": 10,
                "app_permissoes_id": null,
                "categoria": "perfil",
                "nome": "Cadastros",
                "descricao": null,
                "action": null,
                "icon": null,
                "ordem": 2,
                "status": 1,
                "menus_n1": [
                    {
                        "id": 16,
                        "app_menus_id": 10,
                        "app_permissoes_id": 11,
                        "nome": "Fornecedores",
                        "descricao": null,
                        "action": "fornecedores",
                        "icon": "fornecedores.svg",
                        "ordem": 1,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 17,
                        "app_menus_id": 10,
                        "app_permissoes_id": 12,
                        "nome": "Compradores",
                        "descricao": null,
                        "action": "compradores",
                        "icon": "compradores.svg",
                        "ordem": 2,
                        "status": 1,
                        "menus_n2": []
                    },
                    {
                        "id": 18,
                        "app_menus_id": 10,
                        "app_permissoes_id": 10,
                        "nome": "Usuários e Acessos",
                        "descricao": null,
                        "action": "usuarios",
                        "icon": "usuarios.svg",
                        "ordem": 3,
                        "status": 1,
                        "menus_n2": []
                    }
                ]
            }
        ]
    },
    "menu_navigation": {
        "menus": [
            {
                "id": 4,
                "app_permissoes_id": null,
                "categoria": "navigation",
                "nome": "Dashboard",
                "descricao": null,
                "action": "dashboard",
                "icon": "dashboard.svg",
                "ordem": 1,
                "status": 2,
                "menus_n1": []
            },
            {
                "id": 5,
                "app_permissoes_id": null,
                "categoria": "navigation",
                "nome": "Fazendas",
                "descricao": null,
                "action": "fazendas",
                "icon": "fazendas.svg",
                "ordem": 2,
                "status": 1,
                "menus_n1": []
            },
            {
                "id": 6,
                "app_permissoes_id": 2,
                "categoria": "navigation",
                "nome": "Animais",
                "descricao": null,
                "action": "animais",
                "icon": "animais.svg",
                "ordem": 3,
                "status": 1,
                "menus_n1": []
            },
            {
                "id": 7,
                "app_permissoes_id": 5,
                "categoria": "navigation",
                "nome": "Manejos",
                "descricao": null,
                "action": "manejos",
                "icon": "manejos.svg",
                "ordem": 4,
                "status": 1,
                "menus_n1": []
            },
            {
                "id": 8,
                "app_permissoes_id": null,
                "categoria": "navigation",
                "nome": "Perfil",
                "descricao": null,
                "action": "perfil",
                "icon": "perfil.svg",
                "ordem": 5,
                "status": 1,
                "menus_n1": []
            }
        ]
    }
}
```

`animais_categorias`, `animais_bases_raciais` e `animais_sistemas_producoes` não mudam. Sem `action` / `icon`.
