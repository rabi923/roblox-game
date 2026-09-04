r"""
Hotel Hermes - Art Deco Elevator 3D Asset Generator
Generates the ornate brass elevator cage, sliding double doors,
buttons panel, mirror, and floor indicator in Blender,
exporting strictly to: assets/blender/elevator_cage.fbx
"""

import bpy
import os
import math

PROJECT_DIR = r"C:\Users\abish\OneDrive\Desktop\roblox game hermes"
OUTPUT_DIR = os.path.join(PROJECT_DIR, "assets", "blender")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for block in bpy.data.meshes:
        bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        bpy.data.materials.remove(block)

def create_material(name, color, roughness=0.3, metallic=0.85):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*color, 1.0)
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
    return mat

def export_fbx(filename):
    filepath = os.path.join(OUTPUT_DIR, filename)
    bpy.ops.export_scene.fbx(
        filepath=filepath,
        use_selection=False,
        apply_scale_options='FBX_SCALE_ALL',
        object_types={'MESH'},
        bake_space_transform=True
    )
    print(f"Exported: {filepath} ({os.path.getsize(filepath)} bytes)")

def build_elevator_cage():
    clear_scene()
    mat_brass = create_material("ArtDecoBrass", (0.75, 0.60, 0.22), roughness=0.25, metallic=0.9)
    mat_floor = create_material("CheckerMarble", (0.15, 0.15, 0.18), roughness=0.15, metallic=0.0)
    mat_mirror = create_material("ElevatorMirror", (0.9, 0.95, 1.0), roughness=0.05, metallic=0.95)
    mat_indicator = create_material("DialIndicator", (0.9, 0.2, 0.1), roughness=0.1, metallic=0.2)

    # 1. Floor Platform (10 x 10 studs)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.25))
    floor = bpy.context.active_object
    floor.name = "ElevatorFloor"
    floor.scale = (10.0, 10.0, 0.5)
    floor.data.materials.append(mat_floor)

    # 2. Ceiling with Art Deco Dome (10 x 10 studs, height 12)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 12.25))
    ceil = bpy.context.active_object
    ceil.name = "ElevatorCeiling"
    ceil.scale = (10.0, 10.0, 0.5)
    ceil.data.materials.append(mat_brass)

    # 3. Back Wall with Mirror (Y = -5)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -4.8, 6.0))
    wall_back = bpy.context.active_object
    wall_back.name = "ElevatorWall_Back"
    wall_back.scale = (9.8, 0.4, 11.5)
    wall_back.data.materials.append(mat_brass)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -4.5, 6.5))
    mirror = bpy.context.active_object
    mirror.name = "ElevatorMirror"
    mirror.scale = (7.0, 0.1, 8.0)
    mirror.data.materials.append(mat_mirror)

    # 4. Left & Right Brass Grille Walls (X = -5, +5)
    for x_pos, name in [(-4.8, "ElevatorWall_Left"), (4.8, "ElevatorWall_Right")]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x_pos, 0, 6.0))
        wall = bpy.context.active_object
        wall.name = name
        wall.scale = (0.4, 9.8, 11.5)
        wall.data.materials.append(mat_brass)

    # 5. Art Deco Cage Grille Bars
    for y_bar in [-3, -1.5, 0, 1.5, 3]:
        for x_side in [-4.85, 4.85]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=11.5, location=(x_side, y_bar, 6.0))
            bar = bpy.context.active_object
            bar.name = f"GrilleBar_{x_side}_{y_bar}"
            bar.data.materials.append(mat_brass)

    # 6. Front Wall Frame & Doorway (Y = 5)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-3.8, 4.8, 6.0))
    frame_l = bpy.context.active_object
    frame_l.name = "FrontFrame_Left"
    frame_l.scale = (2.2, 0.4, 11.5)
    frame_l.data.materials.append(mat_brass)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(3.8, 4.8, 6.0))
    frame_r = bpy.context.active_object
    frame_r.name = "FrontFrame_Right"
    frame_r.scale = (2.2, 0.4, 11.5)
    frame_r.data.materials.append(mat_brass)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 4.8, 11.0))
    frame_top = bpy.context.active_object
    frame_top.name = "FrontFrame_Top"
    frame_top.scale = (5.6, 0.4, 2.0)
    frame_top.data.materials.append(mat_brass)

    # 7. Sliding Double Doors (Independent parts for Tween animation)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.35, 4.6, 5.0))
    door_l = bpy.context.active_object
    door_l.name = "SlidingDoor_Left"
    door_l.scale = (2.6, 0.2, 10.0)
    door_l.data.materials.append(mat_brass)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(1.35, 4.6, 5.0))
    door_r = bpy.context.active_object
    door_r.name = "SlidingDoor_Right"
    door_r.scale = (2.6, 0.2, 10.0)
    door_r.data.materials.append(mat_brass)

    # 8. Button Panel & Floor Indicator Dial
    bpy.ops.mesh.primitive_cube_add(size=1, location=(4.4, 2.0, 5.5))
    panel = bpy.context.active_object
    panel.name = "ElevatorButtonPanel"
    panel.scale = (0.3, 1.4, 3.5)
    panel.data.materials.append(mat_brass)

    bpy.ops.mesh.primitive_cylinder_add(radius=1.0, depth=0.2, location=(0, 4.9, 11.0))
    dial = bpy.context.active_object
    dial.name = "FloorIndicatorDial"
    dial.rotation_euler = (math.radians(90), 0, 0)
    dial.data.materials.append(mat_indicator)

    # 9. "Ding" Bell Dome
    bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=0.3, location=(2.5, 4.9, 11.0))
    bell = bpy.context.active_object
    bell.name = "ElevatorDingBell"
    bell.rotation_euler = (math.radians(90), 0, 0)
    bell.data.materials.append(mat_brass)

    export_fbx("elevator_cage.fbx")

def main():
    print(f"Generating Art Deco Elevator Model in: {OUTPUT_DIR}")
    build_elevator_cage()
    print("Art Deco Elevator model exported successfully!")

if __name__ == "__main__":
    main()
