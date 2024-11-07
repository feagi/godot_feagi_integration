Metric reporting allows you to tell FEAGI how well it is performing, so it can better train itself. You do this in the form of sending Metrics (stats) after the end of a session.

## Usage

### Timing
You can access the metric reporter object with `FEAGI.metric_reporting`
you should first await the `FEAGI.ready_for_metric_posting` signal before making any calls to it, however, since before that point the reference to the object will be null.

### Sending initial Configuration
Before sending any stats, first you must define the parameter names you will use for your training, and scaling floats (all positive numbers) to represent how important they are. By running method `configure_endgame_metric_settings()` without any arguments, it loads the default dictionary of the following:

    {
			"time_alive": 0.5,
			"max_level_reached": 0.5,
			"score_trying_to_max": 1.0,
    }

Meaning these are the keys you must include with every stat push, and these are how it is scaled. You can however, pass in your own string key - float value dictionary into the function to define your own metric definitions. You must have at least 1 definition, and all scaling factors must be positive.

### Sending statistics
Every time you send stats, you must first construct a dictionary with the same key names as defined in the configuration, with the value being a (positive or 0 value'd) float. Sending the dictionary can be done using the `send_endgame_metrics` method with the dictionary as the first parameter. You should send this at the end of every "session" to help FEAGI give context on how well it performed.
In addition, you can send an optional second string-string paired dictionary of meta data. This dictionary will not be involved in training at all, but can be used to give you, the human reviewer, further context when reviewing training data.

