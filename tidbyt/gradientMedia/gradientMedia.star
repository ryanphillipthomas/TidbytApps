"""
Applet: Gradient
Summary: Displays dynamic gradients
Description: Customize gradient fills for your Tidbyt.
Author: Jeffrey Lancaster
"""

load("math.star", "math")
load("random.star", "random")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")

PIXLET_W = 64
PIXLET_H = 32
GLOBAL_FONT = "tom-thumb"  # or "CG-pixel-3x5-mono"

def median(val1, val2):
    return math.floor((val1 + val2) / 2)

def makeRange(minValue, maxValue, numValues):
    rangeArray = []
    for i in range(0, numValues):
        step = (maxValue - minValue) / numValues
        calcValue = math.round(minValue + (i * step))
        rangeArray.append(calcValue)
    return rangeArray

def rgbRange(start, end, steps):
    rRange = makeRange(start[0], end[0], steps)
    gRange = makeRange(start[1], end[1], steps)
    bRange = makeRange(start[2], end[2], steps)
    returnRange = []
    for n in range(0, steps):
        returnRange.append([rRange[n], gRange[n], bRange[n]])
    return returnRange

# from: https://www.educative.io/answers/how-to-convert-hex-to-rgb-and-rgb-to-hex-in-python
def hex_to_rgb(hex):
    hex = hex.replace("#", "")
    rgb = []
    for i in (0, 2, 4):
        decimal = int(hex[i:i + 2], 16)
        rgb.append(decimal)
    return tuple(rgb)

def rgb_to_hex(r, g, b):
    rgbArr = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    hex = "#"
    r = math.floor(r)
    g = math.floor(g)
    b = math.floor(b)
    for i in (r, g, b):
        secondNum = i % 16
        firstNum = math.floor((i - secondNum) / 16)
        hex += rgbArr[firstNum] + rgbArr[secondNum]
    return hex

def randomColor():
    randomRed = random.number(0, 255)
    randomGreen = random.number(0, 255)
    randomBlue = random.number(0, 255)
    return rgb_to_hex(randomRed, randomGreen, randomBlue)

def shiftLeft(thisArray):
    newThisArray = []
    for i in thisArray:
        newThisArray.append(i[1:] + i[:1])
    return newThisArray

def shiftRight(thisArray):
    newThisArray = []
    for i in thisArray:
        newThisArray.append(i[-1:] + i[:-1])
    return newThisArray

# from: https://stackoverflow.com/questions/2150108/efficient-way-to-rotate-a-list-in-python
def shiftUp(thisArray):
    return thisArray[1:] + thisArray[:1]

def shiftDown(thisArray):
    return thisArray[-1:] + thisArray[:-1]

def four_color_gradient(topL, topR, botL, botR, config):
    # convert inputs to rgb
    topLrgb = hex_to_rgb(topL)
    topRrgb = hex_to_rgb(topR)
    botLrgb = hex_to_rgb(botL)
    botRrgb = hex_to_rgb(botR)

    # determine left column and right column ranges: PIXLET_H
    leftCol = rgbRange(topLrgb, botLrgb, PIXLET_H)
    rightCol = rgbRange(topRrgb, botRrgb, PIXLET_H)

    # for each row, determine range: PIXLET_W
    gradientArray = []
    animatedArray = []

    # make basic gradient array
    for n in range(0, PIXLET_H):
        rowGradient = rgbRange(leftCol[n], rightCol[n], PIXLET_W)
        gradientArray.append(rowGradient)

    # convert each value in gradientArray from RGB to hex
    for n, i in enumerate(gradientArray):
        for m, j in enumerate(i):
            gradientArray[n][m] = rgb_to_hex(j[0], j[1], j[2])

    # if animated, expand gradientArray in animatedArray
    if config.bool("animation", False) == True:
        if config.get("direction") == "up" or config.get("direction") == "down":
            # append the mirror image (adds more rows down)
            mirrorArray = gradientArray[::-1]
            gradientArray += mirrorArray
        elif config.get("direction") == "left" or config.get("direction") == "right":
            # append the mirror image (adds more pixels across)
            for n, i in enumerate(gradientArray):
                mirrorRow = i[::-1]
                gradientArray[n] += mirrorRow

        # add to animatedArray
        if config.get("direction") == "left" or config.get("direction") == "right":
            numFrames = len(gradientArray[0])  # PIXLET_W * 2
        else:
            numFrames = len(gradientArray)  # PIXLET_H * 2

        for i in range(0, numFrames):
            animatedArray.append(gradientArray)

            # shift
            if config.get("direction") == "up":
                gradientArray = shiftUp(gradientArray)
            elif config.get("direction") == "down":
                gradientArray = shiftDown(gradientArray)
            elif config.get("direction") == "left":
                gradientArray = shiftLeft(gradientArray)
            elif config.get("direction") == "right":
                gradientArray = shiftRight(gradientArray)
    else:
        animatedArray = [gradientArray]

    return animatedArray

def two_color_gradient(topL, botR, config):
    topLrgb = hex_to_rgb(topL)
    botRrgb = hex_to_rgb(botR)
    medianR = median(topLrgb[0], botRrgb[0])
    medianG = median(topLrgb[1], botRrgb[1])
    medianB = median(topLrgb[2], botRrgb[2])

    # average r, g, b for other two corners
    medianRGB = rgb_to_hex(medianR, medianG, medianB)
    return four_color_gradient(topL, medianRGB, medianRGB, botR, config)

def displayArray(array, labelCount, config):
    animationChildren = []
    for n in array:  # frames
        columnChildren = []
        stackChildren = []
        for m in n:  # column of rows
            rowChildren = []
            for p in m:  # cells in row
                rowChildren.append(
                    render.Box(width = 1, height = 1, color = p),
                )
            columnChildren.append(
                render.Row(
                    children = rowChildren,
                ),
            )

        # add the gradient to the stack
        stackChildren.append(
            render.Column(children = columnChildren),
        )

        # add labels to the stack
        if config.bool("labels"):
            if labelCount == 4:
                topL = n[0][0]
                topR = n[0][PIXLET_W - 1]
                botL = n[PIXLET_H - 1][0]
                botR = n[PIXLET_H - 1][PIXLET_W - 1]
                if config.bool("animation") == False:
                    if config.get("gradient_type") == "4color":
                        topL = config.get("color1")
                        topR = config.get("color2")
                        botL = config.get("color3")
                        botR = config.get("color4")
                    elif config.get("gradient_type") == "default":
                        topL = "#FF0000"
                        topR = "#FFFF00"
                        botL = "#0000FF"
                        botR = "#FFFFFF"
                stackChildren.extend([
                    render.Padding(
                        child = render.Text(content = topL.upper().replace("#", ""), color = "#000", font = GLOBAL_FONT),
                        pad = (1, 1, 1, 1),
                    ),
                    render.Padding(
                        child = render.Text(content = topR.upper().replace("#", ""), color = "#000", font = GLOBAL_FONT),
                        pad = (40, 1, 1, 1),
                    ),
                    render.Padding(
                        child = render.Text(content = botL.upper().replace("#", ""), color = "#000", font = GLOBAL_FONT),
                        pad = (1, 26, 1, 1),
                    ),
                    render.Padding(
                        child = render.Text(content = botR.upper().replace("#", ""), color = "#000", font = GLOBAL_FONT),
                        pad = (40, 26, 1, 1),
                    ),
                ])
            elif labelCount == 2:
                topL = n[0][0]
                botR = n[PIXLET_H - 1][PIXLET_W - 1]
                if config.bool("animation") == False:
                    topL = config.get("color1")
                    botR = config.get("color2")
                stackChildren.extend([
                    render.Padding(
                        child = render.Text(content = topL.upper().replace("#", ""), color = "#000", font = GLOBAL_FONT),
                        pad = (1, 1, 1, 1),
                    ),
                    render.Padding(
                        child = render.Text(content = botR.upper().replace("#", ""), color = "#000", font = GLOBAL_FONT),
                        pad = (40, 26, 1, 1),
                    ),
                ])

        # add the stack (frame) to the animation
        animationChildren.append(
            render.Stack(children = stackChildren),
        )

    return animationChildren

def main(config):

    ERROR_IMG = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAKhlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgExAAIAAAAkAAAAWodpAAQAAAABAAAAfgAAAAAAAABIAAAAAQAAAEgAAAABQWRvYmUgUGhvdG9zaG9wIENDIDIwMTcgKE1hY2ludG9zaCkAAAOgAQADAAAAAQABAACgAgAEAAAAAQAAABqgAwAEAAAAAQAAABoAAAAACLZimQAAAAlwSFlzAAALEwAACxMBAJqcGAAABPppVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDYuMC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICAgICAgICAgICB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIKICAgICAgICAgICAgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ0MgMjAxNyAoTWFjaW50b3NoKTwveG1wOkNyZWF0b3JUb29sPgogICAgICAgICA8eG1wTU06RGVyaXZlZEZyb20gcmRmOnBhcnNlVHlwZT0iUmVzb3VyY2UiPgogICAgICAgICAgICA8c3RSZWY6aW5zdGFuY2VJRD54bXAuaWlkOjIwMDRlM2JhLTAzMTQtNGE1YS1iYzU4LWZmMmI3YmMxZjcwYzwvc3RSZWY6aW5zdGFuY2VJRD4KICAgICAgICAgICAgPHN0UmVmOmRvY3VtZW50SUQ+YWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmQ3MTJkNjgzLTMzN2QtMTE3YS04ZWI5LWQ0ZGI4NWVmNDM1Mzwvc3RSZWY6ZG9jdW1lbnRJRD4KICAgICAgICAgPC94bXBNTTpEZXJpdmVkRnJvbT4KICAgICAgICAgPHhtcE1NOkRvY3VtZW50SUQ+eG1wLmRpZDpEM0MyRTIyNjJGODQxMUU3QjQ4QUM0REMxNTUwNzFERTwveG1wTU06RG9jdW1lbnRJRD4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDpEMzcwNEM3ODJGODQxMUU3QjQ4QUM0REMxNTUwNzFERTwveG1wTU06SW5zdGFuY2VJRD4KICAgICAgICAgPHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD54bXAuZGlkOmI2NGQzMDMyLWRlNzYtMTY0OS04ZGE5LTM2YTFmYzZjZThhMDwveG1wTU06T3JpZ2luYWxEb2N1bWVudElEPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzI8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgqDUj9DAAAHdklEQVRIDZVWC3CVRxX+9n/dV27uzTsE2uQCZYAkPEpseXUaaAtTrcPoTK46o1WEoWjVytCK4mh/prZiBXTGKk2xA2Nrnd44GqlFCsSAhCIQhocklHfCNcnN675f/3Pd/0+CUNDRndl/d8/ZPed8Z885+wPjjQKEyrIwsb7XSCklVp/gybLMTcz/22jJtvm3H2ZzLhQC//GDoVCXNEHbLe92vie/U2qtZZn+T8q4UFMTTwihNzZtWBXetm0tm5vBIIxm2ixCBtfeOIaysuPcxkPNhzZbwgu74wviA5Fj7/VTtywTs3Ndp9jeSIX2xvb/7BGKMVf8BvD0vfXjs33Hf3V86kt4wBJo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
""")

    random.seed(time.now().unix // 15)

    # define gradientArray and labels
    animatedArray = []
    labelCount = 4
    if config.get("gradient_type") == "random":
        color1 = randomColor()
        color2 = randomColor()
        color3 = randomColor()
        color4 = randomColor()
        animatedArray = four_color_gradient(color1, color2, color3, color4, config)
    elif config.get("gradient_type") == "4color":
        color1 = config.get("color1")
        color2 = config.get("color2")
        color3 = config.get("color3")
        color4 = config.get("color4")
        animatedArray = four_color_gradient(color1, color2, color3, color4, config)
    elif config.get("gradient_type") == "2color":
        color1 = config.get("color1")
        color2 = config.get("color2")
        animatedArray = two_color_gradient(color1, color2, config)
        labelCount = 2
    else:
        animatedArray = four_color_gradient("#FF0000", "#FFFF00", "#0000FF", "#FFFFFF", config)

    # show animatedArray with labels
    animationChildren = displayArray(animatedArray, labelCount, config)

    # get the delay preference
    if config.get("speed") == "fast":
        animation_delay = 10
    else:
        animation_delay = 500

    # show the animation
    # Return the stacked layout
    return render.Root(
        delay = animation_delay,  # Set the delay for the entire widget
        child = render.Stack(
            children = [
                # Base animation
                render.Animation(
                    children = animationChildren,
                ),
                # Column of 3 rows over the animation
                render.Column(
                    main_align="center",
                    cross_align="center",
                    children = [
                        render.Box(
                            width = 64,  # Adjust width for the first row
                            height = 5,  # Adjust height for the first row
                        ),
                        render.Row(
                            main_align="center",
                            cross_align="center",
                            children = [
                                render.Box(
                                    width = 22,  # First box in the row
                                    height = 22,
                                ),
                                render.Box(
                                    width = 22,  # Cyan box containing the image
                                    height = 22,
                                    child = render.Image(
                                        width = 22,
                                        height = 22,
                                        src = ERROR_IMG
                                    )
                                ),
                                render.Box(
                                    width = 30,  # Third box in the row
                                    height = 22,
                                ),
                            ],
                        ),
                        render.Box(
                            width = 64,
                            height = 5,
                        ),
                    ],
                ),
            ]
        )
    )
    
def more_gradient_options(gradient_type):
    if gradient_type == "2color":
        return [
            schema.Color(
                id = "color1",
                name = "Color #1",
                desc = "Top left corner",
                icon = "brush",
                default = "#FF0000",
            ),
            schema.Color(
                id = "color2",
                name = "Color #2",
                desc = "Bottom right corner",
                icon = "brush",
                default = "#0000FF",
            ),
        ]
    elif gradient_type == "4color":
        return [
            schema.Color(
                id = "color1",
                name = "Color #1",
                desc = "Top left corner",
                icon = "brush",
                default = "#FF0000",
            ),
            schema.Color(
                id = "color2",
                name = "Color #2",
                desc = "Top right corner",
                icon = "brush",
                default = "#FFFF00",
            ),
            schema.Color(
                id = "color3",
                name = "Color #3",
                desc = "Bottom left corner",
                icon = "brush",
                default = "#0000FF",
            ),
            schema.Color(
                id = "color4",
                name = "Color #4",
                desc = "Bottom right corner",
                icon = "brush",
                default = "#FFFFFF",
            ),
        ]
    else:
        return []

def get_schema():
    gradientOptions = [
        schema.Option(
            display = "Default",
            value = "default",
        ),
        schema.Option(
            display = "Random",
            value = "random",
        ),
        schema.Option(
            display = "Pick 2",
            value = "2color",
        ),
        schema.Option(
            display = "Pick 4",
            value = "4color",
        ),
    ]

    animationSpeedOptions = [
        schema.Option(
            display = "Fast",
            value = "fast",
        ),
        schema.Option(
            display = "Slow",
            value = "slow",
        ),
    ]

    animationDirectionOptions = [
        schema.Option(
            display = "Scroll up",
            value = "up",
        ),
        schema.Option(
            display = "Scroll down",
            value = "down",
        ),
        schema.Option(
            display = "Scroll left",
            value = "left",
        ),
        schema.Option(
            display = "Scroll right",
            value = "right",
        ),
    ]

    # icons from: https://fontawesome.com/
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "gradient_type",
                name = "Gradient Type",
                icon = "circleHalfStroke",
                desc = "Which gradient to show",
                default = gradientOptions[0].value,
                options = gradientOptions,
            ),
            schema.Toggle(
                id = "labels",
                name = "Text",
                desc = "Show hex values?",
                icon = "font",
                default = False,
            ),
            schema.Toggle(
                id = "animation",
                name = "Animation",
                desc = "Animate the gradient?",
                icon = "play",
                default = False,
            ),
            schema.Generated(
                id = "gradient_generated",
                source = "gradient_type",
                handler = more_gradient_options,
            ),
            # schema.Generated(
            #     id = "animation_generated",
            #     source = "animation",
            #     handler = more_animation_options,
            # ),
            schema.Dropdown(
                id = "speed",
                name = "Animation Speed",
                icon = "forward",
                desc = "How fast to scroll",
                default = "slow",
                options = animationSpeedOptions,
            ),
            schema.Dropdown(
                id = "direction",
                name = "Direction",
                icon = "arrowsUpDownLeftRight",
                desc = "Which way to scroll",
                default = animationDirectionOptions[0].value,
                options = animationDirectionOptions,
            ),
        ],
    )
