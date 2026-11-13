import QtQuick
import "../js/MaterialPalette.js" as MaterialPalette

QtObject {
    id: root

    property var sourceConfig: ({})
    property string sampledSeedHex: "#6750A4"

    function readKey(key, fallback) {
        if (!sourceConfig) {
            return fallback
        }
        var value = sourceConfig[key]
        return value === undefined || value === null || String(value) === ""
            ? fallback
            : String(value)
    }

    function readAny(keys, fallback) {
        for (var index = 0; index < keys.length; ++index) {
            var value = readKey(keys[index], "")
            if (value !== "") {
                return value
            }
        }
        return fallback
    }

    function readBool(keys, fallback) {
        var value = readAny(keys, fallback ? "true" : "false").toLowerCase()
        return value === "true" || value === "yes" || value === "1" || value === "on"
    }

    function normalizedMode() {
        var mode = readAny(["General/colorMode", "colorMode"], "monet").toLowerCase()
        return mode === "manual" || mode === "手动指定" || mode === "手动"
            ? "manual"
            : "monet"
    }

    function normalizedScheme() {
        var name = readAny(["General/manualScheme", "manualScheme"], "Green")
        return MaterialPalette.mdColor(name) !== "" ? name : (name.toLowerCase() === "custom" ? "custom" : "Green")
    }

    function normalizedColorScheme() {
        var value = readAny(["General/colorScheme", "colorScheme"], "dark").toLowerCase()
        return value === "light" ? "light" : "dark"
    }

    function colorFromSettings(role, fallback) {
        if (monetMode) {
            return fallback
        }
        var value = readKey("Colors/" + role, "")
        return MaterialPalette.isValidColor(value) ? value : fallback
    }

    function overrideFromSettings(componentKey, fallback) {
        if (monetMode) {
            return fallback
        }
        var value = readKey("Overrides/" + componentKey, "")
        return MaterialPalette.isValidColor(value) ? value : fallback
    }

    function colorComponents(value) {
        var text = String(value || "").trim()
        if (/^rgba?\(/i.test(text)) {
            var parts = text.substring(text.indexOf("(") + 1, text.indexOf(")")).split(",")
            return {
                r: Math.max(0, Math.min(255, Number(parts[0]))) / 255,
                g: Math.max(0, Math.min(255, Number(parts[1]))) / 255,
                b: Math.max(0, Math.min(255, Number(parts[2]))) / 255,
                a: parts.length > 3 ? Math.max(0, Math.min(1, Number(parts[3]))) : 1
            }
        }
        if (text.charAt(0) !== "#") {
            return { r: 0, g: 0, b: 0, a: 1 }
        }
        text = text.substring(1)
        if (text.length === 3 || text.length === 4) {
            var expanded = ""
            for (var index = 0; index < text.length; ++index) {
                expanded += text.charAt(index) + text.charAt(index)
            }
            text = expanded
        }
        var alpha = 1
        if (text.length === 8) {
            alpha = parseInt(text.substring(0, 2), 16) / 255
            text = text.substring(2)
        }
        return {
            r: parseInt(text.substring(0, 2), 16) / 255,
            g: parseInt(text.substring(2, 4), 16) / 255,
            b: parseInt(text.substring(4, 6), 16) / 255,
            a: alpha
        }
    }

    function alphaColor(value, opacity) {
        var components = colorComponents(value)
        return components.a < 0.999
            ? Qt.rgba(components.r, components.g, components.b, components.a)
            : Qt.rgba(components.r, components.g, components.b, opacity)
    }

    readonly property string colorMode: normalizedMode()
    readonly property bool monetMode: colorMode === "monet"
    readonly property string manualSchemeName: normalizedScheme()
    readonly property string colorSchemeName: normalizedColorScheme()
    readonly property bool darkScheme: colorSchemeName !== "light"
    readonly property bool animationsEnabled: readBool(["General/animationsEnabled", "animationsEnabled"], true)
    readonly property bool showClock: readBool(["General/showClock", "showClock"], true)

    readonly property string customSeed: readAny(["General/customPrimary", "customPrimary"], "#6750A4")
    readonly property string manualSeed: {
        if (manualSchemeName === "custom") {
            return MaterialPalette.isValidColor(customSeed) ? customSeed : "#6750A4"
        }
        return MaterialPalette.mdColor(manualSchemeName)
            || MaterialPalette.mdColor("Green")
            || "#4CAF50"
    }
    readonly property string effectiveSeed: monetMode
        ? (MaterialPalette.isValidColor(sampledSeedHex) ? sampledSeedHex : "#6750A4")
        : manualSeed

    readonly property string backgroundValue: readAny([
        "General/background",
        "background",
        "defaultBackground"
    ], "assets/default-wallpaper.svg")
    readonly property string backgroundType: readAny([
        "General/type",
        "type"
    ], "image").toLowerCase()
    readonly property string backgroundFillMode: readAny([
        "General/backgroundFillMode",
        "backgroundFillMode"
    ], "cover").toLowerCase()
    readonly property bool blurRequested: readBool([
        "General/blurEnabled",
        "blurEnabled"
    ], true)
    readonly property real panelBlurStrength: Math.max(0, Math.min(1,
        Number(readAny(["General/panelBlurStrength", "panelBlurStrength"], "80")) / 100))
    readonly property string defaultUserName: readAny([
        "General/defaultUser",
        "defaultUser"
    ], "")

    readonly property var generatedRoles: MaterialPalette.generateScheme(effectiveSeed, darkScheme)
    readonly property var roles: {
        var output = {}
        var roleNames = [
            "primary", "onPrimary", "primaryContainer", "onPrimaryContainer",
            "secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer",
            "tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer",
            "error", "onError", "errorContainer", "onErrorContainer",
            "surface", "surfaceDim", "surfaceBright",
            "surfaceContainerLowest", "surfaceContainerLow", "surfaceContainer",
            "surfaceContainerHigh", "surfaceContainerHighest",
            "onSurface", "onSurfaceVariant", "outline", "outlineVariant",
            "inverseSurface", "inverseOnSurface", "inversePrimary",
            "shadow", "scrim"
        ]
        for (var index = 0; index < roleNames.length; ++index) {
            var roleName = roleNames[index]
            output[roleName] = colorFromSettings(roleName, generatedRoles[roleName])
        }
        return output
    }

    function roleColor(roleName) {
        return colorFromSettings(roleName, generatedRoles[roleName])
    }

    readonly property string primary: roleColor("primary")
    readonly property string primaryContainer: roleColor("primaryContainer")
    readonly property string secondary: roleColor("secondary")
    readonly property string secondaryContainer: roleColor("secondaryContainer")
    readonly property string surface: roleColor("surface")
    readonly property string surfaceContainerLowest: roleColor("surfaceContainerLowest")
    readonly property string surfaceContainerLow: roleColor("surfaceContainerLow")
    readonly property string surfaceContainer: roleColor("surfaceContainer")
    readonly property string surfaceContainerHigh: roleColor("surfaceContainerHigh")
    readonly property string surfaceContainerHighest: roleColor("surfaceContainerHighest")
    readonly property string outline: roleColor("outline")
    readonly property string outlineVariant: roleColor("outlineVariant")
    readonly property string error: roleColor("error")
    readonly property string shadow: roleColor("shadow")

    // QML reserves names beginning with "on" for signal handlers in some
    // contexts, so the UI uses these aliases internally.
    readonly property string primaryForeground: roleColor("onPrimary")
    readonly property string surfaceForeground: roleColor("onSurface")
    readonly property string surfaceVariantForeground: roleColor("onSurfaceVariant")
    readonly property string errorForeground: roleColor("onError")

    readonly property var rawDialogSurface: overrideFromSettings("dialog.surface", surface)
    readonly property var dialogSurface: alphaColor(rawDialogSurface, darkScheme ? 0.72 : 0.78)
    readonly property var dialogOutline: overrideFromSettings(
        "dialog.outline",
        alphaColor(outline, 0.48)
    )
    readonly property var dialogShadow: overrideFromSettings("dialog.shadow", "#B0000000")
    readonly property var inputBackground: overrideFromSettings(
        "input.background",
        alphaColor(surfaceContainerHigh, 0.90)
    )
    readonly property var inputText: overrideFromSettings("input.text", surfaceForeground)
    readonly property var inputLabel: overrideFromSettings("input.label", surfaceVariantForeground)
    readonly property var inputOutline: overrideFromSettings("input.outline", outline)
    readonly property var inputFocus: overrideFromSettings("input.focus", primary)
    readonly property var revealText: overrideFromSettings("revealButton.text", primary)
    readonly property var loginBackground: overrideFromSettings("loginButton.background", primary)
    readonly property var loginText: overrideFromSettings("loginButton.text", primaryForeground)
    readonly property var sessionBackground: overrideFromSettings(
        "session.background",
        alphaColor(surfaceContainerHigh, 0.88)
    )
    readonly property var sessionPopupBackground: overrideFromSettings(
        "session.popupBackground",
        surfaceContainerHigh
    )
    readonly property var sessionText: overrideFromSettings("session.text", surfaceForeground)
    readonly property var powerBackground: overrideFromSettings(
        "power.background",
        alphaColor(surfaceContainerHigh, 0.78)
    )
    readonly property var powerText: overrideFromSettings("power.text", surfaceForeground)
    readonly property var clockText: overrideFromSettings("clock.text", "#FFFFFF")
    readonly property var clockSecondaryText: overrideFromSettings(
        "clock.secondaryText",
        "#D9FFFFFF"
    )
    readonly property var errorText: overrideFromSettings("error.text", errorForeground)
    readonly property var stateLayer: surfaceForeground
    readonly property var wallpaperScrim: darkScheme
        ? alphaColor(shadow, 0.25)
        : alphaColor("#000000", 0.12)
}
