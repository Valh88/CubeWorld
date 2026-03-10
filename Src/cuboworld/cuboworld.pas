unit cuboworld;

{$mode objfpc}{$H+}

interface

uses
  cw_types,
  cw_chunk,
  cw_events,
  cw_storage_intf,
  cw_storage_mem,
  cw_generator_intf,
  cw_generator_flat,
  cw_world;

type
  // Re-export core types so users can just `uses cuboworld`.
  TBlockId = cw_types.TBlockId;
  TBlock = cw_types.TBlock;
  TChunkCoord = cw_types.TChunkCoord;
  TBlockPos = cw_types.TBlockPos;
  TWorldVec3 = cw_types.TWorldVec3;

  TChunk = cw_chunk.TChunk;

  TWorld = cw_world.TWorld;

  TChunkEvent = cw_events.TChunkEvent;

  IWorldStorage = cw_storage_intf.IWorldStorage;
  TMemoryWorldStorage = cw_storage_mem.TMemoryWorldStorage;

  IChunkGenerator = cw_generator_intf.IChunkGenerator;
  TFlatGenerator = cw_generator_flat.TFlatGenerator;

// This unit is a convenience facade re-exporting main CubeWorld API.

// Helper functions re-exported from cw_types for coordinate conversions.

// Перевод абсолютной позиции блока в координаты чанка и локальные координаты в чанке.
procedure BlockPosToChunkAndLocal(const APos: TBlockPos; out AChunk: TChunkCoord;
  out ALocalX, ALocalY, ALocalZ: Integer);

// Сборка абсолютной позиции блока из координат чанка и локальных координат.
function ChunkAndLocalToBlockPos(const AChunk: TChunkCoord;
  const ALocalX, ALocalY, ALocalZ: Integer): TBlockPos;

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

implementation

procedure BlockPosToChunkAndLocal(const APos: TBlockPos; out AChunk: TChunkCoord;
  out ALocalX, ALocalY, ALocalZ: Integer);
begin
  cw_types.BlockPosToChunkAndLocal(APos, AChunk, ALocalX, ALocalY, ALocalZ);
end;

function ChunkAndLocalToBlockPos(const AChunk: TChunkCoord;
  const ALocalX, ALocalY, ALocalZ: Integer): TBlockPos;
begin
  Result := cw_types.ChunkAndLocalToBlockPos(AChunk, ALocalX, ALocalY, ALocalZ);
end;

function BlockPosToWorldCorner(const APos: TBlockPos; const ABlockSize: Single
  ): TWorldVec3;
begin
  Result := cw_types.BlockPosToWorldCorner(APos, ABlockSize);
end;

function BlockPosToWorldCenter(const APos: TBlockPos; const ABlockSize: Single
  ): TWorldVec3;
begin
  Result := cw_types.BlockPosToWorldCenter(APos, ABlockSize);
end;

function WorldToBlockPos(const AWorld: TWorldVec3; const ABlockSize: Single
  ): TBlockPos;
begin
  Result := cw_types.WorldToBlockPos(AWorld, ABlockSize);
end;

end.

