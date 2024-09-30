# FEAGI Godot Integrator -> Bringing Human Neuron based AI to your Godot games easily!

### FEAGI and this FEAGI Godot Integrator are still early and WIP, feel free to reach out if you have questions!

This plugin for godot allows easy integration with FEAGI to your Godot game, allowing any FEAGI agent to see / sense aspects in your game, and then send outputs to respond. Have FEAGI play as the player, or integrate tighter to allow FEAGI agents to control NPCs and other entities!

If you wish to learn more about FEAGI itself, please check out its github [here](https://github.com/feagi/feagi).

Note you will need access to FEAGI either online via our cloud hosted NeuroRobotics Studio (NRS), or a self hosted instance of FEAGI. More details [here](https://alpha.neurorobotics.studio) 

## Installation

### Method A: Godot Asset Library
The easiest way to get the latest stable version of the plugin is via the asset store, and can be found [here](https://godotengine.org/asset-library/asset/2947). You can also find it within Godot itself by simple searching for "FEAGI" on the Asset Library page.


### Method B: Manual
If you wish to download the plugin manually (or wish to test a non-stable build), simply download the addons folder from this repository and merge it into your Godot project! (Be sure to clear previous versions of the addon first!)

## Usage

To enable the plugin, please go to your project settings and ensure that the FEAGI Integration plugin is enabled!
You may see some import errors if you imported the files quickly. Reloading the project or waiting a moment can be enough to fix the issue

## Setup

Open the FEAGI configuration Panel in the Project tab -> Tools -> Open FEAGI Configurator. Here you will see several tabs:
- FEAGI: For configuring the connection details to your FEAGI instance, which defaults to localhost. 
- Sensory: For configuring all the sensors within your game (lets FEAGI "see" your game)
- Motor: For configuring all the motors within your game (lets FEAGI interact with your game)

To see a general first time guide, see [here](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorial_Basic.md).
