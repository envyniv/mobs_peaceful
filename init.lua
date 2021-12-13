--= Sheep for mobs redo =--
-- Copyright (c) 2015-2016 BlockMen <blockmen2015@gmail.com>
--
-- init.lua
--
-- This software is provided 'as-is', without any express or implied warranty. In no
-- event will the authors be held liable for any damages arising from the use of
-- this software.
--
-- Permission is granted to anyone to use this software for any purpose, including
-- commercial applications, and to alter it and redistribute it freely, subject to the
-- following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
-- claim that you wrote the original software. If you use this software in a
-- product, an acknowledgment in the product documentation is required.
-- 2. Altered source versions must be plainly marked as such, and must not
-- be misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.
--


mobs_peaceful = {}


local function setColor(self)
  if self and self.object then
    local ext = ".png"
    if self.gotten ~= false then
      ext = ".png^(creatures_sheep_shaved.png^[colorize:" .. self.wool_color:gsub("grey", "gray") .. ":50)"
    end
    self.object:set_properties({textures = {"creatures_sheep.png^creatures_sheep_" .. self.wool_color .. ext}})
  end
end

local function shear(self, drop_count, sound)
  if self.gotten == false then
    self.gotten = true
    local pos = self.object:getpos()
    if sound then
      core.sound_play("creatures_shears", {pos = pos, gain = 1, max_hear_distance = 10})
    end

    setColor(self)
--     minetest.add_item(pos, "wool:" .. self.wool_color)
  end
end


-- white, grey, brown, black (see wool colors as reference)
local colors = {"white", "grey", "brown", "black"}

mobs:register_mob('mobs_peaceful:sheep',{
                                         type='animal',
  hp_max=8,
  hp_min=1,
  lifetime = 450, -- 7,5 Minutes
  jump = true,
  jump_height = 1.1,
  stepheight = 1.1,
  pushable = true,
  view_range = 12,
  can_swim = true,
  can_burn = true,
  can_panic = true,
  has_falldamage = true,
  has_kockback = true,
  runaway=true,
  visual = 'mesh',
  mesh = "creatures_sheep.b3d",
  textures = {"creatures_sheep.png^creatures_sheep_white.png"},
--   gotten_texture = {}
  collisionbox = {-0.5, -0.01, -0.55, 0.5, 1.1, 0.55},
  rotation = -90.0,
  animation = {
    stand_start = 1,
    stand_end = 60,
    stand_speed = 15,
    walk_start = 81,
    walk_end= 101,
    walk_speed = 18,
    eat_start = 107,
    eat_end = 170,
    eat_speed = 12,
    eat_loop = false,
    die_start = 171,
    die_end= 191,
    die_speed = 32,
    die_loop = false,
    },
  replace_what = {'default:dirt_with_grass'},
  replace_with = {'default:dirt'},
  replace_rate = 10,
  follow = {"farming:wheat"},

  sounds = {
            damage = {name = "creatures_sheep", gain = 1.0, distance = 10},
            death = {name = "creatures_sheep", gain = 1.0, distance = 10},
--             swim = {name = "creatures_splash", gain = 1.0, distance = 10,},
            random = {name = "creatures_sheep", gain = 1.0, distance = 10}
            },


  on_replace = function(self, pos, oldnode, newnode)
    mobs:set_animation(self, eat)
    self.gotten=false
    setColor(self)
  end,
--   modes = {
--            idle = {chance = 0.5, duration = 10, update_yaw = 8},
--            walk = {chance = 0.14, duration = 4.5, moving_speed = 1.3},
--            walk_long = {chance = 0.11, duration = 8, moving_speed = 1.3, update_yaw = 5},
--            special modes
--            follow = {chance = 0, duration = 20, radius = 4, timer = 5, moving_speed = 1, items = {"farming:wheat"}},
--            eat = {	chance = 0.25,
--                     duration = 4,
--                     nodes = {
--                              "default:grass_1", "default:grass_2", "default:grass_3",
--                              "default:grass_4", "default:grass_5", "default:dirt_with_grass"
--                              }
--                     },
--            },

  drops = function(self)
  local items = {{"mobs:meat_raw"}}
  if (not self.gotten and self.wool_color) then
    return {
            {name = "wool:" .. self.wool_color, chance = 1, min = 1, max = 2},
            {name = 'mobs:meat_raw', chance = 1, min = 1, max = 2},
            }
  else
    return{{name = 'mobs:meat_raw', chance = 1, min = 1, max = 2}}
  end
  end,

--   spawning = {
--               abm_nodes = {
--                            spawn_on = {"default:dirt_with_grass"},
--                            },
--               abm_interval = 55,
--               abm_chance = 7800,
--               max_number = 1,
--               number = {min = 1, max = 3},
--               time_range = {min = 5100, max = 18300},
--               light = {min = 10, max = 15},
--               height_limit = {min = 0, max = 25},

--               spawn_egg = {
--                            description = "Sheep Spawn-Egg",
--                            texture = "creatures_egg_sheep.png",
--                            },

--   get_staticdata = function(self)
--     return {
--             gotten = not self.gotten,
--             wool_color = self.wool_color,
--             }
--     end,

  on_spawn = function(self)
    if self.gotten == nil then
    self.gotten = false
    end
    if not self.wool_color then
    self.wool_color =  colors[math.random(1, #colors)]
    end
    -- update fur
    setColor(self)
    end,

  on_grown = function(self)
    self.gotten=false
    setColor(self)
  end,

  on_rightclick = function(self, clicker)
    mobs:feed_tame(self, clicker, 5, true, false)
    local item = clicker:get_wielded_item()
    if item then
      local name = item:get_name()

    -- play eat sound?
      item:take_item()
      if name == "mobs:shears" and not self.gotten then
        shear(self, math.random(2, 3), true)
        item:add_wear(65535/100)
        minetest.add_item(self.pos, "wool:" .. self.wool_color)
      end
      if not minetest.settings:get_bool("creative_mode") then
        clicker:set_wielded_item(item)
      end
    end
    return true
    end,
--     end,

--   do_custom = function(self, dtime)
--     if self.mode == "eat" and self.eat_node then
--       self.regrow_wool = true
--     end
--     if self.last_mode == "eat" and (self.modetimer and self.modetimer == 0) and self.regrow_wool then
--       self.gotten = false
--       self.regrow_wool = nil
--       setColor(self)
--     end
--     if self.fed_cnt and self.fed_cnt > 4 then
--       self.tamed = true
--       self.fed_cnt = nil
--     end
--     end
  } )

mobs:spawn({name = 'mobs_peaceful:sheep',
            nodes = {
                     'default:dirt_with_grass'
                    },
            neighbors = 'air',
            chance = 7000,
            active_object_count = 50,
            min_height = -31000,
            max_height = 31000,
            day_toggle = true
           })

local S = minetest.get_translator('mobs_peaceful')

mobs:register_egg('mobs_peaceful:sheep', S('Sheep'), 'wool_white.png', 1)

mobs:alias_mob('mobs:sheep', 'mobs_peaceful:sheep')
