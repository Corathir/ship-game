extends Node

## Autoload logging utility. Automatically captures caller context
## (scene, node path, script, line) from the call stack.
##
## Usage:
##   DebugLogger.info("Ship buoyancy applied")
##   DebugLogger.warn("Probe below water", self)
##   DebugLogger.error("Material is null", self)
##
## If a `node` argument is provided, its scene tree path is included.
## Otherwise, the call stack is inspected for the caller's script and line.

enum Level { DEBUG, INFO, WARN, ERROR }

## Minimum level to output. Set to DEBUG during development, INFO for release.
var min_level: Level = Level.DEBUG

## If true, includes the full call stack (expensive — only for crash-level errors).
var verbose_stack: bool = false

## Max stack frames to inspect when resolving caller (performance).
const _MAX_FRAMES := 4


func _ready() -> void:
	# In exported builds, suppress DEBUG by default
	if not OS.is_debug_build():
		min_level = Level.INFO


# ============================================================================
# PUBLIC API
# ============================================================================

func debug(message: String, node: Node = null) -> void:
	_log(Level.DEBUG, message, node)


func info(message: String, node: Node = null) -> void:
	_log(Level.INFO, message, node)


func warn(message: String, node: Node = null) -> void:
	_log(Level.WARN, message, node)


func error(message: String, node: Node = null) -> void:
	_log(Level.ERROR, message, node)


# ============================================================================
# INTERNALS
# ============================================================================

func _log(level: Level, message: String, node: Node) -> void:
	if level < min_level:
		return

	var caller := _resolve_caller(node)
	var prefix := _level_prefix(level)
	var formatted := "%s [%s] %s" % [prefix, caller, message]

	match level:
		Level.DEBUG, Level.INFO:
			print(formatted)
		Level.WARN:
			push_warning(formatted)
		Level.ERROR:
			push_error(formatted)

	if verbose_stack and level >= Level.ERROR:
		_print_stack()


func _resolve_caller(node: Node) -> String:
	var parts: PackedStringArray = []

	# Node path (scene context) — either provided or discovered
	if node:
		parts.append(_node_context(node))
	else:
		var discovered := _discover_node_from_stack()
		if discovered:
			parts.append(discovered)

	# Script + line from call stack
	var stack_info := _stack_caller_info()
	if stack_info:
		parts.append(stack_info)

	return " | ".join(parts) if parts.size() > 0 else "<unknown>"


func _node_context(node: Node) -> String:
	var scene_name: String = ""
	if node.get_tree() and node.get_tree().current_scene:
		scene_name = node.get_tree().current_scene.name
	var node_path: String = str(node.get_path())
	return "%s/%s" % [scene_name, node_path] if scene_name else node_path


func _discover_node_from_stack() -> String:
	# Walk the stack to find a frame whose script is attached to a node
	var stack := get_stack()
	if stack.size() < 3:
		return ""

	# Frame 0 = _discover_node_from_stack, 1 = _resolve_caller,
	# 2 = _log, 3 = debug/info/warn/error, 4 = actual caller
	var caller_frame := mini(4, stack.size() - 1)
	var caller_script: String = stack[caller_frame].get("source", "")

	if caller_script.is_empty():
		return ""

	# Search scene tree for a node with this script
	if not get_tree():
		return ""

	for found_node in get_tree().get_nodes_in_group("_scripts"):
		if found_node.get_script() and found_node.get_script().resource_path == caller_script:
			return _node_context(found_node)

	return ""


func _stack_caller_info() -> String:
	var stack := get_stack()
	if stack.size() < 3:
		return ""

	# Navigate to the actual caller frame
	# 0=_stack_caller_info, 1=_resolve_caller, 2=_log, 3=public_api, 4=caller
	var idx := mini(4, stack.size() - 1)
	var frame: Dictionary = stack[idx]

	var script: String = frame.get("source", "")
	var line: int = frame.get("line", 0)
	var func_name: String = frame.get("function", "")

	# Shorten script path: "res://ocean/wave_calculator.gd" → "ocean/wave_calculator.gd"
	if script.begins_with("res://"):
		script = script.substr(6)

	return "%s::%s():%d" % [script, func_name, line]


func _level_prefix(level: Level) -> String:
	match level:
		Level.DEBUG: return "DBG"
		Level.INFO:  return "INF"
		Level.WARN:  return "WRN"
		Level.ERROR: return "ERR"
		_: return "???"


func _print_stack() -> void:
	var stack := get_stack()
	for i in range(stack.size()):
		var frame: Dictionary = stack[i]
		print("  [%d] %s::%s():%d" % [
			i,
			frame.get("source", "?"),
			frame.get("function", "?"),
			frame.get("line", 0),
		])
