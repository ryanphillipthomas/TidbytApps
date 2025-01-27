load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("time.star", "time")


def main(config):
    title = "%s" % config.str("title", "")
    base_image_url = config.str("image", "")  # URL or file path to the PNG image
    
    render.Column(
     children=[
          render.Box(width=10, height=8, color="#a00"),
          render.Box(width=14, height=6, color="#0a0"),
          render.Box(width=16, height=4, color="#00a"),
     ],
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
