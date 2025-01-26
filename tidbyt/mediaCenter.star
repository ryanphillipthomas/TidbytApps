load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("time.star", "time")

def main(config):
    base_image_url = config.str("image", "")  # URL or file path to the PNG image

    # Add a cache-busting query parameter using the current Unix timestamp
    timestamp = str(time.now().unix)
    image_url = base_image_url + "?ts=" + timestamp

    # Fetch the image from the cache-busted URL
    response = http.get(image_url)

    # Check if the response body is valid
    if response.body() == None:
        return render.Root(
            child=render.Box(
                width=64,
                height=32,
                child=render.Text("Image fetch failed")
            )
        )

    # Encode the image data to base64
    img_base64 = base64.encode(response.body())

    # Ensure the base64 string is properly formatted for render.Image
    img_base64_src = "data:image/png;base64," + img_base64

    # Return the rendered image
    return render.Root(
        child=render.Box(
            width=64,  # Full width of the Tidbyt display
            height=32,  # Full height of the Tidbyt display
            child=render.Image(
                src=img_base64_src,  # Properly formatted base64 image source
                width=24,  # Image width
                height=24,  # Image height
            ),
        )
    )

def get_schema():
    return schema.Schema(
        version="1",
        fields=[
            schema.Text(
                id="image",
                name="Image",
                desc="Homeassistant Auth Image URL",
                icon="image",
            ),
        ],
    )
