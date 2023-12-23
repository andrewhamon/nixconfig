pulsemixer --change-volume +5
# Example volume button that allows press and hold, volume limited to 150%
wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+

# Example volume button that will activate even while an input inhibitor is active
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
