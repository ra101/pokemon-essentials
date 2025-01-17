#===============================================================================
# "Better Speed Up"
# - Marin: original script
# - Phantombass: updating to 19.1
# - ra101: Adding it in Options
#-------------------------------------------------------------------------------
# - Disable by setting `$game_temp.disable_speed_up` to true
# - Remap your `Q` button on the F1 screen to change your speedup switch
# - Default is now faster than original speed
#     - Change line 34 to `@gamespeed = 0 if @gamespeed == nil`
#           for setting original speed as default
#===============================================================================


#===============================================================================
# System and Temp Variables
#===============================================================================

class Game_Temp
  attr_accessor :disable_speed_up

  def disable_speed_up
    @disable_speed_up = false if !@disable_speed_up
    return @disable_speed_up
  end
end

class PokemonSystem
  attr_accessor :gamespeed
  attr_reader :speed_scale

  def gamespeed
    # Default is Faster than original
    @gamespeed = 1 if @gamespeed == nil
    return @gamespeed
  end

  def speed_scale
    # nth frame is *not* skipped
    return [1,2,3]
  end
end

#===============================================================================
# Game Option
#===============================================================================
  MenuHandlers.add(:options_menu, :gamespeed, {
    "name"        => _INTL("Game Speed"),
    "order"       => 31,
    "type"        => EnumOption,
    "parameters"  => [_INTL("Normal"), _INTL("Fast"), _INTL("Faster")],
    "description" => _INTL("Choose the speed at which Game animate."),
    "get_proc"    => proc { next $PokemonSystem.gamespeed },
    "set_proc"    => proc { |value, _scene| $PokemonSystem.gamespeed = value }
  })

#===============================================================================
# Scripts
#===============================================================================
module Graphics
  class << Graphics
    alias fast_forward_update update
    $frame_number = 0

    def _skip_frame_for_speed?
      return false if $game_temp.disable_speed_up
      return $frame_number % $PokemonSystem.speed_scale[$PokemonSystem.gamespeed] != 0
    end

  end

  def self.update
    $frame_number += 1
    return if _skip_frame_for_speed?
    fast_forward_update
    $frame_number = 0
  end
end

#===============================================================================
# HotKey
#===============================================================================
module Input

  def self.update
    update_KGC_ScreenCapture

    if trigger?(Input::F8)
      pbScreenCapture
    end

    if trigger?(Input::AUX1)
      $PokemonSystem.gamespeed = (
        ($PokemonSystem.gamespeed + 1) % $PokemonSystem.speed_scale.size
      )
    end
  end
end
