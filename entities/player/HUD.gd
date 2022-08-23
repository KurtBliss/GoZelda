extends Control

func _process(_delta):
	$RupeesLabel.text = str(PlayerData.rupees)
