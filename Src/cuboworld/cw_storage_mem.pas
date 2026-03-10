unit cw_storage_mem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  cw_types, cw_chunk, cw_storage_intf;

type
  { TMemoryWorldStorage
    Simple in-memory storage; mainly for examples and tests. }
  TMemoryWorldStorage = class(TInterfacedObject, IWorldStorage)
  private
    FChunks: TStringList;
    function ChunkKey(const ACoord: TChunkCoord): string;
    function FindChunkIndex(const ACoord: TChunkCoord): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function LoadChunk(const ACoord: TChunkCoord; AChunk: TChunk): Boolean;
    procedure SaveChunk(const ACoord: TChunkCoord; AChunk: TChunk);
    procedure MarkChunkDirty(const ACoord: TChunkCoord);
  end;

implementation

function TMemoryWorldStorage.ChunkKey(const ACoord: TChunkCoord): string;
begin
  Result := IntToStr(ACoord.X) + ':' + IntToStr(ACoord.Y) + ':' + IntToStr(ACoord.Z);
end;

function TMemoryWorldStorage.FindChunkIndex(const ACoord: TChunkCoord): Integer;
begin
  if FChunks.Find(ChunkKey(ACoord), Result) then
    { Result set by Find }
  else
    Result := -1;
end;

constructor TMemoryWorldStorage.Create;
begin
  inherited Create;
  FChunks := TStringList.Create;
  FChunks.Sorted := True;
end;

destructor TMemoryWorldStorage.Destroy;
var
  i: Integer;
begin
  for i := 0 to FChunks.Count - 1 do
    if FChunks.Objects[i] <> nil then
      TChunk(FChunks.Objects[i]).Free;
  FreeAndNil(FChunks);
  inherited Destroy;
end;

function TMemoryWorldStorage.LoadChunk(const ACoord: TChunkCoord; AChunk: TChunk): Boolean;
var
  Index: Integer;
  Stored: TChunk;
  X, Y, Z: Integer;
begin
  Index := FindChunkIndex(ACoord);
  Result := Index <> -1;
  if not Result then
    Exit;

  Stored := TChunk(FChunks.Objects[Index]);
  // Copy contents into the provided chunk.
  for X := 0 to CChunkSizeX - 1 do
    for Y := 0 to CChunkSizeY - 1 do
      for Z := 0 to CChunkSizeZ - 1 do
        AChunk.SetBlock(X, Y, Z, Stored.GetBlock(X, Y, Z));
end;

procedure TMemoryWorldStorage.SaveChunk(const ACoord: TChunkCoord; AChunk: TChunk);
var
  Index: Integer;
  Stored: TChunk;
  X, Y, Z: Integer;
begin
  Index := FindChunkIndex(ACoord);
  if Index = -1 then
  begin
    Stored := TChunk.Create;
    FChunks.AddObject(ChunkKey(ACoord), Stored);
  end
  else
    Stored := TChunk(FChunks.Objects[Index]);

  for X := 0 to CChunkSizeX - 1 do
    for Y := 0 to CChunkSizeY - 1 do
      for Z := 0 to CChunkSizeZ - 1 do
        Stored.SetBlock(X, Y, Z, AChunk.GetBlock(X, Y, Z));
end;

procedure TMemoryWorldStorage.MarkChunkDirty(const ACoord: TChunkCoord);
var
  Index: Integer;
  Stored: TChunk;
begin
  Index := FindChunkIndex(ACoord);
  if Index = -1 then
    Exit;
  Stored := TChunk(FChunks.Objects[Index]);
  Stored.Dirty := True;
end;

end.

