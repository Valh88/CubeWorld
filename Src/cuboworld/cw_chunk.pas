unit cw_chunk;

{$mode objfpc}{$H+}

interface

uses
  cw_types;

type
  { TChunk
    Stores blocks of a fixed-size chunk in memory. }
  TChunk = class
  private
    FBlocks: array[0..CChunkSizeX - 1, 0..CChunkSizeY - 1, 0..CChunkSizeZ - 1] of TBlock;
    FDirty: Boolean;
    function InBounds(const AX, AY, AZ: Integer): Boolean; inline;
  public
    procedure Clear(const ABlock: TBlock);

    function GetBlock(const AX, AY, AZ: Integer): TBlock;
    procedure SetBlock(const AX, AY, AZ: Integer; const ABlock: TBlock);

    property Dirty: Boolean read FDirty write FDirty;
  end;

implementation

{ TChunk }

function TChunk.InBounds(const AX, AY, AZ: Integer): Boolean;
begin
  Result :=
    (AX >= 0) and (AX < CChunkSizeX) and
    (AY >= 0) and (AY < CChunkSizeY) and
    (AZ >= 0) and (AZ < CChunkSizeZ);
end;

procedure TChunk.Clear(const ABlock: TBlock);
var
  X, Y, Z: Integer;
begin
  for X := 0 to CChunkSizeX - 1 do
    for Y := 0 to CChunkSizeY - 1 do
      for Z := 0 to CChunkSizeZ - 1 do
        FBlocks[X, Y, Z] := ABlock;
  FDirty := True;
end;

function TChunk.GetBlock(const AX, AY, AZ: Integer): TBlock;
begin
  if InBounds(AX, AY, AZ) then
    Result := FBlocks[AX, AY, AZ]
  else
    Result.Id := 0;
end;

procedure TChunk.SetBlock(const AX, AY, AZ: Integer; const ABlock: TBlock);
begin
  if not InBounds(AX, AY, AZ) then
    Exit;
  FBlocks[AX, AY, AZ] := ABlock;
  FDirty := True;
end;

end.

