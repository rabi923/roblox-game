r"""
Hotel Hermes - Modular 3D Asset Generator
Generates modular architectural segments and horror hotel props in Blender,
exporting all .fbx files strictly into the project directory:
assets/blender/
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

def create_material(name, color, roughness=0.7, metallic=0.0):
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
# 1. HALLWAY SEGMENTS
# -----------------------------------------------------------------------------
def build_hallway_straight():
    clear_scene()
    mat_wood = create_material("DarkWood", (0.15, 0.10, 0.07))
    mat_wall = create_material("PeelingWallpaper", (0.35, 0.30, 0.25))
    mat_brass = create_material("AgedBrass", (0.6, 0.45, 0.2), roughness=0.3, metallic=0.8)

    # Floor (32 x 10)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    floor = bpy.context.active_object
    floor.name = "Floor"
    floor.scale = (32, 10, 0.5)
    floor.data.materials.append(mat_wood)

    # Ceiling (32 x 10)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 16))
    ceil = bpy.context.active_object
    ceil.name = "Ceiling"
    ceil.scale = (32, 10, 0.5)
    ceil.data.materials.append(mat_wall)

    # Left Wall (32 x 16)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -5, 8))
    wall_left = bpy.context.active_object
    wall_left.name = "Wall_Left"
    wall_left.scale = (32, 0.6, 16)
    wall_left.data.materials.append(mat_wall)

    # Right Wall (32 x 16)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 5, 8))
    wall_right = bpy.context.active_object
    wall_right.name = "Wall_Right"
    wall_right.scale = (32, 0.6, 16)
    wall_right.data.materials.append(mat_wall)

    # Wall Sconces (Lights)
    for x in [-8, 8]:
        for y in [-4.7, 4.7]:
            bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, 10))
            sconce = bpy.context.active_object
            sconce.name = f"Sconce_{x}_{y}"
            sconce.scale = (0.6, 0.6, 1.2)
            sconce.data.materials.append(mat_brass)

    export_fbx("hallway_straight.fbx")

def build_hallway_lturn():
    clear_scene()
    mat_wood = create_material("DarkWood", (0.15, 0.10, 0.07))
    mat_wall = create_material("PeelingWallpaper", (0.35, 0.30, 0.25))

    # Corner Floor
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    f = bpy.context.active_object
    f.name = "Floor"
    f.scale = (16, 16, 0.5)
    f.data.materials.append(mat_wood)

    # Outer Wall North
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 8, 8))
    w1 = bpy.context.active_object
    w1.name = "Wall_Outer_North"
    w1.scale = (16, 0.6, 16)
    w1.data.materials.append(mat_wall)

    # Outer Wall East
    bpy.ops.mesh.primitive_cube_add(size=1, location=(8, 0, 8))
    w2 = bpy.context.active_object
    w2.name = "Wall_Outer_East"
    w2.scale = (0.6, 16, 16)
    w2.data.materials.append(mat_wall)

    export_fbx("hallway_lturn.fbx")

def build_hallway_tjunction():
    clear_scene()
    mat_wood = create_material("DarkWood", (0.15, 0.10, 0.07))
    mat_wall = create_material("PeelingWallpaper", (0.35, 0.30, 0.25))

    # Main Floor
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    f = bpy.context.active_object
    f.name = "Floor"
    f.scale = (24, 24, 0.5)
    f.data.materials.append(mat_wood)

    # Back Wall
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 12, 8))
    w = bpy.context.active_object
    w.name = "Wall_Back"
    w.scale = (24, 0.6, 16)
    w.data.materials.append(mat_wall)

    export_fbx("hallway_tjunction.fbx")

def build_hallway_deadend():
    clear_scene()
    mat_wood = create_material("DarkWood", (0.15, 0.10, 0.07))
    mat_wall = create_material("PeelingWallpaper", (0.35, 0.30, 0.25))

    # Floor (16 x 10)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    f = bpy.context.active_object
    f.name = "Floor"
    f.scale = (16, 10, 0.5)
    f.data.materials.append(mat_wood)

    # End Wall
    bpy.ops.mesh.primitive_cube_add(size=1, location=(8, 0, 8))
    w_end = bpy.context.active_object
    w_end.name = "Wall_DeadEnd"
    w_end.scale = (0.6, 10, 16)
    w_end.data.materials.append(mat_wall)

    # Boarded Up Window
    bpy.ops.mesh.primitive_cube_add(size=1, location=(7.6, 0, 9))
    win = bpy.context.active_object
    win.name = "BoardedWindow"
    win.scale = (0.4, 4, 6)
    win.data.materials.append(mat_wood)

    export_fbx("hallway_deadend.fbx")

# -----------------------------------------------------------------------------
# 2. GUEST ROOM PROPS
# -----------------------------------------------------------------------------
def build_prop_bed():
    clear_scene()
    mat_frame = create_material("DarkMahogany", (0.12, 0.06, 0.04))
    mat_mattress = create_material("DirtyLinen", (0.7, 0.68, 0.62))
    mat_pillow = create_material("PillowLinen", (0.8, 0.78, 0.72))

    # Bed Frame (Elevated for crawlspace hiding)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.2))
    frame = bpy.context.active_object
    frame.name = "BedFrame"
    frame.scale = (7, 5, 0.4)
    frame.data.materials.append(mat_frame)

    # 4 Legs (Leaving hollow crawlspace underneath)
    for x in [-3.2, 3.2]:
        for y in [-2.2, 2.2]:
            bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, 0.6))
            leg = bpy.context.active_object
            leg.name = f"BedLeg_{x}_{y}"
            leg.scale = (0.4, 0.4, 1.2)
            leg.data.materials.append(mat_frame)

    # Headboard
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-3.4, 0, 2.8))
    head = bpy.context.active_object
    head.name = "Headboard"
    head.scale = (0.4, 5.2, 3.2)
    head.data.materials.append(mat_frame)

    # Mattress
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0.2, 0, 1.8))
    matt = bpy.context.active_object
    matt.name = "Mattress"
    matt.scale = (6.6, 4.6, 0.9)
    matt.data.materials.append(mat_mattress)

    # Pillows
    for y in [-1.3, 1.3]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(-2.4, y, 2.4))
        pillow = bpy.context.active_object
        pillow.name = f"Pillow_{y}"
        pillow.scale = (1.4, 1.8, 0.4)
        pillow.data.materials.append(mat_pillow)

    export_fbx("prop_bed.fbx")

def build_prop_wardrobe():
    clear_scene()
    mat_wood = create_material("OldCabinetOak", (0.16, 0.09, 0.05))
    mat_brass = create_material("AgedBrass", (0.6, 0.45, 0.2), roughness=0.3, metallic=0.8)

    # Wardrobe Outer Shell (Hollow interior for player hiding spot)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 4.5))
    body = bpy.context.active_object
    body.name = "Wardrobe_Body"
    body.scale = (3.5, 5.0, 9.0)
    body.data.materials.append(mat_wood)

    # Double Doors with Handles
    for y, side in [(-1.25, "Left"), (1.25, "Right")]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(1.8, y, 4.5))
        door = bpy.context.active_object
        door.name = f"Door_{side}"
        door.scale = (0.2, 2.3, 8.4)
        door.data.materials.append(mat_wood)

        # Handle
        bpy.ops.mesh.primitive_cube_add(size=1, location=(2.0, y * 0.3, 4.5))
        h = bpy.context.active_object
        h.name = f"Handle_{side}"
        h.scale = (0.15, 0.15, 0.6)
        h.data.materials.append(mat_brass)

    export_fbx("prop_wardrobe.fbx")

def build_prop_desk():
    clear_scene()
    mat_wood = create_material("DeskMahogany", (0.18, 0.11, 0.07))
    mat_brass = create_material("AgedBrass", (0.6, 0.45, 0.2), roughness=0.3, metallic=0.8)

    # Desktop Surface
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 3.0))
    top = bpy.context.active_object
    top.name = "Desktop"
    top.scale = (3.5, 6.0, 0.4)
    top.data.materials.append(mat_wood)

    # Left & Right Pedestal Drawers (Loot spawn targets)
    for y in [-2.2, 2.2]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, y, 1.5))
        pedestal = bpy.context.active_object
        pedestal.name = f"DrawerBlock_{y}"
        pedestal.scale = (3.2, 1.4, 2.8)
        pedestal.data.materials.append(mat_wood)

        # Drawer Handle
        bpy.ops.mesh.primitive_cube_add(size=1, location=(1.7, y, 1.5))
        handle = bpy.context.active_object
        handle.name = f"DrawerHandle_{y}"
        handle.scale = (0.1, 0.6, 0.2)
        handle.data.materials.append(mat_brass)

    export_fbx("prop_desk.fbx")

# -----------------------------------------------------------------------------
# 3. BATHROOM, KITCHEN & SECRET ROOM PROPS
# -----------------------------------------------------------------------------
def build_prop_bathroom():
    clear_scene()
    mat_porcelain = create_material("WhitePorcelain", (0.85, 0.85, 0.83), roughness=0.1)
    mat_chrome = create_material("ChromeFaucet", (0.7, 0.7, 0.75), roughness=0.2, metallic=0.9)
    mat_mirror = create_material("ReflectiveGlass", (0.9, 0.95, 1.0), roughness=0.05, metallic=0.95)

    # Bathtub (Length 6, Width 3, Height 2.2)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.1))
    tub = bpy.context.active_object
    tub.name = "Bathtub"
    tub.scale = (6.0, 3.0, 2.2)
    tub.data.materials.append(mat_porcelain)

    # Toilet Pedestal & Tank
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-4, 3, 1.2))
    toilet = bpy.context.active_object
    toilet.name = "Toilet"
    toilet.scale = (1.8, 1.4, 2.2)
    toilet.data.materials.append(mat_porcelain)

    # Medicine Cabinet with Mirror Door (Loot spawn)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 4, 5.5))
    med = bpy.context.active_object
    med.name = "MedicineCabinet"
    med.scale = (2.4, 0.6, 3.2)
    med.data.materials.append(mat_mirror)

    export_fbx("prop_bathroom_fixtures.fbx")

def build_prop_kitchen():
    clear_scene()
    mat_steel = create_material("StainlessSteel", (0.6, 0.6, 0.65), roughness=0.25, metallic=0.85)
    mat_glass = create_material("BottleGlass", (0.1, 0.4, 0.2), roughness=0.1)

    # Service Prep Counter
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.8))
    counter = bpy.context.active_object
    counter.name = "KitchenCounter"
    counter.scale = (8.0, 3.0, 3.4)
    counter.data.materials.append(mat_steel)

    # Vintage Refrigerator
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-6, 0, 3.5))
    fridge = bpy.context.active_object
    fridge.name = "VintageFridge"
    fridge.scale = (3.2, 3.0, 7.0)
    fridge.data.materials.append(mat_steel)

    # Throwable Distraction Bottles
    for i, x in enumerate([-1.5, 0, 1.5]):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=0.8, location=(x, 0, 3.8))
        bottle = bpy.context.active_object
        bottle.name = f"DistractionBottle_{i+1}"
        bottle.data.materials.append(mat_glass)

    export_fbx("prop_kitchen_service.fbx")

def build_prop_secret_room():
    clear_scene()
    mat_wood = create_material("AncientOak", (0.14, 0.08, 0.05))
    mat_gold = create_material("AntiqueGold", (0.8, 0.65, 0.2), roughness=0.3, metallic=0.85)

    # Revolving Secret Bookshelf Door
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 4.5))
    shelf = bpy.context.active_object
    shelf.name = "SecretBookshelf"
    shelf.scale = (1.5, 5.0, 9.0)
    shelf.data.materials.append(mat_wood)

    # Lore Pedestal
    bpy.ops.mesh.primitive_cylinder_add(radius=0.8, depth=3.2, location=(4, 0, 1.6))
    ped = bpy.context.active_object
    ped.name = "LorePedestal"
    ped.data.materials.append(mat_wood)

    # Ornate Loot Chest
    bpy.ops.mesh.primitive_cube_add(size=1, location=(4, 4, 1.0))
    chest = bpy.context.active_object
    chest.name = "TreasureChest"
    chest.scale = (2.2, 1.6, 1.8)
    chest.data.materials.append(mat_gold)

    export_fbx("prop_secret_room.fbx")

def main():
    print(f"Starting Blender 3D asset generation in: {OUTPUT_DIR}")
    build_hallway_straight()
    build_hallway_lturn()
    build_hallway_tjunction()
    build_hallway_deadend()
    build_prop_bed()
    build_prop_wardrobe()
    build_prop_desk()
    build_prop_bathroom()
    build_prop_kitchen()
    build_prop_secret_room()
    print("All HE-03 3D models generated and exported successfully!")

if __name__ == "__main__":
    main()
