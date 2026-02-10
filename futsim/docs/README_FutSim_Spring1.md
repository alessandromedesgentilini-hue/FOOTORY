# FutSim – Spring 1 Starter Pack (v2)

**Conteúdo**: save_state, seed_repo, roster_pipeline, mods/overrides, mod_installer,
skeleton de players/rosters (Série A).

## Instalação
1. Extraia `lib/` e `docs/` na raiz do seu projeto Flutter.
2. Certifique-se de que existe `lib/models/jogador.dart` (modelo).
3. Ajuste imports se preciso, remova duplicatas antigas (ex.: `Lib/...`).

## Uso básico
```dart
final save = SeedRepo().createInitialSaveSerieA();
final overrides = await ModInstaller.readActivePack(); // opcional
final catalogo = RosterPipeline(SeedRepo()).buildCatalog(overrides: overrides);
```
