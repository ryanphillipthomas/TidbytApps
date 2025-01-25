# Save media player image to Home Assistant media folder

entity_id = data.get("entity_id")
file_name = data.get("file_name", "media_player_image.jpg")  # Default filename

if not entity_id:
    logger.error("No media player entity ID provided!")
    return

# Get the entity picture URL
media_player = hass.states.get(entity_id)
if not media_player:
    logger.error(f"Entity {entity_id} not found!")
    return

entity_picture = media_player.attributes.get("entity_picture")
if not entity_picture:
    logger.error(f"No entity picture found for {entity_id}!")
    return

# Full URL of the image
base_url = hass.config.api.base_url  # Your Home Assistant URL
image_url = f"{base_url}{entity_picture}"

# Get the image
headers = {"Authorization": f"Bearer {hass.config.api_token}"}
response = requests.get(image_url, headers=headers)

if response.status_code == 200:
    # Save the image to the media folder
    media_path = f"/media/media_player/{file_name}"
    with open(f"{hass.config.path('www')}{media_path}", "wb") as file:
        file.write(response.content)
    logger.info(f"Image saved to {media_path}")
else:
    logger.error(f"Failed to download image: {response.status_code}")
