extends Node
## AUTOLOADED singleton that runs with the game. Reads established config and communicates to FEAGI

signal sensory_setup_event()
signal motor_setup_event()

# Read / verify configs
# initial loading and setup of variables, check if enabled
# emit signals when tree is ready, have devices register
# initialize debugger views
# confirm network connection to feagi
# start tick system
