extends Node

var amplitude1 := 0.5
var amplitude2 := 0.3
var frequency1 := 0.5
var frequency2 := 0.8
var speed := 1.0

func get_height(x: float, z: float) -> float:
    var t := Time.get_ticks_msec() / 1000.0
    var wave1 := sin(x * frequency1 + t * speed) * amplitude1
    var wave2 := sin(z * frequency2 + t * speed * 1.3) * amplitude2
    var wave3 := sin(x * 1.5 + z * 0.8 + t * speed * 2.0) * 0.15
    var wave4 := sin(x * 0.6 - z * 1.2 + t * speed * 1.7) * 0.1
    return wave1 + wave2 + wave3 + wave4
