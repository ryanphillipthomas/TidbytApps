load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("encoding/base64.star", "base64")
load("time.star", "time")

IMAGE_FALLBACK = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAgNJREFUOE9tVAGOwzAIM8m7lr292bsa7rCB9aSrJnVJgRjbxGDmgAMwWLzjZ+Db8h1/3CPm72P/7OdeFIuaDndjIR0BXHtjraXDAOy98Yo1D868jHa4YBFIVhAog7nj2h+s92pY+7qw3m8Wi4cFmGA6/VuQKxYNJIo3fD4b67W0Nse+tgpWMX3oDK7YXXOlgHiuSF6vWuLD9Vvksq0iJUsGVYWQgvC7OOQZZlCLK3kVwtcKhFKsOur/pjynEAE8qHhI3BQE+Wwv6ei4p5BySFbK3h04J3aLxWSLgfWU3sCYoxls8wWHElvsnHP+WCgWKSB5K7s8y0cnc0xJaWlscmcuhOqVdihPSurvAET4tMm4cx/YiPyI7yEo69yZV+YQlpyj9FrujUHEtx+MMendppuEm+EcFdRJ2RjB63u5Ib4MGzzq9psts7FomY6nusDx852ClqLHXbOebrUx4H7ovhFoxaH8IkMYjt8pcqpZ6KJpToFuD41cumHOVJsc0s19tdy3bFPzWobhZJTPHsXmjLaFuuZMYVE3bdMy1FVG/4pDZSs9fFiC5YesRA7rlBAmvFiocz+X1cwImzCnZkNeJrSU5TEODr8P15UgnhUSnqtrq+5AQS3b9IWaN0lQn1y2qtluFAjPFe99URFtXlxlWvEonqh7D3tCK4g5NWERlinVfxN/AHCkVywDeaBxAAAAAElFTkSuQmCC
""")


def main(config):
    title = "%s" % config.str("title", "")
    base_image_url = config.str("image", "")  # URL or file path to the PNG image

    # Add cache-busting query parameter using the current Unix timestamp
    timestamp = str(time.now().unix)  # Use time.now().unix as a property, not a function
    image_url = base_image_url + "?ts=" + timestamp

    # Fetch the image from the cache-busted URL
    img = http.get(image_url).body()
    
    render.Column(
     children=[
          render.Box(width=10, height=8, color="#a00"),
          render.Box(width=14, height=6, color="#0a0"),
          render.Box(width=16, height=4, color="#00a"),
          render.Image(src=img,width=24,height=24),
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
