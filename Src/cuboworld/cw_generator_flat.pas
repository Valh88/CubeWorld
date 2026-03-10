unit cw_generator_flat;

{$mode objfpc}{$H+}

interface

uses
  cw_types, cw_chunk, cw_generator_intf;

type
  { TFlatGenerator
    Very simple generator: flat world with a solid layer at Y=0..Height-1. }
  TFlatGenerator = class(TInterfacedObject, IChunkGenerator)
  private
    FGroundHeight: Integer;
    FGroundBlock: TBlock;
  public
    constructor Create(const AGroundHeight: Integer; const AGroundBlockId: TBlockId);

    procedure GenerateChunk(const ACoord: TChunkCoord; AChunk: TChunk);
  end;

implementation

constructor TFlatGenerator.Create(const AGroundHeight: Integer; const AGroundBlockId: TBlockId);
begin
  inherited Create;
  FGroundHeight := AGroundHeight;
  FGroundBlock.Id := AGroundBlockId;
end;

procedure TFlatGenerator.GenerateChunk(const ACoord: TChunkCoord; AChunk: TChunk);
var
  X, Y, Z: Integer;
  GlobalY: Integer;
  Air: TBlock;
begin
  Air.Id := 0;
  for X := 0 to CChunkSizeX - 1 do
    for Z := 0 to CChunkSizeZ - 1 do
      for Y := 0 to CChunkSizeY - 1 do
      begin
        GlobalY := ACoord.Y * CChunkSizeY + Y;
        if GlobalY < FGroundHeight then
          AChunk.SetBlock(X, Y, Z, FGroundBlock)
        else
          AChunk.SetBlock(X, Y, Z, Air);
      end;
end;

end.

