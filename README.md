# ISP Conecta — Gestão de Ordens de Serviço Offline-First

<div align="center">

**Aplicativo mobile Flutter para técnicos de telecomunicações**

Arquitetura MVVM | Offline-First | SQLite | GPS | Câmera | HMAC-SHA256 | Sincronização Multipart

</div>

---

## Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Arquitetura](#arquitetura)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Requisitos Atendidos](#requisitos-atendidos)
- [Como Executar](#como-executar)
- [Testes](#testes)
- [Teste Offline (Modo Avião)](#teste-offline-modo-avião)
- [Melhorias Futuras](#melhorias-futuras)

---

## Sobre o Projeto

O **ISP Conecta** é um aplicativo Android desenvolvido em Flutter para técnicos de campo de provedores de internet (ISPs). O técnico trabalha frequentemente em áreas sem conectividade — subsolos, zonas rurais, garagens — e precisa consultar suas ordens de serviço, ordená-las por proximidade via GPS, registrar o parecer técnico e anexar fotos comprobatórias mesmo totalmente offline.

A sincronização com a nuvem acontece quando o sinal é restabelecido, com upload multipart/form-data e Bearer Token.

### Problema resolvido

- Técnicos em campo não podem depender de conexão permanente
- Necessidade de consultar OS, registrar atendimentos e anexar fotos offline
- Sincronização automática quando há conexão disponível
- Segurança: senha nunca trafega em texto plano (HMAC-SHA256)

---

## Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com camadas desacopladas:

```
┌─────────────────────────────────────────────────────┐
│                     VIEW (UI)                        │
│  SplashScreen · LoginScreen · HomeScreen            │
│  AtendimentoScreen · HistoricoScreen · Detalhe       │
└──────────────────────┬──────────────────────────────┘
                       │ (ChangeNotifier)
┌──────────────────────▼──────────────────────────────┐
│                  VIEWMODEL                           │
│  AuthViewModel · HomeViewModel                       │
│  AtendimentoViewModel · HistoricoViewModel           │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                 REPOSITORY                           │
│  AuthRepository · ChamadoRepository                  │
│  AtendimentoRepository                               │
└──────┬───────────────────────────────┬───────────────┘
       │                               │
┌──────▼──────────┐         ┌─────────▼───────────────┐
│  LOCAL DATASOURCE│         │   REMOTE DATASOURCE     │
│  (SQLite/sqflite)│         │   (API REST - HTTP)     │
│  DatabaseHelper   │         │   ApiDatasource          │
└──────────────────┘         └─────────────────────────┘
```

### Princípios

- **Offline-First**: o SQLite local é a fonte primária de dados. A API é usada apenas para carga inicial e sincronização.
- **Encapsulamento**: cada camada expõe apenas o necessário, escondendo detalhes de implementação.
- **Injeção de dependência manual**: ViewModels recebem repositórios via construtor, facilitando testes.

---

## Tecnologias Utilizadas

| Tecnologia | Função |
|---|---|
| **Flutter 3.x / Dart** | Framework mobile e linguagem |
| **sqflite** | Banco de dados local SQLite (offline-first) |
| **http** | Comunicação com API REST |
| **flutter_secure_storage** | Armazenamento seguro do token |
| **crypto** | HMAC-SHA256 para assinatura de senha |
| **geolocator** | Captura de GPS e cálculo de distância |
| **image_picker** | Captura de foto (câmera/galeria) |
| **connectivity_plus** | Detecção de status de rede |
| **path_provider** | Sistema de arquivos para salvar fotos |
| **permission_handler** | Solicitação de permissões Android |

---

## Estrutura de Pastas

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # URL da API, chave HMAC, rotas, categorias
│   ├── theme/
│   │   └── app_theme.dart              # Tema Material 3 da aplicação
│   └── utils/
│       ├── hmac_util.dart              # HMAC-SHA256 com chave secreta da turma
│       └── distance_util.dart          # Haversine para cálculo de distância
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── database_helper.dart    # SQLite: tabelas chamados e atendimentos
│   │   └── remote/
│   │       └── api_datasource.dart      # API REST: login, chamados, atendimento
│   ├── models/
│   │   ├── usuario_model.dart          # fromJson/toJson
│   │   ├── chamado_model.dart          # fromJson/toJson + fromMap/toMap
│   │   └── atendimento_model.dart      # fromJson/toJson + fromMap/toMap
│   └── repositories/
│       ├── auth_repository.dart        # Login, persistência de token, sessão
│       ├── chamado_repository.dart     # Carga da API, consulta local, status
│       └── atendimento_repository.dart # CRUD local, sync, filtro
├── viewmodels/
│   ├── auth_viewmodel.dart             # Estado de autenticação
│   ├── home_viewmodel.dart             # Chamados + GPS + ordenação
│   ├── atendimento_viewmodel.dart      # Formulário + foto + gravação
│   └── historico_viewmodel.dart        # Lista + filtro + sync
├── views/
│   ├── screens/
│   │   ├── splash_screen.dart          # Tela 01: verificação de sessão
│   │   ├── login_screen.dart           # Tela 02: login com HMAC-SHA256
│   │   ├── home_screen.dart            # Tela 03: chamados offline + GPS
│   │   ├── atendimento_screen.dart     # Tela 04: formulário + foto
│   │   ├── historico_screen.dart       # Tela 05: histórico + filtro + sync
│   │   └── detalhe_atendimento_screen.dart # Detalhe com foto
│   └── widgets/
│       ├── chamado_card.dart           # Card de chamado na Home
│       ├── atendimento_card.dart        # Card de atendimento no Histórico
│       └── sync_badge.dart              # Badge Sincronizado/Pendente
└── main.dart                           # Rotas nomeadas + injeção de dependência

test/
├── unit/
│   ├── chamado_model_test.dart         # Testes do modelo ChamadoModel
│   ├── atendimento_model_test.dart     # Testes do modelo AtendimentoModel
│   ├── api_datasource_test.dart        # Testes do datasource remoto (mock HTTP)
│   ├── atendimento_repository_test.dart # Testes do filtro do repositório
│   ├── hmac_util_test.dart             # Testes do HMAC-SHA256
│   └── distance_util_test.dart         # Testes do cálculo de distância
└── widget/
    ├── login_screen_test.dart          # Testes de widget da tela de Login
    └── detalhe_atendimento_screen_test.dart # Testes de widget da tela de Detalhe
```

---

## Requisitos Atendidos

### Funcionais

| RF | Descrição | Status |
|---|---|---|
| RF01 | Modelagem de entidades (Usuario, Chamado, Atendimento) com fromJson/toJson e fromMap/toMap | Implementado |
| RF02 | Splash Screen com verificação de sessão (auto-login via flutter_secure_storage) | Implementado |
| RF03 | Login com senha assinada via HMAC-SHA256 com chave secreta da turma | Implementado |
| RF04 | Persistência segura do token + carga inicial dos chamados no SQLite | Implementado |
| RF05 | SQLite local com tabelas chamados e atendimentos, operação 100% offline | Implementado |
| RF06 | Home com listagem de chamados abertos via ListView.builder (lazy loading) | Implementado |
| RF07 | GPS: cálculo de distância e ordenação por proximidade (Haversine) | Implementado |
| RF08 | Card com código, nome, categoria, resumo, endereço e distância + navegação | Implementado |
| RF09 | Tela de Atendimento com cabeçalho da OS + formulário (dropdown, texto, data, foto) | Implementado |
| RF10 | Validação estrita com GlobalKey + validators (categoria obrigatória, descrição min 10 chars) | Implementado |
| RF11 | Captura de foto (câmera/galeria) com compressão e salvamento no dispositivo | Implementado |
| RF12 | Conclusão do chamado: grava no SQLite (sincronizado=0), atualiza status para atendido | Implementado |
| RF13 | Sincronização multipart/form-data com Bearer Token, atualiza flag após 201 Created | Implementado |
| RF14 | Histórico com ListView.builder e badge Sincronizado/Pendente | Implementado |
| RF15 | Filtro em tempo real por ID do chamado ou código do cliente | Implementado |
| RF16 | Visualização detalhada com foto (Image.file local ou Image.network remota) | Implementado |

### Não Funcionais

| RNF | Descrição | Status |
|---|---|---|
| RNF01 | Testes unitários (datasources, repositories, models, utils) + 2 telas com testes de widget | Implementado |

---

## Como Executar

### Pré-requisitos

- Flutter 3.x instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou dispositivo físico com depuração USB ativada
- Credenciais de login (fornecidas pelo professor via Discord)

### Passo a passo

```bash
# 1. Clonar o repositório
git clone https://github.com/amandaespindulamachado/ProjFinalFlutterAmandaEspindulaMachado.git

# 2. Entrar no diretório
cd ProjFinalFlutterAmandaEspindulaMachado

# 3. Instalar dependências
flutter pub get

# 4. Rodar o app
flutter run
```

### Credenciais

- **E-mail e senha**: fornecidos pelo professor via Discord
- **Chave HMAC-SHA256**: `ISP_TECH_SENAI_2026_xK9#mQ2$vL8!zP4` (embutida no código)

### Permissões necessárias (Android)

O app solicita automaticamente:
- **Localização (GPS)**: para ordenação por proximidade
- **Câmera**: para captura de fotos comprobatórias
- **Armazenamento**: para salvar e ler fotos do dispositivo
- **Internet**: para carga inicial e sincronização

---

## Testes

```bash
flutter test
```

Cobertura:

- **6 arquivos de testes unitários** (45 testes no total)
  - Modelos: `ChamadoModel`, `AtendimentoModel` (fromJson/toJson/fromMap/toMap, copyWith, igualdade)
  - Datasource remoto: `ApiDatasource` (login, fetchChamados, erros) com mock de HTTP
  - Repositório: `AtendimentoRepository.filtrar` (RF15 - filtro por ID/código)
  - Utilitários: `HmacUtil` (determinístico, 64 chars, diferente do texto plano), `DistanceUtil` (Haversine, formatação)
- **2 arquivos de testes de widget**
  - `LoginScreen`: validação de campos, toggle de senha, exibição de erros
  - `DetalheAtendimentoScreen`: exibição de dados, badge de sync, foto

---

## Teste Offline (Modo Avião)

Para testar a operação 100% offline:

1. **Abra o app com internet** e faça login para carregar os chamados do SQLite
2. **Ative o modo avião** no dispositivo/emulador
3. **Abra a Home** — os chamados aparecem do banco local (banner "Modo Offline")
4. **Selecione um chamado**, preencha o formulário, tire uma foto e conclua
5. O atendimento é gravado no SQLite com status "Pendente de Envio"
6. **Desative o modo avião**
7. **Abra o Histórico** e toque no botão de sincronização (ícone de nuvem)
8. O app envia o atendimento via multipart/form-data para a API e marca como "Sincronizado"

---

## Melhorias Futuras

- [ ] Sincronização automática ao detectar reconexão (listener de conectividade)
- [ ] Push notifications para novos chamados atribuídos
- [ ] Exportação de relatório de atendimentos em PDF
- [ ] Modo escuro (Dark Theme)
- [ ] Testes de integração com banco SQLite em memória
- [ ] Suporte a múltiplas fotos por atendimento
- [ ] Mapa interativo com marcadores dos chamados
- [ ] Internacionalização (i18n) para inglês/espanhol

---

## API

- **URL Base**: `https://oquetemnomeucosmetico.com.br/api`
- **Documentação (Swagger)**: `https://oquetemnomeucosmetico.com.br/docs/`
- **Endpoints utilizados**:
  - `POST /login` — autenticação
  - `GET /chamados` — lista de ordens de serviço
  - `POST /atendimento` — upload multipart de atendimento
  - `GET /historico` — histórico de atendimentos

---

<div align="center">

**Projeto Avaliativo Final — Módulo 02 — Semana 12**

Mobile Flutter — Turma 02 — M1S12

</div>
