# FEAGI Godot Integrator -> Bringing Human Neuron based AI to your Godot games easily!

### FEAGI and this FEAGI Godot Integrator are still early and WIP, feel free to reach out if you have questions!

This guide serves as an example for adding the plugin to your godot game, using the [Robot 2D platformer example from the Godot Example Repo](https://github.com/godotengine/godot-demo-projects/tree/master/2d/physics_platformer)!

## Steps

- Have your project open in Godot
![1](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Basics/01_initial_project.png?raw=true)

- From the asset lib, install the plugin
![2](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Basics/02_download_plugin.PNG)

- Enable the plugin in the project settings, and reload the editor

- Open the Configurator window
![3](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Basics/03_open_configurator.png)

- Set up the agent settings such that we capture 30 Hz, and set your FEAGI connection settings here (defaults to localhost)
![4](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Basics/04_agent_settings.PNG)

- The Sensory settings allow FEAGI to "See" your game. In this example, lets set up a camera device, and have it automatically configure itself to record your whole screen
![5](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Basics/05_sensory.PNG)

- The Motor settings allow FEAGI to control your game. In this example, we will make use of the motion_control output, and have it autoconfigure to act as input events. Be sure to match the direction you want with the appropriate input action!
![6](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Basics/06_motor.PNG)

- Save the configuration at the bottom, and run them game!

- Congrats, FEAGI now can interact with your game!
