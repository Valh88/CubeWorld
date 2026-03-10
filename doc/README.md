# Документация CubeWorld

Обзор документации библиотеки CubeWorld (воксельные миры в стиле Minecraft, FreePascal).

## Содержание

| Документ | Описание |
|----------|----------|
| [architecture.md](architecture.md) | Архитектура библиотеки: модули, модель данных, хранилище, генерация, потоки данных. |
| [chunks_and_blocks.md](chunks_and_blocks.md) | Как управляются чанки и блоки: когда чанк создаётся, полный/неполный чанк, разреженность мира. |

## Кратко о библиотеке

- **Мир** — `TWorld`: чанки создаются по требованию при `SetBlock` или `EnsureChunk`.
- **Блоки** — доступ по глобальным координатам `TBlockPos`; внутри чанка — массив 16×16×16.
- **Координаты** — см. [architecture.md](architecture.md) и вспомогательные функции в `cuboworld` (`BlockPosToWorldCenter`, `WorldToBlockPos` и т.д.).
- **Подключение** — пакет `Package/cuboworldpackage.lpk`, в коде `uses cuboworld;`.
- **Пример** — проект `Example/CubeWorldExample.lpr`.

Корневой [README.md](../README.md) проекта дублирует быстрый старт и ссылки на эту папку.
