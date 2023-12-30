local SupplyManager = {}
-- TODO
-- stack management algorithm
-- remove from game GUID

local global_vars = Global.getVar("_G")

local city_row = {
  {0.10, 2.00, -2.00},
  {0.33, 2.00, -2.00},
  {0.56, 2.00, -2.00},
  {0.79, 2.00, -2.00},
  {1.02, 2.00, -2.00}
}

local all_supplies = {

  -- Player Agents
  ["White Agent"]   = {bag = global_vars["player_pieces_GUIDs"]["White"]["agents"]},
  ["Blue Agent"]    = {bag = global_vars["player_pieces_GUIDs"]["Teal"]["agents"]},
  ["Yellow Agent"]  = {bag = global_vars["player_pieces_GUIDs"]["Yellow"]["agents"]},
  ["Red Agent"]     = {bag = global_vars["player_pieces_GUIDs"]["Red"]["agents"]},

  -- Player Fresh Ships
  ["White Ship (Fresh)"]    = {bag = global_vars["player_pieces_GUIDs"]["White"]["ships"]},
  ["Blue Ship (Fresh)"]     = {bag = global_vars["player_pieces_GUIDs"]["Teal"]["ships"]},
  ["Yellow Ship (Fresh)"]   = {bag = global_vars["player_pieces_GUIDs"]["Yellow"]["ships"]},
  ["Red Ship (Fresh)"]      = {bag = global_vars["player_pieces_GUIDs"]["Red"]["ships"]},

  -- Player Damaged Ships
  ["White Ship (Damaged)"]    = {bag = global_vars["player_pieces_GUIDs"]["White"]["ships"], state = 1},
  ["Blue Ship (Damaged)"]     = {bag = global_vars["player_pieces_GUIDs"]["Teal"]["ships"], state = 1},
  ["Yellow Ship (Damaged)"]   = {bag = global_vars["player_pieces_GUIDs"]["Yellow"]["ships"], state = 1},
  ["Red Ship (Damaged)"]      = {bag = global_vars["player_pieces_GUIDs"]["Red"]["ships"], state = 1},

  -- Player Damaged Ships
  ["White Starport"]    = {bag = global_vars["player_pieces_GUIDs"]["White"]["starports"], face_up = true},
  ["Blue Starport"]     = {bag = global_vars["player_pieces_GUIDs"]["Teal"]["starports"], face_up = true},
  ["Yellow Starport"]   = {bag = global_vars["player_pieces_GUIDs"]["Yellow"]["starports"], face_up = true},
  ["Red Starport"]      = {bag = global_vars["player_pieces_GUIDs"]["Red"]["starports"], face_up = true},

  -- Player Cities
  ["White City"] =  {
    origin = global_vars["player_pieces_GUIDs"]["White"]["player_board"],
    face_up = true,
    set = global_vars["player_pieces_GUIDs"]["White"]["cities"],
    pos = city_row
  },
  ["Blue City"] =   {
    origin = global_vars["player_pieces_GUIDs"]["Teal"]["player_board"],
    face_up = true,
    set = global_vars["player_pieces_GUIDs"]["Teal"]["cities"],
    pos = city_row
  },
  ["Yellow City"] = {
    origin = global_vars["player_pieces_GUIDs"]["Yellow"]["player_board"],
    face_up = true,
    set = global_vars["player_pieces_GUIDs"]["Yellow"]["cities"],
    pos = city_row
  },
  ["Red City"] =    {
    origin = global_vars["player_pieces_GUIDs"]["Red"]["player_board"],
    face_up = true,
    set = global_vars["player_pieces_GUIDs"]["Red"]["cities"],
    pos = city_row
  },

  -- Resources
  ["Psionic"]   = {pos = {0,2,0}, origin = global_vars["resources_markers_GUID"]["psionics"]},
  ["Relic"]     = {pos = {0,2,0}, origin = global_vars["resources_markers_GUID"]["relics"]},
  ["Weapon"]    = {pos = {0,2,0}, origin = global_vars["resources_markers_GUID"]["weapons"]},
  ["Fuel"]      = {pos = {0,2,0}, origin = global_vars["resources_markers_GUID"]["fuel"]},
  ["Material"]  = {pos = {0,2,0}, origin = global_vars["resources_markers_GUID"]["materials"]},



  -- Campaing Components
  --["Blight"]                    = {bag = global_vars[""]},
  ["Imperial Ship (Damaged)"]   = {bag = global_vars["imperial_ships_GUID"], state = 1},
  ["Imperial Ship (Fresh)"]     = {bag = global_vars["imperial_ships_GUID"]},
  --["Free City"]                 = {bag = global_vars[""]},
  --["Free Starport"]             = {bag = global_vars[""]},

  -- Cards
  ["Action Card"] = {
    deck  = global_vars["action_deck_GUID"],
    pos   = {-12.26, 3.10, 6.94},
    rot   = {0.00, 90.00, 180.00} 
  },

  -- Miscallaneous
  [""] = {ignore = true},
  ["Zero Marker"] = {
    pos = {-12.24, 0.99, -7.23},
    rot = {0.00, 180.00, 0.00}
  }
}

-- Main return
function SupplyManager.returnObject(object,is_bottom_deck)

  local deck_pos = is_bottom_deck and -1 or 1
  local supply = all_supplies[object.getName()]

  if not supply then
    print("Unable to return '"..object.getName().."' to a supply.")
    return
  end

  -- Check for additional changes that should be made when returning to supply
  if supply.state then
    object.setState(supply.state)
  elseif supply.face_up and object.is_face_down then
    object.flip()
  elseif supply.face_down and not object.is_face_down then
    object.flip()
  end

  -- Complete return based on type --

  -- Ignore return
  if supply.ignore then
    return

  -- Return to bag
  elseif supply.bag then
    getObjectFromGUID(supply.bag).putObject(object)

  -- Return to deck
  -- If deck doesn't exist then put card where deck was and make it the deck
  elseif supply.deck then
    local deck = getObjectFromGUID(supply.deck)
    if deck then
      supply.deck = deck.putObject(object).getGUID()
      supply.pos = deck.getPosition() + deck_pos*Vector(0,2,0)
      supply.rot = deck.getRotation()
      object.setPosition(supply.pos)
      object.setRotation(supply.rot)
    else
      supply.deck = object.getGUID()
      object.setPosition(supply.pos)
      object.setRotation(supply.rot)
    end

  -- Return a set of objects to a set of positions
  elseif supply.set then
    for ct, obj_GUID in ipairs(supply.set) do
      if object.getGUID() == obj_GUID then
        local pos = supply.pos[ct]
        pos = supply.origin and getObjectFromGUID(supply.origin).positionToWorld(pos)
        object.setPositionSmooth(pos,false,true)
      end
    end

  -- Return an object to a position
  elseif supply.pos then
    local pos = supply.pos
    pos = supply.origin and getObjectFromGUID(supply.origin).positionToWorld(pos)
    object.setPositionSmooth(pos,false,true)
  end

end

function SupplyManager.returnZone(zone) 
  for _,i in pairs(zone.getObjects()) do 
    SupplyManager.returnObject(i) 
  end
end

function SupplyManager.addMenuToObject(object)
  --log("Adding return context menu option to "..object.getName())
  if object.getName() ~= "" and all_supplies[object.getName()] then
    object.addContextMenuItem("Return to supply", SupplyManager.returnFromMenu)
    if object.type == "Card" then
      object.addContextMenuItem("Card to deck bottom", SupplyManager.buryFromMenu)
    end
  end
end

function SupplyManager.returnFromMenu(player_color, position, object)
  for _, i in pairs(Player.getPlayers()) do
    if i.color == player_color then
      for _, k in pairs(i.getSelectedObjects()) do
        SupplyManager.returnObject(k)
      end
    end
  end
end

function SupplyManager.buryFromMenu(player_color, position, object)
  for _, i in pairs(Player.getPlayers()) do
    if i.color == player_color then
      for _, k in pairs(i.getSelectedObjects()) do
        if k.type == "Card" then
          SupplyManager.returnObject(k,true)
        end
      end
    end
  end
end

return SupplyManager