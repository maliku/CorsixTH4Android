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

--! The multi-purpose panel for launching dialogs / screens and dynamic information.
class "UITopPanel" (Window)

function UITopPanel:UITopPanel(ui)
  self:Window()
  
  local app = ui.app

  self.ui = ui
  self.world = app.world
  self.on_top = true
  self.width = 320
  self.height = 48
  self:setDefaultPosition(0.5, 0)
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.money_font = app.gfx:loadFont("QData", "Font05V")
  self.date_font = app.gfx:loadFont("QData", "Font16V")
  self.white_font = app.gfx:loadFont("QData", "Font01V", 0, -2)
  
  -- State relating to fax notification messages
  self.show_animation = true
  self.factory_counter = 22
  self.factory_direction = 0
  self.message_windows = {}
  self.message_queue = {}
  
  self.default_button_sound = "selectx.wav"
  self.countdown = 0
  
  --self:addPanel( 1,   0, 0):makeButton(6, 6, 35, 36, 2, self.dialogBankManager, nil, self.dialogBankStats):setTooltip(_S.tooltip.toolbar.bank_button)
  --self:addPanel( 3,  40, 0) -- Background for balance, rep and date
  self:addPanel( 1, 11, 0):makeButton(6, 6, 35, 36, 2, function() app:quit() end):setTooltip(_S.menu_file.quit)
  self:addPanel( 1, 48, 0):makeButton(1, 6, 35, 36, 2, self.dialogFurnishCorridor):setTooltip(_S.tooltip.toolbar.objects)
  self:addPanel( 1, 85, 0):makeButton(1, 6, 35, 36, 2, self.editRoom):setSound():setTooltip(_S.tooltip.toolbar.edit) -- Remove default sound for this button
  self:addPanel(1, 122, 0):makeButton(1, 6, 35, 36, 2, self.dialogHireStaff):setTooltip(_S.tooltip.toolbar.hire)
  -- The dynamic info bar
  --[[self:addPanel(12, 364, 0)
  for x = 377, 630, 10 do
    self:addPanel(13, x, 0)
  end
  self:addPanel(14, 627, 0)
  
  ui:addKeyHandler("R", self, self.dialogResearch)      -- R for research
  ui:addKeyHandler("A", self, self.toggleAdviser)      -- A for adviser
  ui:addKeyHandler("M", self, self.openFirstMessage)    -- M for message
  ui:addKeyHandler("T", self, self.dialogTownMap)       -- T for town map
  ui:addKeyHandler("I", self, self.toggleInformation)  -- I for Information when you first build
  ui:addKeyHandler("C", self, self.dialogDrugCasebook)  -- C for casebook
  ]]
end

function UITopPanel:draw(canvas, x, y)
  if not self.visible then
    return
  end
  Window.draw(self, canvas, x, y)

  --[[x, y = x + self.x, y + self.y
  self.money_font:draw(canvas, ("%7i"):format(self.ui.hospital.balance), x + 44, y + 9)
  local month, day = self.world:getDate()
  self.date_font:draw(canvas, _S.date_format.daymonth:format(day, month), x + 140, y + 20, 60, 0)
  
  -- Draw possible information in the dynamic info bar
  if not self.additional_buttons[1].visible then
    self:drawDynamicInfo(canvas, x + 364, y)
  end
  
  if self.show_animation then
    if self.factory_counter >= 1 then
        self.panel_sprites:draw(canvas, 40, x + 177, y + 1)
    end
  
    if self.factory_counter > 1 and self.factory_counter <= 22 then
      for dx = 0, self.factory_counter do
        self.panel_sprites:draw(canvas, 41, x + 179 + dx, y + 1)
      end
    end
  
    if self.factory_counter == 22 then
      self.panel_sprites:draw(canvas, 42, x + 201, y + 1)
    end
  end
  ]]
  
  --self:drawReputationMeter(canvas, x + 55, y + 35)
end

function UITopPanel:setPosition(x, y)
  -- Lock to bottom of screen
  return Window.setPosition(self, x, 0)
end

function UITopPanel:hitTest(x, y, x_offset)
  return x >= (x_offset and x_offset or 0) and y >= 0 and x < self.width and y < self.height
end

function UITopPanel:hitTestBar(x, y)
    return y < self.height and self.x <= x and x < self.x + self.width
end

function UITopPanel:onMouseMove(x, y)
  local padding = 6
  local visible = y < self.height + padding
  local newactive = false
  if (self:hitTest(x, y, padding)) then
      newactive = true
  end

  newactive = newactive or (visible and not self.visible)
  if visible then
    self:appear()
  else
    self:disappear()
  end
  return newactive
end

function UITopPanel:appear()
  self.disappear_counter = nil
  self.visible = true
end

function UITopPanel:disappear()
  if not self.disappear_counter then
    self.disappear_counter = 100
  end
end

function UITopPanel:onTick()
  if self.disappear_counter then
    if self.disappear_counter == 0 then
      self.visible = false
      self.disappear_counter = nil
    else
      self.disappear_counter = self.disappear_counter - 1
    end
  end
  Window.onTick(self)
end
