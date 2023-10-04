extends Node

const void_value = []
var callback: JavaScriptObject
@onready var expression: = Expression.new()

func _ready() -> void:
	if OS.get_name() != "Web":
		on_parse_snippet(["print(\"not web\")"])
		return
	
	var window: = JavaScriptBridge.get_interface("window")
	callback = JavaScriptBridge.create_callback(on_parse_snippet)
	window.parseGDScriptSnippet = callback


func on_parse_snippet(args: Array) -> void:
	if args == null or args.size() == 0:
		return
	
	var CustomNode = GDScript.new()
	CustomNode.source_code = """
extends Node

func _init() -> void:
	pass
	
func _ready() -> void:
%s
""" % args[0].indent("\t")
	CustomNode.reload()
	
	var node = CustomNode.new()
	add_child(node)
	node.queue_free()


func parse_expression(expr: String) -> void:
	expression.parse(expr, [])
	if expression.get_error_text() != "":
		printerr(expression.get_error_text())


func execute_expression() -> void:
	expression.execute([], self, true, false)
	if expression.has_execute_failed():
		printerr(expression.get_error_text())

