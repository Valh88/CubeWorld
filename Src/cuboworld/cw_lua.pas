unit cw_lua;

{$mode objfpc}{$H+}

interface

uses
  lua54, lauxlib54,
  cw_types, cw_chunk, cw_events, cw_storage_intf, cw_storage_mem,
  cw_generator_intf, cw_generator_flat, cw_world, cuboworld;

function luaopen_cubeworld(L: Plua_State): Integer; cdecl; export;

implementation

const
  LUA_NOREF_CW = -2;

type
  PWorldUserData = ^TWorldUserData;
  TWorldUserData = record
    World: TWorld;
    L: Plua_State;
    OnChunkCreatedRef: Integer;
    OnChunkChangedRef: Integer;
    EventBridge: TObject;
  end;

  { Bridge: forwards TWorld chunk events to Lua callbacks. }
  TWorldEventBridge = class
  private
    FUd: PWorldUserData;
  public
    constructor Create(AUd: PWorldUserData);
    destructor Destroy; override;
    procedure ChunkCreated(const ACoord: TChunkCoord);
    procedure ChunkChanged(const ACoord: TChunkCoord);
  end;

  PChunkUserData = ^TChunkUserData;
  TChunkUserData = record
    Chunk: TChunk;
  end;

const
  WORLD_MT_NAME: PAnsiChar = 'CubeWorld.World';
  CHUNK_MT_NAME: PAnsiChar = 'CubeWorld.Chunk';

function CheckWorld(L: Plua_State; Index: Integer): TWorld;
var
  Ud: PWorldUserData;
begin
  Ud := PWorldUserData(luaL_checkudata(L, Index, WORLD_MT_NAME));
  if (Ud = nil) or (Ud^.World = nil) then
    luaL_error(L, 'invalid CubeWorld.World');
  Result := Ud^.World;
end;

function CheckChunk(L: Plua_State; Index: Integer): TChunk;
var
  Ud: PChunkUserData;
begin
  Ud := PChunkUserData(luaL_checkudata(L, Index, CHUNK_MT_NAME));
  if (Ud = nil) or (Ud^.Chunk = nil) then
    luaL_error(L, 'invalid CubeWorld.Chunk');
  Result := Ud^.Chunk;
end;

{ TWorldEventBridge }

constructor TWorldEventBridge.Create(AUd: PWorldUserData);
begin
  inherited Create;
  FUd := AUd;
end;

destructor TWorldEventBridge.Destroy;
begin
  if (FUd <> nil) and (FUd^.L <> nil) then
  begin
    if FUd^.OnChunkCreatedRef <> LUA_NOREF_CW then
    begin
      luaL_unref(FUd^.L, LUA_REGISTRYINDEX, FUd^.OnChunkCreatedRef);
      FUd^.OnChunkCreatedRef := LUA_NOREF_CW;
    end;
    if FUd^.OnChunkChangedRef <> LUA_NOREF_CW then
    begin
      luaL_unref(FUd^.L, LUA_REGISTRYINDEX, FUd^.OnChunkChangedRef);
      FUd^.OnChunkChangedRef := LUA_NOREF_CW;
    end;
  end;
  inherited Destroy;
end;

procedure TWorldEventBridge.ChunkCreated(const ACoord: TChunkCoord);
begin
  if (FUd = nil) or (FUd^.L = nil) or (FUd^.OnChunkCreatedRef = LUA_NOREF_CW) then
    Exit;
  lua_rawgeti(FUd^.L, LUA_REGISTRYINDEX, FUd^.OnChunkCreatedRef);
  lua_pushinteger(FUd^.L, ACoord.X);
  lua_pushinteger(FUd^.L, ACoord.Y);
  lua_pushinteger(FUd^.L, ACoord.Z);
  if lua_pcall(FUd^.L, 3, 0, 0) <> LUA_OK then
    lua_pop(FUd^.L, 1);
end;

procedure TWorldEventBridge.ChunkChanged(const ACoord: TChunkCoord);
begin
  if (FUd = nil) or (FUd^.L = nil) or (FUd^.OnChunkChangedRef = LUA_NOREF_CW) then
    Exit;
  lua_rawgeti(FUd^.L, LUA_REGISTRYINDEX, FUd^.OnChunkChangedRef);
  lua_pushinteger(FUd^.L, ACoord.X);
  lua_pushinteger(FUd^.L, ACoord.Y);
  lua_pushinteger(FUd^.L, ACoord.Z);
  if lua_pcall(FUd^.L, 3, 0, 0) <> LUA_OK then
    lua_pop(FUd^.L, 1);
end;

{ World bindings }

function l_world_new(L: Plua_State): Integer; cdecl;
var
  GroundHeight: lua_Integer;
  GroundBlockId: lua_Integer;
  Storage: IWorldStorage;
  Generator: IChunkGenerator;
  Ud: PWorldUserData;
begin
  if lua_gettop(L) >= 1 then
    GroundHeight := luaL_checkinteger(L, 1)
  else
    GroundHeight := 1;

  if lua_gettop(L) >= 2 then
    GroundBlockId := luaL_checkinteger(L, 2)
  else
    GroundBlockId := 1;

  Storage := TMemoryWorldStorage.Create;
  Generator := TFlatGenerator.Create(GroundHeight, TBlockId(GroundBlockId));

  Ud := PWorldUserData(lua_newuserdata(L, SizeOf(TWorldUserData)));
  Ud^.World := TWorld.Create(Storage, Generator);
  Ud^.L := L;
  Ud^.OnChunkCreatedRef := LUA_NOREF_CW;
  Ud^.OnChunkChangedRef := LUA_NOREF_CW;
  Ud^.EventBridge := TWorldEventBridge.Create(Ud);
  Ud^.World.OnChunkCreated := @TWorldEventBridge(Ud^.EventBridge).ChunkCreated;
  Ud^.World.OnChunkChanged := @TWorldEventBridge(Ud^.EventBridge).ChunkChanged;

  luaL_setmetatable(L, WORLD_MT_NAME);

  Result := 1;
end;

function l_world_get_block(L: Plua_State): Integer; cdecl;
var
  W: TWorld;
  Pos: TBlockPos;
  B: TBlock;
begin
  W := CheckWorld(L, 1);
  Pos.X := luaL_checkinteger(L, 2);
  Pos.Y := luaL_checkinteger(L, 3);
  Pos.Z := luaL_checkinteger(L, 4);

  B := W.GetBlock(Pos);
  lua_pushinteger(L, B.Id);
  Result := 1;
end;

function l_world_set_block(L: Plua_State): Integer; cdecl;
var
  W: TWorld;
  Pos: TBlockPos;
  B: TBlock;
begin
  W := CheckWorld(L, 1);
  Pos.X := luaL_checkinteger(L, 2);
  Pos.Y := luaL_checkinteger(L, 3);
  Pos.Z := luaL_checkinteger(L, 4);
  B.Id := TBlockId(luaL_checkinteger(L, 5));

  W.SetBlock(Pos, B);
  Result := 0;
end;

function l_world_update(L: Plua_State): Integer; cdecl;
var
  W: TWorld;
  Dt: lua_Number;
begin
  W := CheckWorld(L, 1);
  Dt := luaL_checknumber(L, 2);
  W.Update(Dt);
  Result := 0;
end;

function l_world_get_chunk(L: Plua_State): Integer; cdecl;
var
  W: TWorld;
  Coord: TChunkCoord;
  Chunk: TChunk;
  Ud: PChunkUserData;
begin
  W := CheckWorld(L, 1);
  Coord.X := luaL_checkinteger(L, 2);
  Coord.Y := luaL_checkinteger(L, 3);
  Coord.Z := luaL_checkinteger(L, 4);

  if not W.TryGetChunk(Coord, Chunk) then
  begin
    Chunk := W.EnsureChunk(Coord);
  end;

  Ud := PChunkUserData(lua_newuserdatauv(L, SizeOf(TChunkUserData), 1));
  Ud^.Chunk := Chunk;
  luaL_setmetatable(L, CHUNK_MT_NAME);
  { Keep world alive while chunk is referenced (avoids use-after-free when world is GC'd). }
  lua_pushvalue(L, 1);
  lua_setiuservalue(L, -2, 1);

  Result := 1;
end;

function l_world_try_get_chunk(L: Plua_State): Integer; cdecl;
var
  W: TWorld;
  Coord: TChunkCoord;
  Chunk: TChunk;
  Ud: PChunkUserData;
begin
  W := CheckWorld(L, 1);
  Coord.X := luaL_checkinteger(L, 2);
  Coord.Y := luaL_checkinteger(L, 3);
  Coord.Z := luaL_checkinteger(L, 4);

  if not W.TryGetChunk(Coord, Chunk) then
  begin
    lua_pushnil(L);
    Result := 1;
    Exit;
  end;

  Ud := PChunkUserData(lua_newuserdatauv(L, SizeOf(TChunkUserData), 1));
  Ud^.Chunk := Chunk;
  luaL_setmetatable(L, CHUNK_MT_NAME);
  lua_pushvalue(L, 1);
  lua_setiuservalue(L, -2, 1);
  Result := 1;
end;

function l_world_set_on_chunk_created(L: Plua_State): Integer; cdecl;
var
  Ud: PWorldUserData;
  Ref: Integer;
begin
  Ud := PWorldUserData(luaL_checkudata(L, 1, WORLD_MT_NAME));
  luaL_checktype(L, 2, LUA_TFUNCTION);
  if (Ud = nil) or (Ud^.World = nil) then
    luaL_error(L, 'invalid CubeWorld.World');
  if Ud^.OnChunkCreatedRef <> LUA_NOREF_CW then
    luaL_unref(Ud^.L, LUA_REGISTRYINDEX, Ud^.OnChunkCreatedRef);
  lua_pushvalue(L, 2);
  Ref := luaL_ref(L, LUA_REGISTRYINDEX);
  Ud^.OnChunkCreatedRef := Ref;
  Result := 0;
end;

function l_world_set_on_chunk_changed(L: Plua_State): Integer; cdecl;
var
  Ud: PWorldUserData;
  Ref: Integer;
begin
  Ud := PWorldUserData(luaL_checkudata(L, 1, WORLD_MT_NAME));
  luaL_checktype(L, 2, LUA_TFUNCTION);
  if (Ud = nil) or (Ud^.World = nil) then
    luaL_error(L, 'invalid CubeWorld.World');
  if Ud^.OnChunkChangedRef <> LUA_NOREF_CW then
    luaL_unref(Ud^.L, LUA_REGISTRYINDEX, Ud^.OnChunkChangedRef);
  lua_pushvalue(L, 2);
  Ref := luaL_ref(L, LUA_REGISTRYINDEX);
  Ud^.OnChunkChangedRef := Ref;
  Result := 0;
end;

function l_world_gc(L: Plua_State): Integer; cdecl;
var
  Ud: PWorldUserData;
begin
  Ud := PWorldUserData(luaL_checkudata(L, 1, WORLD_MT_NAME));
  if (Ud <> nil) then
  begin
    if Ud^.EventBridge <> nil then
    begin
      Ud^.World.OnChunkCreated := nil;
      Ud^.World.OnChunkChanged := nil;
      Ud^.EventBridge.Free;
      Ud^.EventBridge := nil;
    end;
    if Ud^.World <> nil then
    begin
      Ud^.World.Free;
      Ud^.World := nil;
    end;
  end;
  Result := 0;
end;

{ Chunk bindings }

function l_chunk_get_block(L: Plua_State): Integer; cdecl;
var
  C: TChunk;
  X, Y, Z: lua_Integer;
  B: TBlock;
begin
  C := CheckChunk(L, 1);
  X := luaL_checkinteger(L, 2);
  Y := luaL_checkinteger(L, 3);
  Z := luaL_checkinteger(L, 4);

  B := C.GetBlock(X, Y, Z);
  lua_pushinteger(L, B.Id);
  Result := 1;
end;

function l_chunk_set_block(L: Plua_State): Integer; cdecl;
var
  C: TChunk;
  X, Y, Z: lua_Integer;
  B: TBlock;
begin
  C := CheckChunk(L, 1);
  X := luaL_checkinteger(L, 2);
  Y := luaL_checkinteger(L, 3);
  Z := luaL_checkinteger(L, 4);
  B.Id := TBlockId(luaL_checkinteger(L, 5));

  C.SetBlock(X, Y, Z, B);
  Result := 0;
end;

function l_chunk_clear(L: Plua_State): Integer; cdecl;
var
  C: TChunk;
  B: TBlock;
begin
  C := CheckChunk(L, 1);
  B.Id := TBlockId(luaL_checkinteger(L, 2));
  C.Clear(B);
  Result := 0;
end;

function l_chunk_is_dirty(L: Plua_State): Integer; cdecl;
var
  C: TChunk;
begin
  C := CheckChunk(L, 1);
  lua_pushboolean(L, C.Dirty);
  Result := 1;
end;

function l_chunk_set_dirty(L: Plua_State): Integer; cdecl;
var
  C: TChunk;
begin
  C := CheckChunk(L, 1);
  C.Dirty := lua_toboolean(L, 2);
  Result := 0;
end;

function l_chunk_gc(L: Plua_State): Integer; cdecl;
begin
  Result := 0;
end;

{ Coordinate helpers }

function l_block_pos_to_chunk_and_local(L: Plua_State): Integer; cdecl;
var
  Pos: TBlockPos;
  Chunk: TChunkCoord;
  LX, LY, LZ: Integer;
begin
  Pos.X := luaL_checkinteger(L, 1);
  Pos.Y := luaL_checkinteger(L, 2);
  Pos.Z := luaL_checkinteger(L, 3);

  BlockPosToChunkAndLocal(Pos, Chunk, LX, LY, LZ);

  lua_pushinteger(L, Chunk.X);
  lua_pushinteger(L, Chunk.Y);
  lua_pushinteger(L, Chunk.Z);
  lua_pushinteger(L, LX);
  lua_pushinteger(L, LY);
  lua_pushinteger(L, LZ);
  Result := 6;
end;

function l_chunk_and_local_to_block_pos(L: Plua_State): Integer; cdecl;
var
  Chunk: TChunkCoord;
  LX, LY, LZ: Integer;
  Pos: TBlockPos;
begin
  Chunk.X := luaL_checkinteger(L, 1);
  Chunk.Y := luaL_checkinteger(L, 2);
  Chunk.Z := luaL_checkinteger(L, 3);
  LX := luaL_checkinteger(L, 4);
  LY := luaL_checkinteger(L, 5);
  LZ := luaL_checkinteger(L, 6);

  Pos := ChunkAndLocalToBlockPos(Chunk, LX, LY, LZ);

  lua_pushinteger(L, Pos.X);
  lua_pushinteger(L, Pos.Y);
  lua_pushinteger(L, Pos.Z);
  Result := 3;
end;

function l_block_pos_to_world_corner(L: Plua_State): Integer; cdecl;
var
  Pos: TBlockPos;
  Size: lua_Number;
  W: TWorldVec3;
begin
  Pos.X := luaL_checkinteger(L, 1);
  Pos.Y := luaL_checkinteger(L, 2);
  Pos.Z := luaL_checkinteger(L, 3);
  Size := luaL_checknumber(L, 4);

  W := BlockPosToWorldCorner(Pos, Size);

  lua_pushnumber(L, W.X);
  lua_pushnumber(L, W.Y);
  lua_pushnumber(L, W.Z);
  Result := 3;
end;

function l_block_pos_to_world_center(L: Plua_State): Integer; cdecl;
var
  Pos: TBlockPos;
  Size: lua_Number;
  W: TWorldVec3;
begin
  Pos.X := luaL_checkinteger(L, 1);
  Pos.Y := luaL_checkinteger(L, 2);
  Pos.Z := luaL_checkinteger(L, 3);
  Size := luaL_checknumber(L, 4);

  W := BlockPosToWorldCenter(Pos, Size);

  lua_pushnumber(L, W.X);
  lua_pushnumber(L, W.Y);
  lua_pushnumber(L, W.Z);
  Result := 3;
end;

function l_world_to_block_pos(L: Plua_State): Integer; cdecl;
var
  Wv: TWorldVec3;
  Size: lua_Number;
  Pos: TBlockPos;
begin
  Wv.X := luaL_checknumber(L, 1);
  Wv.Y := luaL_checknumber(L, 2);
  Wv.Z := luaL_checknumber(L, 3);
  Size := luaL_checknumber(L, 4);

  Pos := WorldToBlockPos(Wv, Size);

  lua_pushinteger(L, Pos.X);
  lua_pushinteger(L, Pos.Y);
  lua_pushinteger(L, Pos.Z);
  Result := 3;
end;

{ Registration helpers }

procedure RegisterWorldMetatable(L: Plua_State);
begin
  if luaL_newmetatable(L, WORLD_MT_NAME) then
  begin
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, '__index');

    lua_pushcfunction(L, @l_world_get_block);
    lua_setfield(L, -2, 'get_block');

    lua_pushcfunction(L, @l_world_set_block);
    lua_setfield(L, -2, 'set_block');

    lua_pushcfunction(L, @l_world_update);
    lua_setfield(L, -2, 'update');

    lua_pushcfunction(L, @l_world_get_chunk);
    lua_setfield(L, -2, 'get_chunk');

    lua_pushcfunction(L, @l_world_try_get_chunk);
    lua_setfield(L, -2, 'try_get_chunk');

    lua_pushcfunction(L, @l_world_set_on_chunk_created);
    lua_setfield(L, -2, 'set_on_chunk_created');

    lua_pushcfunction(L, @l_world_set_on_chunk_changed);
    lua_setfield(L, -2, 'set_on_chunk_changed');

    lua_pushcfunction(L, @l_world_gc);
    lua_setfield(L, -2, '__gc');
  end;
  lua_pop(L, 1);
end;

procedure RegisterChunkMetatable(L: Plua_State);
begin
  if luaL_newmetatable(L, CHUNK_MT_NAME) then
  begin
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, '__index');

    lua_pushcfunction(L, @l_chunk_get_block);
    lua_setfield(L, -2, 'get_block');

    lua_pushcfunction(L, @l_chunk_set_block);
    lua_setfield(L, -2, 'set_block');

    lua_pushcfunction(L, @l_chunk_clear);
    lua_setfield(L, -2, 'clear');

    lua_pushcfunction(L, @l_chunk_is_dirty);
    lua_setfield(L, -2, 'is_dirty');

    lua_pushcfunction(L, @l_chunk_set_dirty);
    lua_setfield(L, -2, 'set_dirty');

    lua_pushcfunction(L, @l_chunk_gc);
    lua_setfield(L, -2, '__gc');
  end;
  lua_pop(L, 1);
end;

function luaopen_cubeworld(L: Plua_State): Integer; cdecl;
begin
  RegisterWorldMetatable(L);
  RegisterChunkMetatable(L);

  lua_newtable(L);

  lua_pushinteger(L, CChunkSizeX);
  lua_setfield(L, -2, 'CHUNK_SIZE_X');
  lua_pushinteger(L, CChunkSizeY);
  lua_setfield(L, -2, 'CHUNK_SIZE_Y');
  lua_pushinteger(L, CChunkSizeZ);
  lua_setfield(L, -2, 'CHUNK_SIZE_Z');

  lua_pushcfunction(L, @l_world_new);
  lua_setfield(L, -2, 'world_new');

  lua_pushcfunction(L, @l_block_pos_to_chunk_and_local);
  lua_setfield(L, -2, 'block_pos_to_chunk_and_local');

  lua_pushcfunction(L, @l_chunk_and_local_to_block_pos);
  lua_setfield(L, -2, 'chunk_and_local_to_block_pos');

  lua_pushcfunction(L, @l_block_pos_to_world_corner);
  lua_setfield(L, -2, 'block_pos_to_world_corner');

  lua_pushcfunction(L, @l_block_pos_to_world_center);
  lua_setfield(L, -2, 'block_pos_to_world_center');

  lua_pushcfunction(L, @l_world_to_block_pos);
  lua_setfield(L, -2, 'world_to_block_pos');

  Result := 1;
end;

end.

