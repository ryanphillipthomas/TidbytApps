load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("time.star", "time")

def main(config):
    title = "%s" % config.str("title", "")
    source = "%s" % config.str("source", "")
    artist = "%s" % config.str("artist", "")

    base_image_url = config.str("image", "")  # URL or file path to the PNG image

    # Add cache-busting query parameter using the current Unix timestamp
    timestamp = str(time.now().unix)  # Use time.now().unix as a property, not a function
    image_url = base_image_url + "?ts=" + timestamp

    # Fetch the image from the cache-busted URL
    img = http.get(image_url).body()

    return render.Root(
        child=render.Row(
            main_align="center",  # Align items to the start of the row
            cross_align="center",  # Center alignment vertically
            expanded=True,
            children=[
                render.Image(
                    src=img,
                    width=23,
                    height=23,
                ),
                render.Box(width=2, height=1),
                render.Column(
                    expanded=True,
                    main_align="center",
                    cross_align="start",
                    children=[
                    render.Marquee(
                         align = "left",
                         width=40,
                         child=render.Text(content=source, color="#A9A9A9"),
                         ),
                    render.Marquee(
                         align = "left",
                         width=40,
                         child=render.Text(content=title, color="#FFFFFF"),
                         ),
                    render.Marquee(
                         align = "left",
                         width=40,
                         child=render.Text(content=artist, color="#E0E0E0"),
                         ),
                    ],
                ),
            ],
        ),
    )
    
def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "artist",
                name = "Artist?",
                desc = "Artist of Media",
                icon = "user",
            ),
            schema.Text(
                id = "title",
                name = "Title?",
                desc = "Title of Media",
                icon = "user",
            ),
            schema.Text(
                id = "source",
                name = "Source?",
                desc = "Cloffice or Studio",
                icon = "user",
            ),
            schema.Text(
                id = "image",
                name = "Image",
                desc = "Homeassistant Auth Image URL",
                icon = "image",
            ),
        ],
    )
