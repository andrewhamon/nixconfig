{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "volctl";
  runtimeInputs = [ ];
  text = ''
    pactl=${pkgs.pulseaudio}/bin/pactl
    wpctl=${pkgs.wireplumber}/bin/wpctl
    
    if ! $pactl play-sample ${./audio-volume-change.wav} &> /dev/null; then
      $pactl upload-sample ${./audio-volume-change.wav} ${./audio-volume-change.wav}
      $pactl play-sample ${./audio-volume-change.wav}
    fi

    if [ -z "$1" ]; then
      echo "Usage: volctl [up|down|mute|unmute|togglemute]"
      exit 1
    fi

    if [ "$1" = "up" ]; then
      $wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+
    elif [ "$1" = "microup" ]; then
      $wpctl set-volume -l 1.5 @DEFAULT_SINK@ 1%+
    elif [ "$1" = "down" ]; then
      $wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%-
    elif [ "$1" = "microdown" ]; then
      $wpctl set-volume -l 1.5 @DEFAULT_SINK@ 1%-
    elif [ "$1" = "mute" ]; then
      $wpctl set-mute @DEFAULT_SINK@ 1
    elif [ "$1" = "unmute" ]; then
      $wpctl set-mute @DEFAULT_SINK@ 0
    elif [ "$1" = "togglemute" ]; then
      $wpctl set-mute @DEFAULT_SINK@ toggle
    else
      echo "Usage: volctl [up|down|mute|unmute|togglemute]"
      exit 1
    fi
  '';
}
