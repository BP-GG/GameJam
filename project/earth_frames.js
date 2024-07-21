// Set the number of frames and increment
var totalFrames = 73; // 0 to 180, then -180 to 0 (5 degrees per step)
var increment = 5;
var outputFolder = "C:/Godot/GeneralAssets/GameJam/EARTH";

// Get the active document
var doc = app.activeDocument;

// Ensure the document has a layer named "Layer 1"
var layer = doc.layers[0]; // Adjust if necessary

// Get the 3D object path
var path = layer.pathItems[0];

// Function to apply 3D rotation
function apply3DRotation(item, angle) {
    // Check if the 3D effect is already applied
    var has3DEffect = false;
    for (var i = 0; i < item.graphicStyles.length; i++) {
        if (item.graphicStyles[i].name == "3D") {
            has3DEffect = true;
            break;
        }
    }

    if (!has3DEffect) {
        // Apply the 3D effect if not already applied
        app.executeMenuCommand('Live 3D Extrude & Bevel');
    }

    // Access the 3D effect properties
    var appearance = item.appearanceAttributes;
    for (var j = 0; j < appearance.length; j++) {
        var attr = appearance[j];
        if (attr.typename === 'LiveEffect') {
            var options = new XML(attr.effect.parameters.toXMLString());
            options.rotateY = angle;
            attr.effect.parameters = options;
            break;
        }
    }
}

// Iterate through the frames
for (var i = 0; i < totalFrames; i++) {
    // Calculate the rotation angle
    var angle = i * increment;
    if (angle > 180) {
        angle -= 360;
    }

    // Apply the Y rotation
    apply3DRotation(path, angle);

    // Update the document to reflect the new rotation
    app.redraw();

    // Set the file name for export
    var fileName = "frame_" + (i + 1) + ".png";
    var file = new File(outputFolder + "/" + fileName);

    // Set the export options
    var exportOptions = new ExportOptionsPNG24();
    exportOptions.transparency = true;

    // Export the frame
    doc.exportFile(file, ExportType.PNG24, exportOptions);
}

// Reset rotation to 0
apply3DRotation(path, 0);
app.redraw();

alert("Export complete!");
