unit cw_world;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  cw_types, cw_chunk, cw_events, cw_storage_intf, cw_generator_intf;

type
  { TWorld
    Manages chunks and provides block-level access.
    Supports negative block coordinates (floor division for chunk/local mapping). }
  TWorld = class
  private
    FChunks: TStringList;
    FStorage: IWorldStorage;
    FGenerator: IChunkGenerator;
    FOnChunkCreated: TChunkEvent;
    FOnChunkChanged: TChunkEvent;

    function ChunkKey(const ACoord: TChunkCoord): string;
    function FindChunkIndex(const ACoord: TChunkCoord): Integer;
    function GetOrCreateChunk(const ACoord: TChunkCoord): TChunk;
  public
    constructor Create(const AStorage: IWorldStorage; const AGenerator: IChunkGenerator);
    destructor Destroy; override;

    function TryGetChunk(const ACoord: TChunkCoord; out AChunk: TChunk): Boolean;
    function EnsureChunk(const ACoord: TChunkCoord): TChunk;

    function GetBlock(const APos: TBlockPos): TBlock;
    procedure SetBlock(const APos: TBlockPos; const ABlock: TBlock);

    { Вызывать из цикла движка каждый кадр. Резерв для выгрузки далёких чанков,
      сохранения грязных чанков и т.п. }
    procedure Update(const ADeltaTimeSec: Single); virtual;

    property Storage: IWorldStorage read FStorage;
    property Generator: IChunkGenerator read FGenerator;
    property OnChunkCreated: TChunkEvent read FOnChunkCreated write FOnChunkCreated;
    property OnChunkChanged: TChunkEvent read FOnChunkChanged write FOnChunkChanged;
  end;

implementation

function TWorld.ChunkKey(const ACoord: TChunkCoord): string;
begin
  Result := IntToStr(ACoord.X) + ':' + IntToStr(ACoord.Y) + ':' + IntToStr(ACoord.Z);
end;

function TWorld.FindChunkIndex(const ACoord: TChunkCoord): Integer;
begin
  if FChunks.Find(ChunkKey(ACoord), Result) then
    { Result set by Find }
  else
    Result := -1;
end;

function TWorld.GetOrCreateChunk(const ACoord: TChunkCoord): TChunk;
var
  Index: Integer;
  EmptyBlock: TBlock;
begin
  Index := FindChunkIndex(ACoord);
  if Index <> -1 then
    Exit(TChunk(FChunks.Objects[Index]));

  Result := TChunk.Create;
  EmptyBlock.Id := 0;
  Result.Clear(EmptyBlock);

  // Try load from storage first.
  if Assigned(FStorage) then
    if not FStorage.LoadChunk(ACoord, Result) then
    begin
      // If not loaded, generate if possible.
      if Assigned(FGenerator) then
        FGenerator.GenerateChunk(ACoord, Result);
    end;

  FChunks.AddObject(ChunkKey(ACoord), Result);

  if Assigned(FOnChunkCreated) then
    FOnChunkCreated(ACoord);
end;

constructor TWorld.Create(const AStorage: IWorldStorage; const AGenerator: IChunkGenerator);
begin
  inherited Create;
  FChunks := TStringList.Create;
  FChunks.Sorted := True;
  FStorage := AStorage;
  FGenerator := AGenerator;
end;

destructor TWorld.Destroy;
var
  i: Integer;
begin
  for i := 0 to FChunks.Count - 1 do
    if FChunks.Objects[i] <> nil then
      TChunk(FChunks.Objects[i]).Free;
  FreeAndNil(FChunks);
  inherited Destroy;
end;

function TWorld.TryGetChunk(const ACoord: TChunkCoord; out AChunk: TChunk): Boolean;
var
  Index: Integer;
begin
  Index := FindChunkIndex(ACoord);
  Result := Index <> -1;
  if Result then
    AChunk := TChunk(FChunks.Objects[Index])
  else
    AChunk := nil;
end;

function TWorld.EnsureChunk(const ACoord: TChunkCoord): TChunk;
begin
  Result := GetOrCreateChunk(ACoord);
end;

function TWorld.GetBlock(const APos: TBlockPos): TBlock;
var
  ChunkCoord: TChunkCoord;
  LocalX, LocalY, LocalZ: Integer;
  Chunk: TChunk;
begin
  BlockPosToChunkAndLocal(APos, ChunkCoord, LocalX, LocalY, LocalZ);

  if not TryGetChunk(ChunkCoord, Chunk) then
  begin
    Result.Id := 0;
    Exit;
  end;

  Result := Chunk.GetBlock(LocalX, LocalY, LocalZ);
end;

procedure TWorld.SetBlock(const APos: TBlockPos; const ABlock: TBlock);
var
  ChunkCoord: TChunkCoord;
  LocalX, LocalY, LocalZ: Integer;
  Chunk: TChunk;
begin
  BlockPosToChunkAndLocal(APos, ChunkCoord, LocalX, LocalY, LocalZ);

  Chunk := GetOrCreateChunk(ChunkCoord);
  Chunk.SetBlock(LocalX, LocalY, LocalZ, ABlock);

  // Mark chunk as changed for storage.
  if Assigned(FStorage) then
    FStorage.MarkChunkDirty(ChunkCoord);

  if Assigned(FOnChunkChanged) then
    FOnChunkChanged(ChunkCoord);
end;

procedure TWorld.Update(const ADeltaTimeSec: Single);
begin
  // Заглушка: можно переопределить в наследнике или добавить логику
  // выгрузки чанков по расстоянию, сохранения dirty-чанков и т.д.
end;

end.

