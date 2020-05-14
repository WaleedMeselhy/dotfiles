#!/bin/bash

MIXER=${MIXER:-""}

if [[ -z "$MIXER" ]]; then
    MIXER="default"
    if amixer -D pulse info >/dev/null 2>&1; then
        MIXER="pulse"
    fi
fi

function move_sinks_to_new_default() {
    DEFAULT_SINK=$1
    pacmd list-sink-inputs | grep index: | grep -o '[0-9]\+' | while read SINK; do
        pacmd move-sink-input $SINK $DEFAULT_SINK
    done
}

function set_default_playback_device_next() {
    inc=${1:-1}
    num_devices=$(pacmd list-sinks | grep -c index:)
    sink_arr=($(pacmd list-sinks | grep index: | grep -o '[0-9]\+'))
    default_sink_index=$(($(pacmd list-sinks | grep index: | grep -no '*' | grep -o '^[0-9]\+') - 1))
    default_sink_index=$((($default_sink_index + $num_devices + $inc) % $num_devices))
    default_sink=${sink_arr[$default_sink_index]}
    pacmd set-default-sink $default_sink
    move_sinks_to_new_default $default_sink
}

if [[ "$1" == "toggle_source" ]] ; then
    set_default_playback_device_next
else
    amixer -q set Master toggle
fi
