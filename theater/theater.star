load("encoding/base64.star", "base64")
load("render.star", "render")
load("schema.star", "schema")

def main(config):
    title = "%s" % config.str("title", "")
    image_data = config.str("image", "")
    
    # Decode the base64 image string
    image = base64.decode(image_data)
    
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
                            render.Image(image),
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
                desc = "Base64 encoded image string",
                icon = "image",
            ),
        ],
    )
