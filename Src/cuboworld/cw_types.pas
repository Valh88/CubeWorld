unit cw_types;

{$mode objfpc}{$H+}

interface

type
  // Identifier of a block type.
  TBlockId = type Word;

  // Simple block data; can be extended later (light, metadata, etc.).
  TBlock = record
    Id: TBlockId;
  end;

  // Discrete chunk coordinates in world space.
  TChunkCoord = record
    X, Y, Z: Integer;
  end;

  // Absolute block coordinates in world space.
  TBlockPos = record
    X, Y, Z: Integer;
  end;

  // 3D-вектор в мировых координатах.
  TWorldVec3 = record
    X, Y, Z: Single;
  end;

// Преобразования координат блока и чанка.

// Перевод абсолютной позиции блока в координаты чанка и локальные координаты в чанке.
procedure BlockPosToChunkAndLocal(const APos: TBlockPos; out AChunk: TChunkCoord;
  out ALocalX, ALocalY, ALocalZ: Integer);

// Сборка абсолютной позиции блока из координат чанка и локальных координат.
function ChunkAndLocalToBlockPos(const AChunk: TChunkCoord;
  const ALocalX, ALocalY, ALocalZ: Integer): TBlockPos;

// Преобразования между индексами блока и мировыми координатами.

// Мировые координаты "минимального угла" блока (например, левый‑нижний‑задний угол),
// при размере блока ABlockSize.
function BlockPosToWorldCorner(const APos: TBlockPos; const ABlockSize: Single
  ): TWorldVec3;

// Мировые координаты центра блока при размере блока ABlockSize.
function BlockPosToWorldCenter(const APos: TBlockPos; const ABlockSize: Single
  ): TWorldVec3;

// Получить индекс блока по мировым координатам и размеру блока.
function WorldToBlockPos(const AWorld: TWorldVec3; const ABlockSize: Single
  ): TBlockPos;

const
  // Default chunk dimensions (can be generalized later).
  CChunkSizeX = 16;
  CChunkSizeY = 16;
  CChunkSizeZ = 16;

implementation

uses
  Math;

procedure BlockPosToChunkAndLocal(const APos: TBlockPos; out AChunk: TChunkCoord;
  out ALocalX, ALocalY, ALocalZ: Integer);
begin
  // Floor-деление: корректно для отрицательных координат (div/mod в Pascal для отрицательных дают неверный результат).
  AChunk.X := Trunc(Floor(APos.X / CChunkSizeX));
  AChunk.Y := Trunc(Floor(APos.Y / CChunkSizeY));
  AChunk.Z := Trunc(Floor(APos.Z / CChunkSizeZ));

  ALocalX := APos.X - AChunk.X * CChunkSizeX;
  ALocalY := APos.Y - AChunk.Y * CChunkSizeY;
  ALocalZ := APos.Z - AChunk.Z * CChunkSizeZ;
end;

function ChunkAndLocalToBlockPos(const AChunk: TChunkCoord;
  const ALocalX, ALocalY, ALocalZ: Integer): TBlockPos;
begin
  Result.X := AChunk.X * CChunkSizeX + ALocalX;
  Result.Y := AChunk.Y * CChunkSizeY + ALocalY;
  Result.Z := AChunk.Z * CChunkSizeZ + ALocalZ;
end;

function BlockPosToWorldCorner(const APos: TBlockPos; const ABlockSize: Single
  ): TWorldVec3;
begin
  Result.X := APos.X * ABlockSize;
  Result.Y := APos.Y * ABlockSize;
  Result.Z := APos.Z * ABlockSize;
end;

function BlockPosToWorldCenter(const APos: TBlockPos; const ABlockSize: Single
  ): TWorldVec3;
begin
  Result.X := (APos.X + 0.5) * ABlockSize;
  Result.Y := (APos.Y + 0.5) * ABlockSize;
  Result.Z := (APos.Z + 0.5) * ABlockSize;
end;

function WorldToBlockPos(const AWorld: TWorldVec3; const ABlockSize: Single
  ): TBlockPos;
begin
  // Используем Floor, чтобы корректно обрабатывать нецелые координаты.
  Result.X := Floor(AWorld.X / ABlockSize);
  Result.Y := Floor(AWorld.Y / ABlockSize);
  Result.Z := Floor(AWorld.Z / ABlockSize);
end;

end.

