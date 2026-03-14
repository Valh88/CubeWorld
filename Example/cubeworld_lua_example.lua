-- Расширенный пример использования динамической библиотеки CubeWorld из Lua.
-- Библиотека libcubeworld.dll (Windows) или libcubeworld.so (Linux/macOS) — в каталоге Example рядом с этим скриптом.
-- На Windows: соберите проект Library (CubeWorld.lpi) и скопируйте lib\x86_64-win64\libcubeworld.dll в Example.

local here = debug.getinfo(1, "S").source
here = (here:sub(2):match("(.*/)") or "./"):gsub("^@", "")

package.preload["cubeworld"] = function()
  local libname = (os.getenv("OS") or ""):find("^Windows") and "libcubeworld.dll" or "libcubeworld.so"
  local libpath = here .. libname
  local fn, err = package.loadlib(libpath, "luaopen_cubeworld")
  if not fn then
    error("cannot load " .. libpath .. ": " .. (err or "unknown"), 2)
  end
  return fn()
end

---@type cuboworld
local cw = require "cubeworld"

print("=== CubeWorld Lua bindings ===")
print("Chunk size:", cw.CHUNK_SIZE_X, cw.CHUNK_SIZE_Y, cw.CHUNK_SIZE_Z)
print()

-- ---------------------------------------------------------------------------
-- 1. Мир и подписка на события (до любых операций с блоками/чанками)
-- ---------------------------------------------------------------------------
print("--- 1. Мир и события ---")
local world = cw.world_new(8, 1)  -- высота грунта 8, id грунта 1

-- Подписываемся сразу: OnChunkCreated/OnChunkChanged вызываются только при
-- создании чанка и при world:set_block (не при chunk:set_block).
world:set_on_chunk_created(function(cx, cy, cz)
  print(("  [event] chunk created (%d, %d, %d)"):format(cx, cy, cz))
end)
world:set_on_chunk_changed(function(cx, cy, cz)
  print(("  [event] chunk changed (%d, %d, %d)"):format(cx, cy, cz))
end)

-- Первый set_block создаёт чанк (0,0,0) -> сработают оба события
world:set_block(0, 0, 0, 5)
world:set_block(1, 0, 0, 6)
world:set_block(-1, 2, 3, 10)
print("block (0,0,0) =", world:get_block(0, 0, 0))
print("block (1,0,0) =", world:get_block(1, 0, 0))
print("block (-1,2,3) =", world:get_block(-1, 2, 3))
print()

-- ---------------------------------------------------------------------------
-- 2. Ещё раз on_chunk_changed и on_chunk_created для нового чанка
-- ---------------------------------------------------------------------------
print("--- 2. События чанков ---")
-- Меняем блок через мир -> on_chunk_changed(0,0,0)
world:set_block(0, 0, 0, 99)
-- Получаем далёкий чанк (100,100,100) -> он создаётся, on_chunk_created(100,100,100)
local ch = world:get_chunk(100, 100, 100)
-- Меняем блок в мире в этом чанке -> on_chunk_changed(100,100,100)
world:set_block(1600, 1600, 1600, 1)
-- Изменение через chunk:set_block тоже вызывает on_chunk_changed
ch:set_block(0, 0, 0, 42)
print()

-- ---------------------------------------------------------------------------
-- 3. try_get_chunk: получить чанк без создания
-- ---------------------------------------------------------------------------
print("--- 3. try_get_chunk ---")
local ok_chunk = world:try_get_chunk(0, 0, 0)
local nil_chunk = world:try_get_chunk(200, 200, 200)  -- чанк не создавали -> nil
print("try_get_chunk(0,0,0)     =>", ok_chunk and "chunk" or "nil")
print("try_get_chunk(200,200,200) =>", nil_chunk and "chunk" or "nil")
if ok_chunk then
  print("  block (0,0,0) in chunk =", ok_chunk:get_block(0, 0, 0))
end
print()

local cx, cy, cz, lx, ly, lz = cw.block_pos_to_chunk_and_local(10, 5, -3)
print(("block (10,5,-3) -> chunk (%d,%d,%d), local (%d,%d,%d)"):format(cx, cy, cz, lx, ly, lz))
print(75)
-- ---------------------------------------------------------------------------
-- 4. Чанк: clear, is_dirty, set_dirty
-- ---------------------------------------------------------------------------
print("--- 4. Чанк: clear, dirty ---")
local c = world:get_chunk(1, 0, 0)
c:set_block(5, 5, 5, 42)
print("after set_block: is_dirty =", c:is_dirty())
c:set_dirty(false)
print("after set_dirty(false): is_dirty =", c:is_dirty())
c:clear(0)  -- заполнить весь чанк воздухом (id=0)
print("after clear(0): block (5,5,5) =", c:get_block(5, 5, 5))
c:clear(7)
print("after clear(7): block (0,0,0) =", c:get_block(0, 0, 0))
print()

-- ---------------------------------------------------------------------------
-- 5. Преобразования координат
-- ---------------------------------------------------------------------------
print("--- 5. Координаты ---")
local cx, cy, cz, lx, ly, lz = cw.block_pos_to_chunk_and_local(10, 5, -3)
print(("block (10,5,-3) -> chunk (%d,%d,%d), local (%d,%d,%d)"):format(cx, cy, cz, lx, ly, lz))

local px, py, pz = cw.chunk_and_local_to_block_pos(0, 0, 0, 10, 5, 7)
print(("chunk (0,0,0) local (10,5,7) -> block (%d,%d,%d)"):format(px, py, pz))

local block_size = 1.0
local wx, wy, wz = cw.block_pos_to_world_center(0, 0, 0, block_size)
print(("block (0,0,0) center (block_size=1) -> world (%.2f, %.2f, %.2f)"):format(wx, wy, wz))

local gx, gy, gz = cw.block_pos_to_world_corner(2, 1, 0, block_size)
print(("block (2,1,0) corner -> world (%.2f, %.2f, %.2f)"):format(gx, gy, gz))

local bx, by, bz = cw.world_to_block_pos(2.3, 0.7, -1.2, block_size)
print(("world (2.3, 0.7, -1.2) -> block (%d, %d, %d)"):format(bx, by, bz))
print()

-- ---------------------------------------------------------------------------
-- 6. Игровой цикл и GC: чанк держит мир
-- ---------------------------------------------------------------------------
print("--- 6. Update и ссылки ---")
for i = 1, 3 do
  world:update(1.0 / 60.0)
end
-- Пока есть ссылка на чанк, мир не будет собран
local keep_chunk = world:get_chunk(0, 0, 0)
print("Chunk (0,0,0) held; world stays alive while chunk is referenced.")
print()

-- ---------------------------------------------------------------------------
-- 7. Второй мир (независимый)
-- ---------------------------------------------------------------------------
print("--- 7. Второй мир ---")
local world2 = cw.world_new(2, 3)  -- тонкий слой, блок 3
world2:set_block(0, 0, 0, 11)
print("world2: block (0,0,0) =", world2:get_block(0, 0, 0))

print("=== done ===")
