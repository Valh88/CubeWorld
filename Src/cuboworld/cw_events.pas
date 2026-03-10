unit cw_events;

{$mode objfpc}{$H+}

interface

uses
  cw_types;

type
  // Basic events on chunks. Coord is the chunk coordinate.
  TChunkEvent = procedure(const ACoord: TChunkCoord) of object;

implementation

end.

