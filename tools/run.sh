#!/usr/bin/env bash
# Lance le jeu (scène principale), ou une scène donnée : tools/run.sh res://scenes/rooms/room_prototype.tscn
source "$(dirname "$0")/_godot.sh"
exec "$GODOT" --path . "$@"
