load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("time.star", "time")

def main(config):
    title = config.get("title", "")
    base_image_url = config.get("image", "")  # URL to the PNG image

    # Add cache-busting query parameter using the current Unix timestamp
    timestamp = str(time.now().unix)  # Correctly access the unix property
    image_url = base_image_url + "?ts=" + timestamp

    # Fetch the image from the cache-busted URL
    response = http.get(image_url)
    if response.status_code != 200:
        return render.Text("Failed to load image.")
    img = response.body()

    return render.Root(
        child=render.Row(
            main_align="start",  # Align items to the start of the row
            cross_align="center",  # Center alignment vertically
            children=[
                render.Image(src=img, width=27, height=27),  # Display the image
                render.Column(
                    main_align="start",
                    cross_align="start",
                    children=[
                        render.Text(content=title, color="#A9A9A9"),  # Gray text
                        render.Text(content=title, font="6x13", weight="bold"),  # Bold and larger text
                        render.Text(content=title, color="#FFFFFF"),  # White text
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
