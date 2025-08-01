-------------
-- FRAMEWORK CLASS
-------------
local RSGCore = exports["rsg-core"]:GetCoreObject()
local Inventory = exports["rsg-inventory"]

jo.file.load("framework-bridge.rsg.FrameworkClass")
jo.framework.inv = Inventory

-------------
-- VARIABLES
-------------

-------------
-- INVENTORY
-------------

function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  local isAdded = RSGCore.Functions.AddItem(item, nil)
  if isAdded then
    return eprint(item .. " < item does not exist in the core configuration")
  end
  RSGCore.Functions.CreateUseableItem(item, function(source, data)
    callback(source, { metadata = data.info })
    if closeAfterUsed then
      TriggerClientEvent("rsg-inventory:client:closeInv", source)
    end
  end)
end

function jo.framework:createInventory(id, name, invConfig)
  local config = {
    label = name,
    maxweight = invConfig.maxWeight and (invConfig.maxWeight * 1000), --convert kg to g
    slots = invConfig.maxSlots
  }

  Inventory:CreateInventory(id, config)
end

function jo.framework:openInventory(source, id)
  Inventory:OpenInventory(source, id)
end

function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  Inventory:CreateInventory(invId)
  return Inventory:AddItem(invId, item, quantity, false, metadata)
end

function jo.framework:getItemsFromInventory(invId)
  local inventory = Inventory:GetInventory(invId) or { items = {} }
  local items = {}
  for _, item in pairs(inventory.items) do
    table.insert(items, {
      metadata = item.info,
      amount = item.amount,
      item = item.name
    })
  end
  return items
end

function jo.framework:removeInventory(invId)
  MySQL.update("DELETE FROM inventories WHERE identifier = ?", { invId })
  return Inventory.DeleteInventory(invId)
end
