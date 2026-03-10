## CubeWorld Library

Библиотека для создания воксельных (кубических) миров в стиле Minecraft.
Написана на FreePascal, без привязки к конкретному движку (Leadwerks, Castle Game Engine и т.д.).

### Возможности

- **Хранение мира**: разбиение на чанки фиксированного размера (по умолчанию 16×16×16).
- **Работа с блоками**: чтение/запись блоков по глобальным координатам.
- **Процедурная генерация**: генераторы чанков через интерфейс `IChunkGenerator`.
- **Хранилища**: абстракция над хранением чанков (`IWorldStorage`), есть in‑memory реализация.
- **События**: уведомления о создании и изменении чанков для синхронизации с рендером.

### Основные типы (через фасад `cuboworld`)

- `TWorld` — мир, точка входа для работы.
- `TBlockId`, `TBlock` — тип и данные блока.
- `TBlockPos` — глобальные координаты блока.
- `TChunkCoord`, `TChunk` — координаты и содержимое чанка.
- `IWorldStorage`, `TMemoryWorldStorage` — интерфейс и простое хранилище мира.
- `IChunkGenerator`, `TFlatGenerator` — интерфейс и плоский генератор мира.

### Подключение в Lazarus

1. Откройте пакет `Package/cuboworldpackage.lpk` и установите его (Install).
2. В проекте добавьте пакет `CuboWorldPackage` в **Required Packages**.
3. В `uses` своих модулей укажите:

```pascal
uses
  cuboworld;
```

После этого станут доступны типы `TWorld`, `TBlock`, `TBlockPos` и т.д.

### Быстрый пример

См. проект в каталоге `Example/` (`CubeWorldExample.lpr`), упрощённо:

```pascal
uses
  cuboworld;

var
  World: TWorld;
  Storage: IWorldStorage;
  Generator: IChunkGenerator;
  Pos: TBlockPos;
  Block: TBlock;
begin
  Storage := TMemoryWorldStorage.Create;
  Generator := TFlatGenerator.Create(4, 1); // земля до Y<4, блок id=1
  World := TWorld.Create(Storage, Generator);
  try
    Pos.X := 0;
    Pos.Y := 0;
    Pos.Z := 0;

    Block := World.GetBlock(Pos);
    Writeln('Initial block: ', Block.Id);

    Block.Id := 2;
    World.SetBlock(Pos, Block);

    Block := World.GetBlock(Pos);
    Writeln('After SetBlock: ', Block.Id);
  finally
    World.Free;
  end;
end.
```

### Где смотреть устройство

- Архитектура и внутреннее устройство описаны в `doc/architecture.md`.
- Исходный код библиотеки лежит в `Src/cuboworld`.

