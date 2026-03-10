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

implementation

end.

