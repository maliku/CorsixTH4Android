--[[ Copyright (c) 2009 Peter "Corsix" Cawley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

local TH = require "TH"

class "UIBuildRoom" (Window)

local factor = 1.5
local cat_label_y = {}
local hover_edges = {}

function UIBuildRoom:UIBuildRoom(ui)
  self:Window()
  
  local app = ui.app
  factor = app:getGlobalScaleFactor()
  cat_label_y = {21 * factor, 53 * factor, 84 * factor, 116 * factor}
  hover_edges = {156 * factor, 287 * factor, 31 * factor, 226 * factor}
  self.ui = ui
  self.modal_class = "main"
  self.esc_closes = true
  self.width = 297 * factor
  self.height = 294 * factor
  self:setDefaultPosition(0.5, 0.5)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req09V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.blue_font = app.gfx:loadFont("QData", "Font02V")
  self.category_index = 0
  self.list_hover_index = 0
  self.preview_anim = false
  self.default_button_sound = "selectx.wav"
  
  local function cat(n)
    return --[[persistable:build_room_set_category]] function(self)
      return self:setCategory(n)
    end
  end
  local room_n = 1
  local function rm()
    local n = room_n
    room_n = room_n + 1
    return --[[persistable:build_room_build_room]] function(self)
      return self:buildRoom(n)
    end
  end
  
  self:addPanel(210,   0,   0):setScaledNOffset():makeButton(9, 9, 129, 32, 211, cat(1)):setTooltip(_S.tooltip.build_room_window.room_classes.diagnosis)
  self:addPanel(212,   0,  41):setScaledNOffset():makeButton(9, 0, 129, 31, 213, cat(2)):setTooltip(_S.tooltip.build_room_window.room_classes.treatment)
  -- Clinics should really be at y=73, but TH skips a pixel here
  -- so that the left and right columns are the same height
  self:addPanel(214,   0,  72):setScaledNOffset():makeButton(9, 0, 129, 32, 215, cat(3)):setTooltip(_S.tooltip.build_room_window.room_classes.clinic)
  self:addPanel(216,   0, 104):setScaledNOffset():makeButton(9, 0, 129, 32, 217, cat(4)):setTooltip(_S.tooltip.build_room_window.room_classes.facilities)
  self:addPanel(218,   0, 146):setScaledNOffset() -- Grid top
  for y = 179, 249, 10 do
    self:addPanel(219,   0,   y):setScaledNOffset() -- Grid body
  end
  self:addPanel(220,   0, 259):setScaledNOffset() -- Grid bottom
  self:addPanel(221, 146,   0):setScaledNOffset() -- List top
  for y = 34, 205, 19 do
    self:addPanel(222, 146,   y):setScaledNOffset():makeButton(12, 0, 126, 19, 223, rm()) -- List body
      .enabled = false
  end
  
  -- The close button has no sprite for when pressed, so it has to be custom drawn
  local build_room_dialog_close = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  self:addPanel(224, 146, 224):setScaledNOffset():makeButton(8, 34, 134, 27, 224, self.close):setTooltip(_S.tooltip.build_room_window.close)
  .panel_for_sprite.custom_draw = --[[persistable:build_room_draw_close_button]] function(panel, canvas, x, y)
    x = x + panel.x
    y = y + panel.y
    panel.window.panel_sprites:draw(canvas, panel.sprite_index, x, y, panel:getScaledFlag())
    local btn = panel.window.active_button
    if btn and btn.panel_for_sprite == panel and btn.active then
      build_room_dialog_close:draw(canvas, 1, x + 8 * factor, y + 34 * factor, panel:getScaledFlag())
    end
  end
  
  self.list_title = _S.build_room_window.pick_department
  self.cost_box = _S.build_room_window.cost .. "0"
  self.list = {}
  self.category_titles = {
    _S.room_classes.diagnosis,
    _S.room_classes.treatment,
    _S.room_classes.clinics,
    _S.room_classes.facilities
  }
  self.category_rooms = {
  }
  for i, category in ipairs{"diagnosis", "treatment", "clinics", "facilities"} do
    local rooms = {}
    self.category_rooms[i] = rooms
    for _, room in ipairs(app.world.available_rooms) do
      -- NB: Unimplemented rooms are hidden unless in debug mode
      if (app.config.debug or room.class) and room.categories[category]
      and ui.hospital.discovered_rooms[room] then
        rooms[#rooms + 1] = room
      end
    end
    table.sort(rooms, function(r1, r2) return r1.categories[category] < r2.categories[category] end)
  end
  
  self:makeTooltip(_S.tooltip.build_room_window.cost, 160, 228, 282, 242)
end

function UIBuildRoom:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  self.white_font:draw(canvas, self.list_title, x + 163 * factor, y + 18 * factor)
  for i = 1, 4 do
    (i == self.category_index and self.blue_font or self.white_font)
      :draw(canvas, self.category_titles[i], x + 19 * factor, y + cat_label_y[i])
  end
  
  for i, room in ipairs(self.list) do
    (i == self.list_hover_index and self.blue_font or self.white_font)
      :draw(canvas, room.name, x + 163 * factor, y + (21 + i * 19) * factor)
  end
  
  self.white_font:draw(canvas, self.cost_box, x + 163 * factor, y + 232 * factor)
  
  if self.preview_anim then
    self.preview_anim:draw(canvas, x + 70 * factor, y + 200 * factor)
  end
end

function UIBuildRoom:setCategory(index)
  if index == 1 then
    self.ui:tutorialStep(3, 2, 3)
  else
    self.ui:tutorialStep(3, 3, 2)
  end
  self.category_index = index
  self.list_title = _S.build_room_window.pick_room_type
  self.list = self.category_rooms[index]
  
  local last = #self.list + 5
  for i = 5, 14 do
    self.buttons[i].enabled = i < last
    if i < last then
      self.buttons[i]:setTooltip(self.list[i - 4].tooltip)
    else
      self.buttons[i]:setTooltip()
    end
  end
end

function UIBuildRoom:buildRoom(index)
  local hosp = self.ui.hospital
  if index == 1 then self.ui:tutorialStep(3, 3, 4) end
  if hosp.balance >= hosp.research.research_progress[self.list[index]].build_cost then
    -- Close any full screen window currently open.
    local fullscreen = self.ui:getWindow(UIFullscreen)
    if fullscreen then
      fullscreen:close()
    end
    local edit_dlg = UIEditRoom(self.ui, self.list[index])
    self.ui:addWindow(edit_dlg)
  else
    -- give visual warning that player doesn't have enough $ to build
    self.ui.adviser:say(_A.warnings.money_very_low_take_loan, false, true)
    self.ui:playSound("Wrong2.wav")
  end
end

function UIBuildRoom:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)
  
  local hover_idx = 0
  if hover_edges[1] <= x and x < hover_edges[2] and hover_edges[3] <= y and y < hover_edges[4] then
    for i = 5, 14 do
      local btn = self.buttons[i]
      if btn.enabled and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
        hover_idx = i - 4
        break
      end
    end
  end
  
  if hover_idx ~= self.list_hover_index then
    self.ui:playSound "HLightP2.wav"
    if hover_idx == 0 then
      self.cost_box = _S.build_room_window.cost .. "0"
      self.preview_anim = false
    else
      local cost = self.ui.hospital.research.research_progress[self.list[hover_idx]].build_cost
      self.cost_box = _S.build_room_window.cost .. cost
      self.preview_anim = TH.animation()
      self.preview_anim:setAnimation(self.ui.app.anims, self.list[hover_idx].build_preview_animation)
    end
    self.list_hover_index = hover_idx
    repaint = true
  end
  
  return repaint
end

function UIBuildRoom:close()
  self.ui:tutorialStep(3, {2, 3}, 1)
  return Window.close(self)
end
