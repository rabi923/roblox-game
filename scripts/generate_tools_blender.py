r"""
Hotel Hermes - Tool & Item Models 3D Asset Generator
Generates flashlight, keycards (red, blue, green), safe code note,
electrical fuse, ritual candle, wine bottle, and coffee mug in Blender,
exporting strictly to: assets/blender/
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

def create_material(name, color, roughness=0.5, metallic=0.0):
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

# -----------------------------------------------------------------------------
# 1. HANDHELD FLASHLIGHT
# -----------------------------------------------------------------------------
def build_flashlight():
    clear_scene()
    mat_metal = create_material("AgedMetal", (0.15, 0.16, 0.18), roughness=0.3, metallic=0.8)
    mat_rubber = create_material("RubberGrip", (0.05, 0.05, 0.05), roughness=0.8, metallic=0.0)
    mat_glass = create_material("LensGlass", (0.8, 0.9, 1.0), roughness=0.1, metallic=0.9)
    mat_switch = create_material("RedSwitch", (0.8, 0.1, 0.1), roughness=0.4, metallic=0.0)

    # Flashlight Handle Body (Length 1.2, Radius 0.18)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.18, depth=1.0, location=(0, 0, 0.5))
    handle = bpy.context.active_object
    handle.name = "Flashlight_Handle"
    handle.data.materials.append(mat_metal)

    # Grip Ribs
    bpy.ops.mesh.primitive_cylinder_add(radius=0.19, depth=0.6, location=(0, 0, 0.45))
    grip = bpy.context.active_object
    grip.name = "Flashlight_Grip"
    grip.data.materials.append(mat_rubber)

    # Beveled Head (Radius 0.28, Depth 0.35)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.28, depth=0.35, location=(0, 0, 1.15))
    head = bpy.context.active_object
    head.name = "Flashlight_Head"
    head.data.materials.append(mat_metal)

    # Front Glass Lens
    bpy.ops.mesh.primitive_cylinder_add(radius=0.25, depth=0.05, location=(0, 0, 1.33))
    lens = bpy.context.active_object
    lens.name = "Flashlight_Lens"
    lens.data.materials.append(mat_glass)

    # Toggle Switch
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.2, 0.7))
    switch = bpy.context.active_object
    switch.name = "Flashlight_Switch"
    switch.scale = (0.08, 0.06, 0.15)
    switch.data.materials.append(mat_switch)

    export_fbx("tool_flashlight.fbx")

# -----------------------------------------------------------------------------
# 2. KEY ITEMS: KEYCARDS, CODE NOTE, FUSE, CANDLE
# -----------------------------------------------------------------------------
def build_key_items():
    clear_scene()
    mat_red = create_material("KeycardRed", (0.85, 0.15, 0.15), roughness=0.3)
    mat_blue = create_material("KeycardBlue", (0.15, 0.35, 0.85), roughness=0.3)
    mat_green = create_material("KeycardGreen", (0.15, 0.75, 0.25), roughness=0.3)
    mat_chip = create_material("GoldChip", (0.8, 0.65, 0.2), roughness=0.2, metallic=0.8)
    mat_paper = create_material("CrumpledPaper", (0.85, 0.82, 0.72), roughness=0.9)
    mat_copper = create_material("FuseCopper", (0.75, 0.45, 0.25), roughness=0.3, metallic=0.9)
    mat_glass = create_material("FuseGlass", (0.9, 0.95, 1.0), roughness=0.1, metallic=0.8)
    mat_wax = create_material("CandleWax", (0.9, 0.85, 0.7), roughness=0.6)

    # 1. Red Keycard
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.5, 0, 0.02))
    card_r = bpy.context.active_object
    card_r.name = "Keycard_Red"
    card_r.scale = (0.55, 0.85, 0.04)
    card_r.data.materials.append(mat_red)

    # 2. Blue Keycard
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.02))
    card_b = bpy.context.active_object
    card_b.name = "Keycard_Blue"
    card_b.scale = (0.55, 0.85, 0.04)
    card_b.data.materials.append(mat_blue)

    # 3. Green Keycard
    bpy.ops.mesh.primitive_cube_add(size=1, location=(1.5, 0, 0.02))
    card_g = bpy.context.active_object
    card_g.name = "Keycard_Green"
    card_g.scale = (0.55, 0.85, 0.04)
    card_g.data.materials.append(mat_green)

    # Chips on Keycards
    for x in [-1.5, 0, 1.5]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x, 0.15, 0.05))
        chip = bpy.context.active_object
        chip.name = f"Chip_{x}"
        chip.scale = (0.2, 0.2, 0.02)
        chip.data.materials.append(mat_chip)

    # 4. Safe Code Note (Folded / Crumpled Parchment)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.5, 2.0, 0.05))
    note = bpy.context.active_object
    note.name = "SafeCodeNote"
    note.scale = (0.7, 0.9, 0.08)
    note.rotation_euler = (0, 0, math.radians(12))
    note.data.materials.append(mat_paper)

    # 5. Electrical Fuse (Cylindrical Cartridge Fuse)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=0.6, location=(0, 2.0, 0.12))
    fuse_body = bpy.context.active_object
    fuse_body.name = "Fuse_Body"
    fuse_body.rotation_euler = (0, math.radians(90), 0)
    fuse_body.data.materials.append(mat_glass)

    # Fuse Endcaps
    for x in [-0.25, 0.25]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.13, depth=0.15, location=(x, 2.0, 0.12))
        cap = bpy.context.active_object
        cap.name = f"FuseCap_{x}"
        cap.rotation_euler = (0, math.radians(90), 0)
        cap.data.materials.append(mat_copper)

    # 6. Ritual Wax Candle
    bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=0.7, location=(1.5, 2.0, 0.35))
    candle = bpy.context.active_object
    candle.name = "RitualCandle"
    candle.data.materials.append(mat_wax)

    # Candle Wick
    bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=0.15, location=(1.5, 2.0, 0.75))
    wick = bpy.context.active_object
    wick.name = "CandleWick"
    wick.data.materials.append(mat_wax)

    export_fbx("tool_key_items.fbx")

# -----------------------------------------------------------------------------
# 3. THROWABLE ITEMS: WINE BOTTLE, COFFEE MUG
# -----------------------------------------------------------------------------
def build_throwables():
    clear_scene()
    mat_green_glass = create_material("GreenGlassBottle", (0.08, 0.25, 0.12), roughness=0.15, metallic=0.1)
    mat_label = create_material("VintageWineLabel", (0.85, 0.8, 0.7), roughness=0.8)
    mat_ceramic = create_material("HotelCeramicMug", (0.9, 0.9, 0.88), roughness=0.2)

    # 1. Vintage Wine Bottle (Base, Neck, Rim)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=0.7, location=(-0.8, 0, 0.35))
    b_body = bpy.context.active_object
    b_body.name = "WineBottle_Body"
    b_body.data.materials.append(mat_green_glass)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=0.45, location=(-0.8, 0, 0.85))
    b_neck = bpy.context.active_object
    b_neck.name = "WineBottle_Neck"
    b_neck.data.materials.append(mat_green_glass)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.225, depth=0.35, location=(-0.8, 0, 0.35))
    b_label = bpy.context.active_object
    b_label.name = "WineBottle_Label"
    b_label.data.materials.append(mat_label)

    # 2. Hotel Ceramic Coffee Mug
    bpy.ops.mesh.primitive_cylinder_add(radius=0.26, depth=0.55, location=(0.8, 0, 0.28))
    mug = bpy.context.active_object
    mug.name = "CoffeeMug_Body"
    mug.data.materials.append(mat_ceramic)

    # Mug Handle Loop
    bpy.ops.mesh.primitive_torus_add(major_radius=0.15, minor_radius=0.04, location=(1.1, 0, 0.28))
    handle = bpy.context.active_object
    handle.name = "CoffeeMug_Handle"
    handle.rotation_euler = (math.radians(90), 0, 0)
    handle.data.materials.append(mat_ceramic)

    export_fbx("tool_throwables.fbx")

def main():
    print(f"Generating Tools and Item Models in: {OUTPUT_DIR}")
    build_flashlight()
    build_key_items()
    build_throwables()
    print("All HE-06 tool and item 3D models exported successfully!")

if __name__ == "__main__":
    main()
