# Assets Guide - The Stamp Office

## 📁 Folder Structure

```
assets/
├── models/          # 3D models (.glb, .gltf, .blend)
├── textures/        # Texture files (.png, .jpg)
└── materials/       # Godot material resources (.tres)
```

## 🎨 Art Style Reference: "Phở Anh Hai" Low-Poly

Target aesthetic:
- **Low-poly with soft edges** - Beveled corners, not sharp boxes
- **Flat shading** with subtle gradients
- **Warm office lighting** - Fluorescent hum vibe
- **Props and clutter** - Lived-in feel
- **Muted color palette** - Beige, brown, gray, green accents

---

## 🛠️ Recommended Free Asset Sources

### Low-Poly Furniture
1. **Quaternius** (CC0): https://quaternius.com/
   - Ultimate Buildings Pack
   - Furniture Pack
   
2. **Kenney** (CC0): https://kenney.nl/assets
   - Furniture Kit
   - City Kit (offices)

3. **Poly Pizza** (CC0): https://poly.pizza/
   - Search: "office", "desk", "chair"

4. **Sketchfab** (Filter by free/CC): https://sketchfab.com/
   - Search: "low poly office"

### Textures
1. **Poly Haven** (CC0): https://polyhaven.com/textures
2. **ambientCG** (CC0): https://ambientcg.com/

---

## 📐 Model Requirements

### Scale
- **1 unit = 1 meter** in Godot
- Standard door height: 2.2m
- Desk height: 0.75m
- Chair seat: 0.45m

### Polycount Guidelines (per object)
| Object Type | Max Tris |
|-------------|----------|
| Small props (cup, stamp) | 50-200 |
| Furniture (chair, lamp) | 200-800 |
| Large furniture (desk, cabinet) | 500-1500 |
| Environment (wall, floor) | 100-500 |

### Format
- **Preferred**: `.glb` (Binary glTF) - smallest file size
- **Alternative**: `.gltf`, `.blend`, `.fbx`

---

## 🎯 Priority Objects to Replace

### High Priority (Player sees constantly)
1. ✅ **Player's Desk** - Needs drawers, monitor, keyboard, papers
2. ✅ **Office Chair** - Needs wheels, armrests, realistic shape
3. ✅ **Filing Cabinets** - Drawer detail, handles
4. ✅ **Clerk NPC** - Stylized human mesh

### Medium Priority
5. **Reception Counter** - Curved front, computer
6. **Waiting Chairs** - Row seating
7. **Plants** - Low-poly leaves, not spheres
8. **Coffee Table** - Magazines, cups

### Low Priority (Background)
9. **Wall decorations** - Posters, clocks
10. **Ceiling fixtures** - Fluorescent lights
11. **Floor tiles** - Pattern variation

---

## 🔧 Import Settings (Godot 4)

When importing `.glb` files:

1. **Select the file in FileSystem**
2. **Import tab settings:**
   ```
   Root Type: StaticBody3D (for collision)
   Root Name: <ObjectName>
   
   Meshes:
   - Generate Lightmap UV2: On
   - Shadow Meshes: On
   
   Materials:
   - External Files: On (for editing)
   ```

3. **Re-import** (click Reimport button)

---

## 🎨 Material Setup

### Base Office Materials

```gdshader
# Desk Wood
albedo_color = Color(0.55, 0.4, 0.28)
metallic = 0.1
roughness = 0.6

# Metal Cabinet
albedo_color = Color(0.6, 0.62, 0.65)
metallic = 0.7
roughness = 0.3

# Fabric Chair
albedo_color = Color(0.25, 0.28, 0.32)
metallic = 0.0
roughness = 0.95

# Paper/Documents
albedo_color = Color(0.98, 0.96, 0.92)
metallic = 0.0
roughness = 0.95
```

---

## 🚀 Quick Start: Blender to Godot

1. **Create in Blender** (or download model)
2. **Apply transforms**: Ctrl+A → All Transforms
3. **Check scale**: Should match real-world meters
4. **Export**: File → Export → glTF 2.0 (.glb)
   - Format: glTF Binary (.glb)
   - Include: Selected Objects only
   - Transform: +Y Up
5. **Drag .glb** into `game/assets/models/`
6. **Use in scene**: Drag into 3D viewport

---

## 📝 Asset Naming Convention

```
[category]_[name]_[variant].glb

Examples:
- furniture_desk_main.glb
- furniture_chair_office_01.glb
- prop_mug_coffee.glb
- prop_papers_stack.glb
- decor_plant_potted_large.glb
- arch_wall_segment.glb
```

---

## ✅ Checklist for New Assets

- [ ] Correct scale (1 unit = 1 meter)
- [ ] Applied transforms in Blender
- [ ] Low-poly count within guidelines
- [ ] Proper material names (for Godot identification)
- [ ] Collision shape if needed
- [ ] Follows naming convention
