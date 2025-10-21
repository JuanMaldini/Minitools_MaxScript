# Minitools_MaxScript

A collection of custom MaxScript tools for Autodesk 3ds Max, designed to simplify common modeling and animation tasks.

## Measurer Tool

The first tool in the sequence: a simple measurer for calculating the total distance traveled by an animated object during its animation.

### Features
- Measures the approximate path length by sampling the object's position every frame over the animation range.
- Works with any type of position animation (keyframes, constraints, paths, etc.).
- Displays the total distance in a message box.

### Installation
1. Open `Measurer.ms` in 3ds Max's MaxScript Editor and run it (or evaluate it).
2. Go to **Customize > Customize User Interface > Toolbars**.
3. In the "Category" dropdown, select "0_Minitools".
4. Drag the "Measurer" item to your desired toolbar.
5. Click OK to save.

### Usage
- **Preselected Object**: Select an object in the scene, then click the Measurer toolbar button. The dialog opens and immediately measures the selected object's distance.
- **Pick Object**: In the open dialog, click the "Pick Object" button to select a different object and measure its distance.

### Requirements
- 3ds Max (any recent version supporting MaxScript).
- The object must have some position animation over the scene's animation range.

### Future Tools
This is the start of a sequence of basic tools. More functions will be added to expand capabilities.