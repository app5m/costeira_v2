# Web no mesmo app

Flutter web deste repositório. Sem projeto novo e sem controller novo.

Este arquivo fica em `web/` na raiz. Tela Dart não entra aqui. Se o Flutter gerar `index.html` nesta pasta, deixa ele.

## Onde escrever

View web: `lib/features/<feature>/presentation/web/`

View mobile: `presentation/pages/`. Não editar.

Não copiar `domain/`, `infra/`, usecase, model nem binds. O bind já existe, por exemplo `lib/features/manejos_animais/manejos_animais_binds.dart`. A tela pega o controller com `Modular.get`.

## Controller

A página lê os getters e chama os métodos do controller. Ele é `ChangeNotifier` e já guarda `TextEditingController`. Exemplo: `ManejoReprodutivoController`.

Post, filtro, estoque e validação ficam no controller. Não reescrever isso na view.

Se faltar um dado na tela, acrescentar getter ou método no controller sem mudar o que o mobile já chama.

## Troca de tela

`kIsWeb` só na hora de escolher a página. O shell é `lib/features/base/pages/main_navigation_page.dart`: no browser, menu lateral no lugar da barra de baixo. O controller das duas telas é o mesmo.

## Ordem

Login, dashboard, fazendas, animais, movimentações, manejos.

Não entrar em fluxo que o mobile ainda está abrindo.

## Browser

Quando a tela usar, tratar no plugin: `geolocator`, `image_picker`, `permission_handler`, `firebase_messaging`. Hive e a API seguem iguais.
