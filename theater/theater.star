load("encoding/base64.star", "base64")
load("render.star", "render")

ICON_2 = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAAFARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAAAAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAFKADAAQAAAABAAAAFAAAAABB553+AAAACXBIWXMAAAsTAAALEwEAmpwYAAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgoZXuEHAAABW0lEQVQ4Ee2Sv0oDQRDGv825F4yaVrG0VEvBNu9gY2PtE1ibvIB/SkuxtrAP5LCz8AUUUgTFRlGLmJDby+fMJasQN0FREMGBZY+Z+X7zZw/480ZWC3p+ZBCSxoO+DfUwcn+J3FtRsEBjX2DcPWGU2rA7PgH2kTxcNabaG4Dx1vkoOBjQ8UTcJw/mgfRIexOhnM6ZMbvH8mFEqL7PGSuY0sz7DayzWSebCXldZ+f85OUBWNaY0CK9Ry0XjjqRDKr3TpF2tzKwFKdgkXG6OC0zz2p+Il1+0IkjCPTJVkR2Roa2LtIxYZxWykIg7ws+SuV9P3SuLxs0GVzBpSkhRSbuLtihVMvHkVbiYrkMFKxFWTidCM/y5NqNFA3aOGBfswV4275p7Rg31y5tGtu9uFvoAq0hKc8JUkPOfGehgPgmxYIv5Tm5sNEY/B4V8V5eGaxtuy/9gx72f//eBl4BsjaAI8ZoU5gAAAAASUVORK5CYII=

""")
ICON_1 = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAAFARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAAAAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAFKADAAQAAAABAAAAFAAAAABB553+AAAACXBIWXMAAAsTAAALEwEAmpwYAAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgoZXuEHAAABW0lEQVQ4Ee2Sv0oDQRDGv825F4yaVrG0VEvBNu9gY2PtE1ibvIB/SkuxtrAP5LCz8AUUUgTFRlGLmJDby+fMJasQN0FREMGBZY+Z+X7zZw/480ZWC3p+ZBCSxoO+DfUwcn+J3FtRsEBjX2DcPWGU2rA7PgH2kTxcNabaG4Dx1vkoOBjQ8UTcJw/mgfRIexOhnM6ZMbvH8mFEqL7PGSuY0sz7DayzWSebCXldZ+f85OUBWNaY0CK9Ry0XjjqRDKr3TpF2tzKwFKdgkXG6OC0zz2p+Il1+0IkjCPTJVkR2Roa2LtIxYZxWykIg7ws+SuV9P3SuLxs0GVzBpSkhRSbuLtihVMvHkVbiYrkMFKxFWTidCM/y5NqNFA3aOGBfswV4275p7Rg31y5tGtu9uFvoAq0hKc8JUkPOfGehgPgmxYIv5Tm5sNEY/B4V8V5eGaxtuy/9gx72f//eBl4BsjaAI8ZoU5gAAAAASUVORK5CYII=

""")

LOCALIZED_STRINGS = {
    "1": {
        "en": "Running",
    },
    "2": {
        "en": "theater",
    },
}

def main(config):
    lang = config.get("lang", "en")

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
                            render.Image(src = ICON_1),
                            render.Stack(
                                children = [
                                    render.Padding(
                                        pad = (0, 0, 0, 0),
                                        child = render.Text(LOCALIZED_STRINGS["1"][lang]),
                                    ),
                                    render.Padding(
                                        pad = (0, 10, 0, 0),
                                        child = render.Text(LOCALIZED_STRINGS["2"][lang]),
                                    ),
                                ],
                            ),
                        ],
                    ),
                    render.Row(
                        expanded = True,  # Use as much horizontal space as possible
                        main_align = "space_evenly",  # Controls horizontal alignment
                        cross_align = "center",  # Controls vertical alignment
                        children = [
                            render.Image(src = ICON_2),
                            render.Stack(
                                children = [
                                    render.Padding(
                                        pad = (0, 0, 0, 0),
                                        child = render.Text(LOCALIZED_STRINGS["1"][lang]),
                                    ),
                                    render.Padding(
                                        pad = (0, 10, 0, 0),
                                        child = render.Text(LOCALIZED_STRINGS["2"][lang]),
                                    ),
                                ],
                            ),
                        ],
                    ),
                ],
            ),
        ),
    )
