unit cw_generator_intf;

{$mode objfpc}{$H+}

interface

uses
  cw_types, cw_chunk;

type
  { IChunkGenerator
    Generates chunk contents procedurally. }
  IChunkGenerator = interface
    ['{8E7B6E7E-4C0C-4A2B-84E8-0A4C4B1B4E11}']
    procedure GenerateChunk(const ACoord: TChunkCoord; AChunk: TChunk);
  end;

implementation

end.

