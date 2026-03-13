-- Пример использования динамической библиотеки CubeWorld из Lua.
-- Библиотека libcubeworld.so должна лежать в каталоге Example рядом с этим скриптом.

local here = debug.getinfo(1, "S").source
here = (here:sub(2):match("(.*/)") or "./"):gsub("^@", "")

-- Загрузчик для модуля "cubeworld": Lua ищет cubeworld.so, а у нас libcubeworld.so
package.preload["cubeworld"] = function()
  local libpath = here .. "libcubeworld.so"
  local fn, err = package.loadlib(libpath, "luaopen_cubeworld")
  if not fn then
    error("cannot load " .. libpath .. ": " .. (err or "unknown"), 2)
  end
  return fn()
end

-- Загружаем модуль CubeWorld
local cw = require "cubeworld"

print("CubeWorld Lua bindings loaded")
print("Chunk size:", cw.CHUNK_SIZE_X, cw.CHUNK_SIZE_Y, cw.CHUNK_SIZE_Z)

-- Создаём мир:
--   высота грунта = 8 блоков
--   id блока грунта = 1
local world = cw.world_new(8, 1)

-- Ставим блок в абсолютных координатах мира
world:set_block(0, 0, 0, 5)
local id = world:get_block(0, 0, 0)
print("block id at (0,0,0) =", id)

-- Работаем с чанком напрямую
local cx, cy, cz = 0, 0, 0
local chunk = world:get_chunk(cx, cy, cz)

local lx, ly, lz = 0, 0, 0
chunk:set_block(lx, ly, lz, 7)
print("chunk local block at (0,0,0) =", chunk:get_block(lx, ly, lz))
print("chunk is_dirty =", chunk:is_dirty())

-- Преобразование: блок -> чанк + локальные координаты
local cX, cY, cZ, lX, lY, lZ =
  cw.block_pos_to_chunk_and_local(10, 5, -3)
print(("block (10,5,-3) -> chunk (%d,%d,%d), local (%d,%d,%d)"):
  format(cX, cY, cZ, lX, lY, lZ))

-- Блок -> мировые координаты центра (размер блока 1.0)
local wx, wy, wz = cw.block_pos_to_world_center(0, 0, 0, 1.0)
print("world center of (0,0,0) =", wx, wy, wz)

-- Мировые координаты -> блок
local bx, by, bz = cw.world_to_block_pos(2.3, 0.7, -1.2, 1.0)
print("block from world (2.3,0.7,-1.2) =", bx, by, bz)

-- Тестовый игровой цикл
for i = 1, 5 do
  world:update(1.0 / 60.0)
end

print("done")

