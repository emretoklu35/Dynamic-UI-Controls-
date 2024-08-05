# Dynamic UI Controls 

This iOS project dynamically creates UI controls based on JSON data. The supported controls include labels, textboxes, pickers, images, buttons, radio buttons, and checkboxes.

Features

    •    Dynamic UI Generation: Load and render various UI elements (labels, textboxes, pickers, images, buttons, radio buttons, checkboxes) based on a JSON configuration file.
    •    Customizable Styles: Control properties such as text, font weight, alignment, colors, and more via the JSON file.
    •    Pickers with Toolbars: Picker controls with associated toolbars for selection.
    •    Image Loading: Asynchronously load images from URLs.
    •    Radio Button Group: Exclusive selection for radio buttons.
    •    Checkboxes: Toggle multiple checkboxes independently.

How It Works

    1.    JSON Parsing: The JSON file (controls.json) is parsed to extract the control definitions.
    2.    UI Setup: Based on the parsed JSON data, various UI elements are dynamically created and added to a scrollable content view.
    3.    Event Handling: Buttons and other controls have associated actions and event handlers.
    
JSON Structure

The JSON file should follow this structure:
[
    {
        "control": "label",
        "text": "Sample Label",
        "fontWeight": "bold",
        "alignment": "center",
        "color": "#FF5733"
    },
    {
        "control": "textbox",
        "text": "Sample Textbox",
        "backgroundColor": "#DDDDDD",
        "textColor": "#333333"
    },
    {
        "control": "picker",
        "items": [
            { "name": "Option 1", "url": "https://example.com/1" },
            { "name": "Option 2", "url": "https://example.com/2" }
        ],
        "placeholder": "Choose an option",
        "backgroundColor": "#FFFFFF",
        "textColor": "#000000",
        "font": { "size": 14, "weight": "regular" }
    },
    {
        "control": "image",
        "url": "https://example.com/image.jpg"
    },
    {
        "control": "button",
        "text": "Submit"
    },
    {
        "control": "radio",
        "items": [
            { "title": "Radio 1" },
            { "title": "Radio 2" }
        ]
    },
    {
        "control": "checkboxes",
        "checkboxes": [
            { "id": "check1", "title": "Checkbox 1" },
            { "id": "check2", "title": "Checkbox 2" }
        ]
    }
]


Project Structure

    •    ViewController.swift: Contains the main logic for loading and setting up the UI controls based on the JSON data.
    •    UIColor+Hex.swift: Extension to initialize UIColor from a hex string.
    •    UIImageView+Load.swift: Extension to asynchronously load images from a URL.

Usage

    1.    Add your JSON configuration file to the project.
    2.    Ensure the JSON file is named controls.json and included in the main bundle.
    3.    Run the app to see the dynamically generated UI.
    
    
Example JSON

[
    {
        "control": "label",
        "text": "Hello, World!",
        "fontWeight": "bold",
        "alignment": "center",
        "color": "#FF0000"
    },
    {
        "control": "textbox",
        "text": "Enter your text here",
        "backgroundColor": "#DDDDDD",
        "textColor": "#000000"
    },
    {
        "control": "button",
        "text": "Submit"
    }
]

Extensions

    •    UIColor Extension: Converts hex color strings to UIColor.
    •    UIImageView Extension: Adds asynchronous image loading capability to UIImageView.
