program CubeWorldExample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, 
  cuboworld, cw_types;

var
  World: TWorld;
  Storage: IWorldStorage;
  Generator: IChunkGenerator;
  Pos: TBlockPos;
  Block: TBlock;
  WorldCorner: TWorldVec3;
begin
  Storage := TMemoryWorldStorage.Create;
  Generator := TFlatGenerator.Create(4, 1); // ground up to Y<4, block id 1
  World := TWorld.Create(Storage, Generator);
  try
    Pos.X := 0;
    Pos.Y := 0;
    Pos.Z := 0;

    Block := World.GetBlock(Pos);
    Writeln('Initial block at (0,0,0): ', Block.Id);

    Block.Id := 2;
    World.SetBlock(Pos, Block);
    
    Block.Id := 5;
    Pos.X := 1;
    Pos.Y := 0;
    Pos.Z := 0;
    World.SetBlock(Pos, Block);
    WorldCorner := BlockPosToWorldCorner(Pos, 16);
    Writeln('World corner at (1,0,0): ', WorldCorner.X, ', ', WorldCorner.Y, ', ', WorldCorner.Z);
    Block := World.GetBlock(Pos);
    Writeln('After SetBlock, block at (0,0,0): ', Block.Id);

    Readln;
  finally
    World.Free;
  end;
end.

