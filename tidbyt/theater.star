load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("time.star", "time")

def main(config):
    title = "%s" % config.str("title", "")
    base_image_url = config.str("image", "")  # URL or file path to the PNG image

    # Add cache-busting query parameter using the current Unix timestamp
    timestamp = str(time.now().unix)  # Use time.now().unix as a property, not a function
    image_url = base_image_url + "?ts=" + timestamp

    # Fetch the image from the cache-busted URL
    img = http.get(image_url).body()

    return render.Root(
        delay = 1000,
        child = render.Box(
            child = render.Animation(
                children = [
                    render.Row(
                        expanded = True,  # Use as much horizontal space as possible
                        main_align = "space_evenly",  # Controls horizontal alignment
                        cross_align = "center",  # Controls vertical alignment
                        children = [
                            render.Image(src=img, width=27, height=27),  # Pass Base64-encoded image
                            render.Box(width=1,height=1),
                            render.WrappedText(title),
                        ],
                    ),
                ],
            ),
        ),
    )
    
def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "title",
                name = "Title?",
                desc = "Title of playing content",
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
