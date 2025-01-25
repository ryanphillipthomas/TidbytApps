load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")  # Ensure the time module is available in your environment

DEFAULT_WHO = "World"

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    # Extract time components as strings
    hour_24 = int(now.format("%H"))  # Hour in 24-hour format
    minute = int(now.format("%M"))  # Minutes
    seconds = int(now.format("%S"))  # Seconds

    # Determine AM/PM and convert to 12-hour format
    period = "AM" if hour_24 < 12 else "PM"
    hour_12 = hour_24 if hour_24 <= 12 else hour_24 - 12
    hour_12 = 12 if hour_12 == 0 else hour_12  # Handle midnight and noon

    # Flashing colon logic
    colon = ":" if seconds % 2 == 0 else " "

    formatted_time = "%02d%s%02d %s" % (hour_12, colon, minute, period)

    message = "Hello, %s! The time is %s." % (config.str("who", DEFAULT_WHO), formatted_time)

    if config.bool("small"):
        msg = render.Text(message, font = "CG-pixel-3x5-mono")
    else:
        msg = render.Text(message)

    return render.Root(
        child = msg,
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "who",
                name = "Who?",
                desc = "Who to say hello to.",
                icon = "user",
            ),
            schema.Toggle(
                id = "small",
                name = "Display small text",
                desc = "A toggle to display smaller text.",
                icon = "compress",
                default = False,
            ),
        ],
    )
