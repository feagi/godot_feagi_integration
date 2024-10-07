### FEAGI and this FEAGI Godot Integrator are still early and WIP, feel free to reach out if you have questions!

**NOTE: This guide assumes you read the previous tutorial to get your project setup with FEAGI**

In this guide, we will set up a device, in this case an accelerometer sensor, that does not have an automated setup, so we can learn how to add custom devices to the integration.

Our goal is to send the x,y velocity of our character to FEAGI (keep in mind the in actual use-case, velocity should not be used interchangeably with acceleration, but we are taking this shortcut here as we want to focus on the usage of the plugin, not to teach a physics lesson).

## Steps

Lets add the accelerometer device, and lets set a good min max range for our data (this depends on your use case)
![1](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Custom_Device/1_create_accelerometer.PNG?raw=true)

Now, lets go into the node of our character, as we need access to the velocity information. Thankfully, we extend off of RigidBody2D for our character script (player.gd), so we can simply access the `linear_velocity` parameter.

The plugin uses callables to read or write to the game, and in the case of an accelerometer sensor, we need to create a method that returns a vector3 (the type for each device  is explained in the relevant FEAGI_Device_X script for that device).

Let us create a function in the player.gd to get this velocity
![2](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Custom_Device/2_create_function.PNG?raw=true)

Now, we need to tell our plugin to use this function for our accelerometer device. Thankfully, we have a way to simplify this process with RegistrationAgents. The easiest way to create one is to add an exported one to your node of choice, and edit it from the Godot Editor
![3](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Custom_Device/3_define_agent_in_script.PNG?raw=true)

Now from the godot editor, click on the node with your script, define the Registration Agent, and select the device type (in this case, Accelerometer), and type in the same name you used on the device you intend to simulate (in this case, we called our accelerometer 'accelerometer 0'
![4](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Custom_Device/4_define_agent.PNG?raw=true)

Now finally, we need to actually call this agent to commence registration. The easiest way usually is to just call it in the _ready function. The only required parameter is the function that will be used (that you defined earlier).
![5](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Custom_Device/5_call_for_registration.PNG?raw=true)
Keep in mind this function is a coroutine, so you may optionally await for it to register itself with the FEAGI plugin. This is necessary since it may take a moment for the plugin to initialize!

And you are complete! Feel free to run the game, and check out the FEAGI debug tab to ensure data is being captured as expected!
![6](https://github.com/feagi/godot_feagi_integration/blob/main/docs/Tutorials/Custom_Device/6_complete.PNG?raw=true)
