---@meta
--- Типы для LSP (LuaLS/EmmyLua): подсказки для модуля cubeworld (libcubeworld.so).
--- Подключение: в скрипте добавьте после require строку с типом, например:
---   local cw = require "cubeworld"
---   ---@type cuboworld
---   cw
--- Или объявите переменную с типом: ---@type cuboworld
---   local cw = require "cubeworld"

---@class cuboworld.World
---Обёртка мира (TWorld). Создаётся через cuboworld.world_new().
local World = {}

---Получить id блока в мировых координатах.
---@param self cuboworld.World
---@param x integer
---@param y integer
---@param z integer
---@return integer block_id
function World:get_block(x, y, z) end

---Установить блок в мировых координатах.
---@param self cuboworld.World
---@param x integer
---@param y integer
---@param z integer
---@param block_id integer
function World:set_block(x, y, z, block_id) end

---Обновление мира (вызывать из игрового цикла).
---@param self cuboworld.World
---@param dt number время в секундах
function World:update(dt) end

---Получить или создать чанк по координатам чанка. Всегда возвращает чанк.
---@param self cuboworld.World
---@param cx integer координата чанка X
---@param cy integer координата чанка Y
---@param cz integer координата чанка Z
---@return cuboworld.Chunk
function World:get_chunk(cx, cy, cz) end

---Получить чанк без создания. Возвращает nil, если чанк ещё не создан.
---@param self cuboworld.World
---@param cx integer
---@param cy integer
---@param cz integer
---@return cuboworld.Chunk|nil
function World:try_get_chunk(cx, cy, cz) end

---Установить callback при создании чанка. Функция вызывается с (cx, cy, cz).
---@param self cuboworld.World
---@param callback fun(cx: integer, cy: integer, cz: integer)
function World:set_on_chunk_created(callback) end

---Установить callback при изменении чанка. Функция вызывается с (cx, cy, cz).
---@param self cuboworld.World
---@param callback fun(cx: integer, cy: integer, cz: integer)
function World:set_on_chunk_changed(callback) end

---@class cuboworld.Chunk
---Обёртка чанка. Получается через world:get_chunk() или world:try_get_chunk().
local Chunk = {}

---Получить id блока в локальных координатах чанка (0..15).
---@param self cuboworld.Chunk
---@param lx integer 0..CHUNK_SIZE_X-1
---@param ly integer 0..CHUNK_SIZE_Y-1
---@param lz integer 0..CHUNK_SIZE_Z-1
---@return integer block_id
function Chunk:get_block(lx, ly, lz) end

---Установить блок в локальных координатах чанка.
---@param self cuboworld.Chunk
---@param lx integer
---@param ly integer
---@param lz integer
---@param block_id integer
function Chunk:set_block(lx, ly, lz, block_id) end

---Заполнить весь чанк блоком с заданным id.
---@param self cuboworld.Chunk
---@param block_id integer
function Chunk:clear(block_id) end

---Флаг «грязный» (нужно сохранение).
---@param self cuboworld.Chunk
---@return boolean
function Chunk:is_dirty() end

---Установить флаг dirty.
---@param self cuboworld.Chunk
---@param dirty boolean
function Chunk:set_dirty(dirty) end

---Модуль cuboworld (результат require "cubeworld").
---@class cuboworld
---@field CHUNK_SIZE_X integer размер чанка по X (16)
---@field CHUNK_SIZE_Y integer размер чанка по Y (16)
---@field CHUNK_SIZE_Z integer размер чанка по Z (16)
---@field world_new fun(groundHeight?: integer, groundBlockId?: integer): cuboworld.World создать мир (по умолчанию height=1, blockId=1)
---@field block_pos_to_chunk_and_local fun(x: integer, y: integer, z: integer): integer, integer, integer, integer, integer, integer блок -> (cx, cy, cz, lx, ly, lz)
---@field chunk_and_local_to_block_pos fun(cx: integer, cy: integer, cz: integer, lx: integer, ly: integer, lz: integer): integer, integer, integer (cx,cy,cz,lx,ly,lz) -> (x, y, z)
---@field block_pos_to_world_corner fun(x: integer, y: integer, z: integer, blockSize: number): number, number, number угол блока в мировых координатах
---@field block_pos_to_world_center fun(x: integer, y: integer, z: integer, blockSize: number): number, number, number центр блока в мировых координатах
---@field world_to_block_pos fun(wx: number, wy: number, wz: number, blockSize: number): integer, integer, integer мировые координаты -> блок
local cuboworld = {}

return nil
