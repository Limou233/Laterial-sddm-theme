.pragma library

// Palette utilities for Material 3 Expressive. These are intentionally
// self-contained so the greeter does not need Plasma's color engine.

var mdColors = {
    red: "#F44336",
    pink: "#E91E63",
    purple: "#9C27B0",
    deeppurple: "#673AB7",
    indigo: "#3F51B5",
    blue: "#2196F3",
    lightblue: "#03A9F4",
    cyan: "#00BCD4",
    teal: "#009688",
    green: "#4CAF50",
    lightgreen: "#8BC34A",
    lime: "#CDDC39",
    yellow: "#FFEB3B",
    amber: "#FFC107",
    orange: "#FF9800",
    deeporange: "#FF5722",
    brown: "#795548",
    bluegrey: "#607D8B",
    grey: "#9E9E9E"
}

function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, value))
}

function normalizeColorName(name) {
    return String(name || "").replace(/[\s_-]/g, "").toLowerCase()
}

function isValidColor(value) {
    var text = String(value || "").trim()
    return /^#(?:[0-9a-f]{3,4}|[0-9a-f]{6}|[0-9a-f]{8})$/i.test(text)
        || /^rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+(?:\s*,\s*(?:0|1|0?\.\d+))?\s*\)$/i.test(text)
}

function mdColor(name) {
    return mdColors[normalizeColorName(name)] || ""
}

function hexToRgb(hex) {
    var value = String(hex || "").trim()
    if (value.charAt(0) !== "#") {
        return { r: 103, g: 80, b: 164 }
    }
    value = value.substring(1)
    if (value.length === 3 || value.length === 4) {
        value = value.substring(0, 3).split("").map(function (part) {
            return part + part
        }).join("")
    } else if (value.length === 8) {
        value = value.substring(2)
    } else if (value.length !== 6) {
        return { r: 103, g: 80, b: 164 }
    }
    return {
        r: parseInt(value.substring(0, 2), 16),
        g: parseInt(value.substring(2, 4), 16),
        b: parseInt(value.substring(4, 6), 16)
    }
}

function rgbToHsl(red, green, blue) {
    var r = red / 255
    var g = green / 255
    var b = blue / 255
    var maximum = Math.max(r, g, b)
    var minimum = Math.min(r, g, b)
    var delta = maximum - minimum
    var lightness = (maximum + minimum) / 2
    var saturation = 0
    var hue = 0

    if (delta > 0) {
        saturation = delta / (1 - Math.abs(2 * lightness - 1))
        if (maximum === r) {
            hue = ((g - b) / delta) % 6
        } else if (maximum === g) {
            hue = (b - r) / delta + 2
        } else {
            hue = (r - g) / delta + 4
        }
        hue *= 60
        if (hue < 0) {
            hue += 360
        }
    }

    return { h: hue, s: saturation, l: lightness }
}

function hslToRgb(hue, saturation, lightness) {
    var h = ((hue % 360) + 360) % 360
    var s = clamp(saturation, 0, 1)
    var l = clamp(lightness, 0, 1)
    var chroma = (1 - Math.abs(2 * l - 1)) * s
    var segment = h / 60
    var x = chroma * (1 - Math.abs(segment % 2 - 1))
    var r = 0
    var g = 0
    var b = 0

    if (segment < 1) {
        r = chroma; g = x
    } else if (segment < 2) {
        r = x; g = chroma
    } else if (segment < 3) {
        g = chroma; b = x
    } else if (segment < 4) {
        g = x; b = chroma
    } else if (segment < 5) {
        r = x; b = chroma
    } else {
        r = chroma; b = x
    }

    var match = l - chroma / 2
    return {
        r: Math.round((r + match) * 255),
        g: Math.round((g + match) * 255),
        b: Math.round((b + match) * 255)
    }
}

function channelToHex(channel) {
    var value = clamp(Math.round(channel), 0, 255).toString(16)
    return value.length === 1 ? "0" + value : value
}

function rgbToHex(red, green, blue) {
    return "#" + channelToHex(red) + channelToHex(green) + channelToHex(blue)
}

function hsl(hue, saturation, lightness) {
    var value = hslToRgb(hue, saturation, lightness)
    return rgbToHex(value.r, value.g, value.b)
}

function seedFromPixels(data, width, height) {
    if (!data || !width || !height) {
        return "#6750A4"
    }

    var hueX = 0
    var hueY = 0
    var hueWeight = 0
    var saturationSum = 0
    var lightnessSum = 0
    var allR = 0
    var allG = 0
    var allB = 0
    var allCount = 0

    // A small stride is enough to find the dominant mood of a wallpaper.
    var pixelCount = width * height
    var stride = Math.max(1, Math.floor(pixelCount / 1600))
    for (var pixel = 0; pixel < pixelCount; pixel += stride) {
        var offset = pixel * 4
        var alpha = data[offset + 3]
        if (alpha < 96) {
            continue
        }

        var red = data[offset]
        var green = data[offset + 1]
        var blue = data[offset + 2]
        allR += red
        allG += green
        allB += blue
        allCount += 1

        var hslValue = rgbToHsl(red, green, blue)
        var chroma = Math.max(red, green, blue) - Math.min(red, green, blue)
        if (chroma < 22 || hslValue.l < 0.08 || hslValue.l > 0.94) {
            continue
        }

        // Prefer saturated mid-tones, but keep muted wallpapers usable.
        var weight = (0.35 + hslValue.s) * (0.30 + chroma / 255)
            * (1 - Math.abs(hslValue.l - 0.56) * 0.8)
        var angle = hslValue.h * Math.PI / 180
        hueX += Math.cos(angle) * weight
        hueY += Math.sin(angle) * weight
        hueWeight += weight
        saturationSum += hslValue.s
        lightnessSum += hslValue.l
    }

    if (hueWeight < 0.010 || allCount === 0) {
        if (allCount === 0) {
            return "#6750A4"
        }
        var average = rgbToHsl(
            allR / allCount,
            allG / allCount,
            allB / allCount
        )
        return hsl(average.h, clamp(average.s + 0.14, 0.22, 0.56), 0.48)
    }

    var hue = Math.atan2(hueY, hueX) * 180 / Math.PI
    if (hue < 0) {
        hue += 360
    }
    var saturation = clamp(saturationSum / hueWeight, 0.30, 0.62)
    var lightness = clamp(lightnessSum / hueWeight, 0.38, 0.62)
    return hsl(hue, saturation, lightness)
}

function generateScheme(seedHex, darkMode) {
    var seed = isValidColor(seedHex) ? seedHex : "#6750A4"
    var rgb = hexToRgb(seed)
    var seedHsl = rgbToHsl(rgb.r, rgb.g, rgb.b)
    var hue = seedHsl.h
    var chroma = clamp(seedHsl.s, 0.32, 0.62)
    var dark = !!darkMode

    if (!dark) {
        return {
            primary: hsl(hue, chroma, 0.39),
            onPrimary: hsl(hue, 0.70, 0.985),
            primaryContainer: hsl(hue, chroma * 0.72, 0.88),
            onPrimaryContainer: hsl(hue, 0.76, 0.16),
            secondary: hsl(hue, chroma * 0.54, 0.43),
            onSecondary: hsl(hue, 0.55, 0.985),
            secondaryContainer: hsl(hue, chroma * 0.52, 0.89),
            onSecondaryContainer: hsl(hue, 0.64, 0.19),
            tertiary: hsl(hue + 58, chroma * 0.68, 0.42),
            onTertiary: hsl(hue + 58, 0.58, 0.985),
            tertiaryContainer: hsl(hue + 58, chroma * 0.46, 0.89),
            onTertiaryContainer: hsl(hue + 58, 0.64, 0.18),
            error: "#BA1A1A",
            onError: "#FFFFFF",
            errorContainer: "#FFDAD6",
            onErrorContainer: "#410002",
            surface: hsl(hue, 0.15, 0.985),
            surfaceDim: hsl(hue, 0.10, 0.86),
            surfaceBright: hsl(hue, 0.13, 0.99),
            surfaceContainerLowest: "#FFFFFF",
            surfaceContainerLow: hsl(hue, 0.15, 0.96),
            surfaceContainer: hsl(hue, 0.16, 0.94),
            surfaceContainerHigh: hsl(hue, 0.17, 0.91),
            surfaceContainerHighest: hsl(hue, 0.18, 0.87),
            onSurface: hsl(hue, 0.18, 0.105),
            onSurfaceVariant: hsl(hue, 0.14, 0.30),
            outline: hsl(hue, 0.12, 0.50),
            outlineVariant: hsl(hue, 0.13, 0.78),
            inverseSurface: hsl(hue, 0.12, 0.20),
            inverseOnSurface: hsl(hue, 0.12, 0.95),
            inversePrimary: hsl(hue, chroma * 0.68, 0.78),
            shadow: "#000000",
            scrim: "#000000"
        }
    }

    return {
        primary: hsl(hue, chroma * 0.86, 0.78),
        onPrimary: hsl(hue, 0.68, 0.14),
        primaryContainer: hsl(hue, chroma * 0.72, 0.29),
        onPrimaryContainer: hsl(hue, chroma * 0.62, 0.92),
        secondary: hsl(hue, chroma * 0.59, 0.80),
        onSecondary: hsl(hue, 0.55, 0.16),
        secondaryContainer: hsl(hue, chroma * 0.52, 0.30),
        onSecondaryContainer: hsl(hue, chroma * 0.58, 0.92),
        tertiary: hsl(hue + 58, chroma * 0.66, 0.80),
        onTertiary: hsl(hue + 58, 0.58, 0.15),
        tertiaryContainer: hsl(hue + 58, chroma * 0.50, 0.30),
        onTertiaryContainer: hsl(hue + 58, chroma * 0.58, 0.92),
        error: "#FFB4AB",
        onError: "#690005",
        errorContainer: "#93000A",
        onErrorContainer: "#FFDAD6",
        surface: hsl(hue, 0.17, 0.075),
        surfaceDim: hsl(hue, 0.16, 0.075),
        surfaceBright: hsl(hue, 0.17, 0.26),
        surfaceContainerLowest: hsl(hue, 0.17, 0.045),
        surfaceContainerLow: hsl(hue, 0.17, 0.105),
        surfaceContainer: hsl(hue, 0.17, 0.13),
        surfaceContainerHigh: hsl(hue, 0.17, 0.17),
        surfaceContainerHighest: hsl(hue, 0.17, 0.22),
        onSurface: hsl(hue, 0.12, 0.92),
        onSurfaceVariant: hsl(hue, 0.13, 0.76),
        outline: hsl(hue, 0.12, 0.57),
        outlineVariant: hsl(hue, 0.13, 0.28),
        inverseSurface: hsl(hue, 0.10, 0.91),
        inverseOnSurface: hsl(hue, 0.12, 0.19),
        inversePrimary: hsl(hue, chroma * 0.78, 0.39),
        shadow: "#000000",
        scrim: "#000000"
    }
}
