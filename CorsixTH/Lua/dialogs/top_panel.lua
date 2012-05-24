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
  self.width = 417
  self.height = 48
  self:setDefaultPosition(0.5, 0)
  self.panel_sprites = app.gfx:loadSpriteTable("Bitmap", "top_panel", true)
  
  -- State relating to fax notification messages
  self.show_animation = true
  self.factory_counter = 22
  self.factory_direction = 0
  self.message_windows = {}
  self.message_queue = {}
  
  self.default_button_sound = "selectx.wav"
  self.countdown = 0
  
  local function playMusic()
      if not app.audio.background_music then
          if not app.audio:playRandomBackgroundTrack() then -- play
              self.ui:addWindow(UIConfirmDialog(self.ui, _S.confirmation.need_music_data))
          end
      else
          app.audio:pauseBackgroundTrack() -- pause or unpause
      end
  end

  local function playAudio()
      local toggle = not app.config.play_sounds
      app.audio:playSoundEffects(toggle)
      app.config.play_announcements = toggle
  end

  local speed_names = {
      "Pause",
      "Slowest",
      "Slower",
      "Normal",
      "Max speed",
      "And then some more",
  }

  local function speedUp()
      local current_speed = app.world:getCurrentSpeed()
      if current_speed == "And then some more" then
          return
      end
      for i = 1, #speed_names do
          if current_speed == speed_names[i] then
              app.world:setSpeed(speed_names[i + 1])
          end
      end
  end

  local function slowDown()
      local current_speed = app.world:getCurrentSpeed()
      if current_speed == "Pause" then
          return
      end
      for i = 1, #speed_names do
          if current_speed == speed_names[i] then
              app.world:setSpeed(speed_names[i - 1])
          end
      end
  end

  local function volumeUp()
      local volume = 0
      if app.config.music_volume < 1.0 then
          volume = app.config.music_volume + 0.1
          if volume > 1.0 then volume = 1.0 end
          app.audio:setBackgroundVolume(volume)
      end
      if app.config.sound_volume < 1.0 then
          volume = app.config.sound_volume + 0.1
          if volume > 1.0 then volume = 1.0 end
          app.audio:setSoundVolume(volume)
      end
      if app.config.announcement_volume < 1.0 then
          volume = app.config.announcement_volume + 0.1
          if volume > 1.0 then volume = 1.0 end
          app.audio:setAnnouncementVolume(volume)
      end
  end

  local function volumeDown()
      local volume = 0
      if app.config.music_volume > 0 then
          volume = app.config.music_volume - 0.1
          if volume < 0 then volume = 0 end
          app.audio:setBackgroundVolume(volume)
      end
      if app.config.sound_volume > 0 then
          volume = app.config.sound_volume - 0.1
          if volume < 0 then volume = 0 end
          app.audio:setSoundVolume(volume)
      end
      if app.config.announcement_volume > 0 then
          volume = app.config.announcement_volume - 0.1
          if volume < 0 then volume = 0 end
          app.audio:setAnnouncementVolume(volume)
      end
  end

  self:addPanel( 1, 0, 0):makeButton(1, 6, 35, 36, 2, function() self.ui:addWindow(UISaveGame(self.ui)) end):setTooltip(_S.menu_file.save)
  self:addPanel( 3, 42, 0):makeButton(1, 6, 35, 36, 4, function() self.ui:addWindow(UILoadGame(self.ui, "game")) end):setTooltip(_S.menu_file.load)

  self:addPanel( 5, 79, 0):makeButton(1, 6, 35, 36, 6, playMusic):setTooltip(_S.menu_options.music)
  self:addPanel( 7, 116, 0):makeButton(1, 6, 35, 36, 8, playAudio):setTooltip(_S.menu_options.sound)

  self:addPanel( 9, 153, 0):makeButton(1, 6, 35, 36, 10, volumeDown):setTooltip(_S.menu_options.sound_vol)
  self:addPanel(11, 190, 0):makeButton(1, 6, 35, 36, 12, volumeUp):setTooltip(_S.menu_options.sound_vol)

  self:addPanel(13, 227, 0):makeButton(1, 6, 35, 36, 14, slowDown):setTooltip(_S.menu_options_game_speed.slower)
  self:addPanel(15, 264, 0):makeButton(1, 6, 35, 36, 16, speedUp):setSound():setTooltip(_S.menu_options_game_speed.max_speed)

  self:addPanel(17, 301, 0):makeButton(1, 6, 35, 36, 18, function() self.ui:showBriefing() end):setTooltip(_S.menu_charts.briefing)
  self:addPanel(19, 338, 0):makeButton(1, 6, 35, 36, 20, function() app:restart() end):setTooltip(_S.menu_file.restart)
  self:addPanel(21, 375, 0):makeButton(1, 6, 35, 36, 22, function() app:quit() end):setTooltip(_S.menu_file.quit)
end

function UITopPanel:draw(canvas, x, y)
  if not self.visible then
    return
  end
  Window.draw(self, canvas, x, y)
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
    self.disappear_counter = 50
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
