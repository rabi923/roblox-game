r"""
Hotel Hermes - Lobby 3D Asset Generator
Generates the grand vintage hotel lobby models in Blender,
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

def create_material(name, color, roughness=0.6, metallic=0.0):
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
# 1. GRAND RECEPTION DESK & NEON SIGN
# -----------------------------------------------------------------------------
def build_reception_desk():
    clear_scene()
    mat_wood = create_material("MahoganyDesk", (0.15, 0.08, 0.05), roughness=0.4)
    mat_brass = create_material("HotelBrass", (0.75, 0.6, 0.2), roughness=0.25, metallic=0.9)
    mat_neon = create_material("NeonSign", (0.9, 0.3, 0.1), roughness=0.1)

    # Curved Grand Counter (Width 16, Depth 5, Height 3.6)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.8))
    counter = bpy.context.active_object
    counter.name = "ReceptionCounter"
    counter.scale = (16.0, 4.5, 3.6)
    counter.data.materials.append(mat_wood)

    # Countertop Trim
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 3.7))
    top = bpy.context.active_object
    top.name = "CountertopTrim"
    top.scale = (16.4, 4.8, 0.3)
    top.data.materials.append(mat_brass)

    # Brass Check-In Service Bell
    bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=0.3, location=(0, -1.2, 3.9))
    bell = bpy.context.active_object
    bell.name = "CheckInBell"
    bell.data.materials.append(mat_brass)

    # Back Wall Key Rack
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 4.0, 5.0))
    rack = bpy.context.active_object
    rack.name = "KeyCubbyRack"
    rack.scale = (14.0, 0.8, 6.0)
    rack.data.materials.append(mat_wood)

    # "HOTEL HERMES" Sign Plaque
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 3.5, 8.5))
    sign = bpy.context.active_object
    sign.name = "HotelHermesSignPlaque"
    sign.scale = (12.0, 0.4, 2.0)
    sign.data.materials.append(mat_neon)

    export_fbx("lobby_reception_desk.fbx")

# -----------------------------------------------------------------------------
# 2. GRAND STAIRCASE & CHANDELIER
# -----------------------------------------------------------------------------
def build_staircase_and_chandelier():
    clear_scene()
    mat_marble = create_material("DarkMarble", (0.12, 0.12, 0.14), roughness=0.2)
    mat_carpet = create_material("VelvetRedRunner", (0.5, 0.05, 0.05), roughness=0.9)
    mat_brass = create_material("AntiqueGoldBrass", (0.7, 0.55, 0.2), roughness=0.3, metallic=0.85)

    # Grand Staircase (12 Steps)
    for i in range(12):
        z = i * 0.8
        y = i * 1.2
        # Marble Step
        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, y, z + 0.4))
        step = bpy.context.active_object
        step.name = f"Step_{i+1}"
        step.scale = (14.0, 1.4, 0.8)
        step.data.materials.append(mat_marble)

        # Red Carpet Runner in Center
        bpy.ops.mesh.primitive_cube_add(size=1, location=(0, y, z + 0.82))
        runner = bpy.context.active_object
        runner.name = f"Runner_{i+1}"
        runner.scale = (6.0, 1.35, 0.05)
        runner.data.materials.append(mat_carpet)

    # Ornate Grand Chandelier
    bpy.ops.mesh.primitive_cylinder_add(radius=3.0, depth=0.4, location=(0, 0, 18.0))
    tier1 = bpy.context.active_object
    tier1.name = "Chandelier_Tier1"
    tier1.data.materials.append(mat_brass)

    bpy.ops.mesh.primitive_cylinder_add(radius=1.8, depth=0.4, location=(0, 0, 16.5))
    tier2 = bpy.context.active_object
    tier2.name = "Chandelier_Tier2"
    tier2.data.materials.append(mat_brass)

    export_fbx("lobby_staircase_chandelier.fbx")

# -----------------------------------------------------------------------------
# 3. WAITING LOUNGE & ROOM SERVICE WHEEL
# -----------------------------------------------------------------------------
def build_lounge_and_wheel():
    clear_scene()
    mat_leather = create_material("BurgundyLeather", (0.3, 0.08, 0.08), roughness=0.5)
    mat_wood = create_material("DarkWalnut", (0.14, 0.08, 0.04), roughness=0.4)
    mat_wheel = create_material("CarnivalWheel", (0.8, 0.6, 0.1), roughness=0.3, metallic=0.5)

    # Vintage Armchair
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-6, 0, 1.5))
    seat = bpy.context.active_object
    seat.name = "Armchair_Seat"
    seat.scale = (3.2, 3.2, 1.2)
    seat.data.materials.append(mat_leather)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(-6, 1.4, 3.0))
    back = bpy.context.active_object
    back.name = "Armchair_Back"
    back.scale = (3.2, 0.8, 2.5)
    back.data.materials.append(mat_leather)

    # Coffee Table
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.0))
    table = bpy.context.active_object
    table.name = "CoffeeTable"
    table.scale = (5.0, 3.0, 1.4)
    table.data.materials.append(mat_wood)

    # Daily Room Service Wheel (Vertical spin wheel)
    bpy.ops.mesh.primitive_cylinder_add(radius=2.5, depth=0.4, location=(8, 0, 4.5))
    wheel = bpy.context.active_object
    wheel.name = "RoomServiceWheel"
    wheel.rotation_euler = (math.radians(90), 0, 0)
    wheel.data.materials.append(mat_wheel)

    # Wheel Stand Pedestal
    bpy.ops.mesh.primitive_cube_add(size=1, location=(8, 0, 2.0))
    stand = bpy.context.active_object
    stand.name = "WheelStand"
    stand.scale = (1.2, 1.2, 4.0)
    stand.data.materials.append(mat_wood)

    export_fbx("lobby_lounge_wheel.fbx")

def main():
    print(f"Generating Lobby 3D models in: {OUTPUT_DIR}")
    build_reception_desk()
    build_staircase_and_chandelier()
    build_lounge_and_wheel()
    print("All Lobby 3D models exported successfully!")

if __name__ == "__main__":
    main()
