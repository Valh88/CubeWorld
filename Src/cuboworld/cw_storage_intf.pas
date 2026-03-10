unit cw_storage_intf;

{$mode objfpc}{$H+}

interface

uses
  cw_types, cw_chunk;

type
  { IWorldStorage
    Abstract storage backend for chunks (disk, memory, DB, etc.). }
  IWorldStorage = interface
    ['{7B7F9DF5-7C9E-4F46-9F06-5F0E8F2F0C10}']
    function LoadChunk(const ACoord: TChunkCoord; AChunk: TChunk): Boolean;
    procedure SaveChunk(const ACoord: TChunkCoord; AChunk: TChunk);
    procedure MarkChunkDirty(const ACoord: TChunkCoord);
  end;

implementation

end.

