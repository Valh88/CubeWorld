program CubeWorldExample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils,
  cuboworld; // достаточно фасада, он реэкспортирует все типы

var
  World: TWorld;
  Storage: IWorldStorage;
  Generator: IChunkGenerator;
  Pos: TBlockPos;
  Block: TBlock;
  WorldCorner: TWorldVec3;
  ChunkCoord: TChunkCoord;
  LocalX, LocalY, LocalZ: Integer;
  WorldCenter: TWorldVec3;
  WorldFromCenter: TBlockPos;
begin
  Storage := TMemoryWorldStorage.Create;
  Generator := TFlatGenerator.Create(4, 1); // ground up to Y<4, block id 1
  World := TWorld.Create(Storage, Generator);
  try
    Writeln('=== CubeWorld library demo ===');

    // 1) Чтение/запись блока по глобальным индексам
    Pos.X := 0;
    Pos.Y := 0;
    Pos.Z := 0;

    Block := World.GetBlock(Pos);
    Writeln('Initial block at (0,0,0): ', Block.Id);

    Block.Id := 2; // ставим произвольный блок
    World.SetBlock(Pos, Block);

    // 2) Работа с соседним блоком
    Block.Id := 5;
    Pos.X := 1;
    Pos.Y := 0;
    Pos.Z := 0;
    World.SetBlock(Pos, Block);

    // 3) Преобразование индекса блока в мировые координаты
    WorldCorner := BlockPosToWorldCorner(Pos, 16); // размер блока 16 мировых единиц
    Writeln('World corner at block (1,0,0) with BlockSize=16: ',
      WorldCorner.X:0:1, ', ', WorldCorner.Y:0:1, ', ', WorldCorner.Z:0:1);

    WorldCenter := BlockPosToWorldCenter(Pos, 16);
    Writeln('World center at block (1,0,0): ',
      WorldCenter.X:0:1, ', ', WorldCenter.Y:0:1, ', ', WorldCenter.Z:0:1);

    // 4) Обратное преобразование: из мировых координат обратно в индекс блока
    WorldFromCenter := WorldToBlockPos(WorldCenter, 16);
    Writeln('Block index from world center: (',
      WorldFromCenter.X, ',', WorldFromCenter.Y, ',', WorldFromCenter.Z, ')');

    // 5) Преобразование глобальных координат в координаты чанка и локальные индексы
    BlockPosToChunkAndLocal(Pos, ChunkCoord, LocalX, LocalY, LocalZ);
    Writeln('Block (1,0,0) resides in chunk (',
      ChunkCoord.X, ',', ChunkCoord.Y, ',', ChunkCoord.Z,
      '), local index (', LocalX, ',', LocalY, ',', LocalZ, ')');

    // 6) Чтение блока обратно, чтобы убедиться, что запись сработала
    Block := World.GetBlock(Pos);
    Writeln('After SetBlock, block at (1,0,0): ', Block.Id);

    // 7) Вызов Update (в реальной игре он будет вызываться каждый кадр)
    World.Update(1.0 / 60.0); // имитация кадра ~60 FPS

    Readln;
  finally
    World.Free;
  end;
end.

