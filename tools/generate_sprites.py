#!/usr/bin/env python3
"""
CityBuilder Pixel-Art Generator (M16)
Generates all 32x32 sprites programmatically with Pillow.
Run from the project root: python3 tools/generate_sprites.py
"""
from PIL import Image, ImageDraw, ImageFilter
import os
import math

S = 32  # tile size
OUT_TILES  = "assets/tiles"
OUT_SOUNDS = "assets/sounds"  # not used here

os.makedirs(OUT_TILES, exist_ok=True)

# ─── Palette ────────────────────────────────────────────────────────────────

P = {
    # terrain
    "grass_light":  (106, 168, 79),
    "grass_mid":    (87,  147, 60),
    "grass_dark":   (69,  126, 42),
    "grass_detail": (132, 191, 106),
    "water_light":  (111, 168, 220),
    "water_mid":    (61,  133, 198),
    "water_dark":   (28,  69,  135),
    "water_foam":   (194, 224, 255),
    "hill_light":   (182, 149, 77),
    "hill_mid":     (153, 116, 49),
    "hill_dark":    (120, 88,  28),
    "hill_snow":    (245, 245, 255),
    "forest_trunk": (101, 67,  33),
    "forest_dark":  (22,  100, 20),
    "forest_mid":   (44,  130, 42),
    "forest_light": (78,  164, 76),
    # road / rail
    "road_base":    (100, 100, 100),
    "road_line":    (230, 200, 50),
    "road_edge":    (60,  60,  60),
    "rail_tie":     (120, 80,  40),
    "rail_metal":   (180, 180, 190),
    # buildings — residential
    "res_wall1":    (235, 200, 160),
    "res_wall2":    (210, 175, 130),
    "res_roof1":    (180, 60,  40),
    "res_roof2":    (140, 35,  20),
    "res_window":   (160, 220, 255),
    "res_door":     (100, 60,  30),
    # buildings — commercial
    "com_wall1":    (180, 200, 230),
    "com_wall2":    (140, 160, 200),
    "com_glass":    (200, 240, 255),
    "com_frame":    (80,  100, 140),
    "com_sign":     (255, 200, 50),
    # buildings — industrial
    "ind_wall1":    (180, 175, 165),
    "ind_wall2":    (140, 135, 125),
    "ind_roof1":    (120, 115, 105),
    "ind_chimney":  (70,  70,  70),
    "ind_smoke":    (200, 190, 180),
    # services
    "police_blue":  (30,  70,  160),
    "fire_red":     (200, 50,  30),
    "hospital_wh":  (240, 240, 240),
    "hospital_cross":(200, 30,  30),
    "school_yel":   (220, 180, 50),
    "uni_stone":    (180, 165, 130),
    # extraction
    "mine_dark":    (60,  55,  50),
    "mine_beam":    (100, 80,  50),
    "oil_metal":    (50,  50,  60),
    "oil_black":    (20,  20,  25),
    "saw_wood":     (160, 100, 50),
    "quarry_grey":  (130, 125, 120),
    # vehicles
    "car_body":     (220, 60,  60),
    "car_window":   (180, 220, 255),
    "car_wheel":    (30,  30,  30),
    "bus_yellow":   (255, 200, 50),
    "train_blue":   (40,  90,  170),
    "train_window": (200, 230, 255),
    # spaceport
    "space_conc":   (160, 160, 165),
    "space_steel":  (200, 205, 215),
    "rocket_body":  (230, 230, 235),
    "rocket_flame": (255, 120, 20),
    # power
    "power_coal":   (50,  45,  40),
    "power_solar":  (20,  40,  100),
    "power_solar_c":(220, 180, 30),
    "power_wind":   (200, 200, 200),
    "power_smoke":  (150, 140, 130),
    # UI overlay tints (semi-transparent base)
    "ui_bg":        (30,  30,  45),
    "ui_accent":    (80,  200, 120),
    # misc
    "transparent":  (0,   0,   0,  0),
    "black":        (0,   0,   0),
    "white":        (255, 255, 255),
    "shadow":       (0,   0,   0,  80),
}

def rgb(name):
    c = P[name]
    return c[:3]

def new(bg=None):
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    if bg:
        img.paste((*rgb(bg), 255), [0, 0, S, S])
    return img

def draw(img):
    return ImageDraw.Draw(img)

def save(img, path):
    img.save(os.path.join(OUT_TILES, path))
    print(f"  → {path}")

def pixel(d, x, y, name):
    d.point([(x, y)], fill=(*rgb(name), 255))

def rect(d, x0, y0, x1, y1, name, alpha=255):
    c = rgb(name)
    d.rectangle([x0, y0, x1, y1], fill=(*c, alpha))

def outline(d, x0, y0, x1, y1, col, width=1):
    d.rectangle([x0, y0, x1, y1], outline=(*rgb(col), 255), width=width)

def hline(d, y, x0, x1, name):
    d.line([(x0, y), (x1, y)], fill=(*rgb(name), 255))

def vline(d, x, y0, y1, name):
    d.line([(x, y0), (x, y1)], fill=(*rgb(name), 255))

# ─── Terrain Tiles ───────────────────────────────────────────────────────────

def tile_grass():
    img = new("grass_mid")
    d = draw(img)
    # subtle variation dots
    for pos in [(4,5),(10,2),(18,8),(25,4),(7,20),(15,15),(22,22),(28,10),(3,27),(20,29)]:
        d.point([pos], fill=(*rgb("grass_light"), 200))
    for pos in [(8,12),(16,6),(24,18),(6,25),(29,20)]:
        d.point([pos], fill=(*rgb("grass_dark"), 160))
    return img

def tile_water():
    img = new("water_mid")
    d = draw(img)
    # animated ripple lines (frame 0)
    for y in [6, 14, 22]:
        for x in range(0, S, 4):
            if (x // 4) % 2 == 0:
                hline(d, y, x, x+2, "water_light")
    for pos in [(2,3),(10,18),(20,8),(28,25),(5,28)]:
        d.ellipse([pos[0]-1, pos[1]-1, pos[0]+1, pos[1]+1],
                  fill=(*rgb("water_foam"), 120))
    return img

def tile_hill():
    img = new("hill_mid")
    d = draw(img)
    # draw a simple hill silhouette
    cx, cy = 16, 18
    for r in range(14, 0, -1):
        alpha = 255
        col = "hill_light" if r > 8 else "hill_dark"
        d.ellipse([cx-r, cy-r//2, cx+r, cy+r//2], fill=(*rgb(col), alpha))
    # snow cap
    d.ellipse([cx-4, cy-7, cx+4, cy-1], fill=(*rgb("hill_snow"), 220))
    return img

def tile_forest():
    img = new("grass_dark")
    d = draw(img)
    def tree(tx, ty, h):
        # trunk
        rect(d, tx-1, ty+h-4, tx+1, ty+h, "forest_trunk")
        # canopy layers
        for i, (w, y_off) in enumerate([(7,0),(9,3),(11,6)]):
            col = ["forest_dark","forest_mid","forest_light"][i % 3]
            d.polygon([(tx, ty-h//2+y_off-3), (tx-w//2, ty+y_off),
                        (tx+w//2, ty+y_off)], fill=(*rgb(col), 255))
    tree(8,  28, 14)
    tree(22, 26, 12)
    tree(15, 24, 16)
    return img

# ─── Road / Rail ────────────────────────────────────────────────────────────

def tile_road_h():
    img = new("road_base")
    d = draw(img)
    rect(d, 0, 10, S-1, 21, "road_base")
    rect(d, 0,  9, S-1,  9, "road_edge")
    rect(d, 0, 22, S-1, 22, "road_edge")
    # centre dashes
    for x in range(0, S, 8):
        rect(d, x, 15, x+4, 16, "road_line")
    return img

def tile_road_v():
    img = tile_road_h().rotate(90)
    return img

def tile_road_cross():
    img = new("road_base")
    d = draw(img)
    rect(d, 9,  0,  22, S-1, "road_base")
    rect(d, 0, 10, S-1,  21, "road_base")
    rect(d, 8,  0,   8, S-1, "road_edge")
    rect(d, 23, 0,  23, S-1, "road_edge")
    rect(d, 0,  9, S-1,  9,  "road_edge")
    rect(d, 0, 22, S-1, 22,  "road_edge")
    return img

def tile_rail_h():
    img = new("grass_mid")
    d = draw(img)
    # ties
    for x in range(2, S, 6):
        rect(d, x, 12, x+3, 20, "rail_tie")
    # rails
    hline(d, 13, 0, S-1, "rail_metal")
    hline(d, 14, 0, S-1, "rail_metal")
    hline(d, 18, 0, S-1, "rail_metal")
    hline(d, 19, 0, S-1, "rail_metal")
    return img

def tile_rail_v():
    return tile_rail_h().rotate(90)

# ─── Residential Buildings ──────────────────────────────────────────────────

def _base_ground(d):
    rect(d, 0, 26, S-1, S-1, "grass_mid")

def building_res_1():
    img = new()
    d = draw(img)
    _base_ground(d)
    # small house: 20x16, centred
    bx, by, bw, bh = 6, 10, 20, 16
    rect(d, bx, by, bx+bw, by+bh, "res_wall1")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # roof
    d.polygon([(bx-2, by), (bx+bw//2, by-7), (bx+bw+2, by)],
              fill=(*rgb("res_roof1"), 255))
    # windows
    for wx in [bx+3, bx+11]:
        rect(d, wx, by+5, wx+4, by+10, "res_window")
        outline(d, wx, by+5, wx+4, by+10, "black")
    # door
    rect(d, bx+8, by+9, bx+12, by+16, "res_door")
    return img

def building_res_2():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 4, 6, 24, 20
    rect(d, bx, by, bx+bw, by+bh, "res_wall1")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # second floor slightly darker
    rect(d, bx, by, bx+bw, by+bh//2, "res_wall2")
    # roof
    d.polygon([(bx-2, by), (bx+bw//2, by-8), (bx+bw+2, by)],
              fill=(*rgb("res_roof1"), 255))
    # windows 2 floors
    for wy in [by+3, by+13]:
        for wx in [bx+3, bx+11, bx+19]:
            if wx < bx+bw-2:
                rect(d, wx, wy, wx+4, wy+5, "res_window")
                outline(d, wx, wy, wx+4, wy+5, "black")
    rect(d, bx+10, by+13, bx+14, by+20, "res_door")
    return img

def building_res_3():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, bw = 5, 22
    floors = [(by_off, col) for by_off, col in [(3,"res_wall1"),(9,"res_wall2"),(15,"res_wall1"),(21,"res_wall2")]]
    for i, (by_off, col) in enumerate(floors):
        rect(d, bx, by_off, bx+bw, by_off+6, col)
    outline(d, bx, 3, bx+bw, 26, "black")
    # flat roof
    rect(d, bx-2, 1, bx+bw+2, 4, "res_roof2")
    # windows on each floor
    for row_y in [4, 10, 16, 22]:
        for wx in [bx+2, bx+8, bx+14, bx+20]:
            if wx < bx+bw-1:
                rect(d, wx, row_y, wx+3, row_y+4, "res_window")
    return img

# ─── Commercial Buildings ───────────────────────────────────────────────────

def building_com_1():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 5, 12, 22, 14
    rect(d, bx, by, bx+bw, by+bh, "com_wall1")
    # glass facade
    rect(d, bx+2, by+2, bx+bw-2, by+bh-2, "com_glass")
    # frame grid
    for gx in range(bx+2, bx+bw-1, 5):
        vline(d, gx, by+2, by+bh-2, "com_frame")
    hline(d, by+8, bx+2, bx+bw-2, "com_frame")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # sign
    rect(d, bx+5, by-3, bx+bw-5, by, "com_sign")
    return img

def building_com_2():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 4, 8, 24, 18
    rect(d, bx, by, bx+bw, by+bh, "com_wall1")
    # glass strips
    for gy in range(by+2, by+bh-1, 5):
        rect(d, bx+2, gy, bx+bw-2, gy+3, "com_glass")
    outline(d, bx, by, bx+bw, by+bh, "black")
    rect(d, bx+3, by-4, bx+bw-3, by, "com_sign")
    return img

def building_com_3():
    img = new()
    d = draw(img)
    _base_ground(d)
    # tower
    bx, bw = 9, 14
    floors_y = list(range(2, 26, 4))
    for fy in floors_y:
        col = "com_wall1" if (fy // 4) % 2 == 0 else "com_wall2"
        rect(d, bx, fy, bx+bw, fy+4, col)
        rect(d, bx+1, fy+1, bx+bw-1, fy+3, "com_glass")
    outline(d, bx, 2, bx+bw, 26, "black")
    # antenna
    vline(d, bx+bw//2, 0, 3, "com_frame")
    return img

# ─── Industrial Buildings ───────────────────────────────────────────────────

def building_ind_1():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 3, 14, 26, 12
    rect(d, bx, by, bx+bw, by+bh, "ind_wall1")
    # shed roof
    d.polygon([(bx, by), (bx+bw, by), (bx+bw, by-4), (bx, by-2)],
              fill=(*rgb("ind_roof1"), 255))
    outline(d, bx, by, bx+bw, by+bh, "black")
    # chimney
    rect(d, bx+bw-5, by-10, bx+bw-2, by, "ind_chimney")
    # smoke puff
    d.ellipse([bx+bw-7, by-14, bx+bw, by-9], fill=(*rgb("ind_smoke"), 180))
    # door/loading
    rect(d, bx+10, by+5, bx+18, by+12, "road_edge")
    return img

def building_ind_2():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 2, 10, 28, 16
    rect(d, bx, by, bx+bw, by+bh, "ind_wall2")
    rect(d, bx, by-4, bx+bw, by, "ind_roof1")
    outline(d, bx, by-4, bx+bw, by+bh, "black")
    # two chimneys
    for cx in [bx+6, bx+20]:
        rect(d, cx, by-14, cx+4, by, "ind_chimney")
        d.ellipse([cx-2, by-18, cx+6, by-12], fill=(*rgb("ind_smoke"), 180))
    # windows
    for wx in [bx+3, bx+14]:
        rect(d, wx, by+3, wx+6, by+9, "res_window")
    return img

def building_ind_3():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 1, 7, S-2, 19
    rect(d, bx, by, bx+bw, by+bh, "ind_wall2")
    # saw-tooth roof
    for i in range(4):
        x0 = bx + i*7
        d.polygon([(x0, by), (x0+4, by-6), (x0+7, by)],
                  fill=(*rgb("ind_roof1"), 255))
    outline(d, bx, by, bx+bw, by+bh, "black")
    # 3 chimneys
    for cx in [bx+4, bx+14, bx+24]:
        rect(d, cx, by-12, cx+3, by, "ind_chimney")
        d.ellipse([cx-2, by-16, cx+5, by-10], fill=(*rgb("ind_smoke"), 160))
    return img

# ─── Public Services ────────────────────────────────────────────────────────

def building_police():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 4, 10, 24, 16
    rect(d, bx, by, bx+bw, by+bh, "police_blue")
    rect(d, bx+2, by+2, bx+bw-2, by+8, "white")
    # windows
    for wx in [bx+3, bx+14]:
        rect(d, wx, by+2, wx+6, by+8, "res_window")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # sign / star
    d.text((bx+6, by+9), "POL", fill=(*rgb("white"), 255)) if hasattr(d, 'text') else None
    # light bar
    rect(d, bx+8, by-3, bx+16, by, "fire_red")
    rect(d, bx+6, by-3, bx+8,  by, "police_blue")
    return img

def building_fire():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 3, 10, 26, 16
    rect(d, bx, by, bx+bw, by+bh, "fire_red")
    # garage door
    rect(d, bx+6, by+6, bx+20, by+16, "white")
    for gy in range(by+7, by+16, 2):
        hline(d, gy, bx+6, bx+20, "road_edge")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # roof bar
    rect(d, bx-2, by-3, bx+bw+2, by, "fire_red")
    # sign
    rect(d, bx+10, by+2, bx+16, by+6, "white")
    return img

def building_hospital():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 3, 8, 26, 18
    rect(d, bx, by, bx+bw, by+bh, "hospital_wh")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # red cross
    cx, cy = bx+bw//2, by+bh//2
    rect(d, cx-2, cy-6, cx+2, cy+6, "hospital_cross")
    rect(d, cx-6, cy-2, cx+6, cy+2, "hospital_cross")
    # windows
    for wx in [bx+3, bx+bw-8]:
        rect(d, wx, by+3, wx+5, by+8, "res_window")
    return img

def building_school():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 3, 10, 26, 16
    rect(d, bx, by, bx+bw, by+bh, "school_yel")
    # gable roof
    d.polygon([(bx-2, by), (bx+bw//2, by-8), (bx+bw+2, by)],
              fill=(*rgb("res_roof1"), 255))
    outline(d, bx, by, bx+bw, by+bh, "black")
    # windows row
    for wx in [bx+2, bx+9, bx+17]:
        rect(d, wx, by+3, wx+5, by+9, "res_window")
    # door
    rect(d, bx+11, by+9, bx+15, by+16, "res_door")
    # bell tower
    rect(d, bx+bw//2-2, by-14, bx+bw//2+2, by-8, "school_yel")
    d.ellipse([bx+bw//2-3, by-17, bx+bw//2+3, by-11], fill=(*rgb("hill_mid"),255))
    return img

def building_university():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 1, 8, S-2, 18
    rect(d, bx, by, bx+bw, by+bh, "uni_stone")
    # columns
    for cx in range(bx+3, bx+bw-2, 6):
        rect(d, cx, by-2, cx+2, by+bh, "hill_snow")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # pediment
    d.polygon([(bx-2, by-2), (bx+bw//2, by-10), (bx+bw+2, by-2)],
              fill=(*rgb("hill_light"), 255))
    # windows
    for wx in [bx+2, bx+10, bx+19]:
        rect(d, wx, by+6, wx+5, by+13, "res_window")
    return img

def building_spaceport():
    img = new()
    d = draw(img)
    # pad + tower
    rect(d, 0, 20, S-1, S-1, "space_conc")
    rect(d, 12, 18, 20, 22, "space_conc")
    # launch pad circle
    d.ellipse([8, 16, 24, 24], outline=(*rgb("white"), 200), width=1)
    # rocket
    bx = 14
    rect(d, bx, 2, bx+4, 18, "rocket_body")
    d.polygon([(bx, 2), (bx+2, -2), (bx+4, 2)], fill=(*rgb("space_steel"), 255))
    # fins
    d.polygon([(bx-2, 14), (bx, 18), (bx, 12)], fill=(*rgb("space_steel"), 255))
    d.polygon([(bx+4, 12), (bx+4, 18), (bx+6, 14)], fill=(*rgb("space_steel"), 255))
    # flame
    d.polygon([(bx, 18), (bx+2, 24), (bx+4, 18)],
              fill=(*rgb("rocket_flame"), 220))
    outline(d, bx, 2, bx+4, 18, "black")
    return img

# ─── Extraction Buildings ────────────────────────────────────────────────────

def building_mine():
    img = new()
    d = draw(img)
    _base_ground(d)
    # shaft entrance
    rect(d, 8, 18, 24, 26, "mine_dark")
    d.arc([8, 14, 24, 22], 180, 0, fill=(*rgb("mine_beam"), 255), width=3)
    # headframe
    d.polygon([(14, 6), (18, 6), (16, 2)], outline=(*rgb("mine_beam"), 255), width=2)
    vline(d, 14, 6, 18, "mine_beam")
    vline(d, 18, 6, 18, "mine_beam")
    hline(d, 18, 8, 24, "mine_beam")
    # debris pile
    d.polygon([(4,26),(8,22),(16,24),(14,26)], fill=(*rgb("quarry_grey"),255))
    return img

def building_sawmill():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 4, 12, 22, 14
    rect(d, bx, by, bx+bw, by+bh, "saw_wood")
    # saw blade
    cx, cy, r = bx+bw+4, by+4, 5
    d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(*rgb("rail_metal"), 255))
    for angle in range(0, 360, 45):
        ax = cx + int(r*1.4 * math.cos(math.radians(angle)))
        ay = cy + int(r*1.4 * math.sin(math.radians(angle)))
        d.line([(cx,cy),(ax,ay)], fill=(*rgb("black"),255), width=1)
    # log pile
    for li in range(3):
        d.ellipse([bx+2+li*2, by+bh-4+li, bx+8+li*2, by+bh-1+li],
                  fill=(*rgb("forest_trunk"),255))
    outline(d, bx, by, bx+bw, by+bh, "black")
    return img

def building_oil_pump():
    img = new()
    d = draw(img)
    _base_ground(d)
    # base
    rect(d, 10, 22, 22, 26, "oil_metal")
    # derrick
    d.polygon([(12,22),(20,22),(18,4),(14,4)], outline=(*rgb("oil_metal"),255), width=2)
    # cross beams
    for cy in [10,16]:
        hline(d, cy, 13, 19, "oil_metal")
    # pump head
    rect(d, 11, 2, 21, 6, "oil_metal")
    # oil drip
    d.ellipse([15, 24, 17, 28], fill=(*rgb("oil_black"), 200))
    return img

def building_quarry():
    img = new()
    d = draw(img)
    _base_ground(d)
    # quarry pit (top-down)
    d.ellipse([4, 8, 28, 24], fill=(*rgb("hill_dark"), 255))
    d.ellipse([8, 11, 24, 21], fill=(*rgb("quarry_grey"), 255))
    d.ellipse([12, 14, 20, 18], fill=(*rgb("hill_mid"), 255))
    # excavator arm
    d.line([(6,14),(14,8)], fill=(*rgb("oil_metal"),255), width=2)
    d.line([(14,8),(18,12)], fill=(*rgb("oil_metal"),255), width=2)
    # stone pile
    for i in range(4):
        d.ellipse([22+i, 20-i, 28+i, 24-i], fill=(*rgb("quarry_grey"),180))
    return img

def building_smelter():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 3, 12, 24, 14
    rect(d, bx, by, bx+bw, by+bh, "ind_wall2")
    # furnace glow
    rect(d, bx+8, by+4, bx+16, by+12, "fire_red")
    d.ellipse([bx+10, by+6, bx+14, by+10], fill=(*rgb("school_yel"),255))
    # two chimneys
    for cx in [bx+4, bx+bw-6]:
        rect(d, cx, by-10, cx+4, by, "ind_chimney")
        d.ellipse([cx-3, by-14, cx+7, by-8], fill=(*rgb("power_smoke"),160))
    outline(d, bx, by, bx+bw, by+bh, "black")
    return img

# ─── Power Plants ────────────────────────────────────────────────────────────

def building_coal_plant():
    img = new()
    d = draw(img)
    _base_ground(d)
    bx, by, bw, bh = 2, 12, 22, 14
    rect(d, bx, by, bx+bw, by+bh, "power_coal")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # big chimney
    rect(d, bx+bw, by-8, bx+bw+6, by+bh, "ind_chimney")
    d.ellipse([bx+bw-2, by-14, bx+bw+8, by-6], fill=(*rgb("power_smoke"), 200))
    d.ellipse([bx+bw-4, by-20, bx+bw+10, by-12], fill=(*rgb("power_smoke"), 140))
    # cooling tower outline
    d.arc([bx-2, by-6, bx+8, by+2], 180, 0, fill=(*rgb("ind_wall1"),255), width=2)
    return img

def building_solar_plant():
    img = new()
    d = draw(img)
    # ground
    rect(d, 0, 24, S-1, S-1, "grass_dark")
    # solar panels — 3x2 grid
    for row in range(2):
        for col in range(3):
            px = 3 + col * 9
            py = 8 + row * 8
            rect(d, px, py, px+8, py+6, "power_solar")
            # cell grid
            for gx in range(px+2, px+8, 2):
                vline(d, gx, py+1, py+5, "power_solar_c")
            for gy in range(py+2, py+6, 2):
                hline(d, gy, px+1, px+7, "power_solar_c")
            outline(d, px, py, px+8, py+6, "black")
    return img

def building_wind_turbine():
    img = new()
    d = draw(img)
    rect(d, 0, 24, S-1, S-1, "grass_mid")
    # tower
    cx = S // 2
    d.polygon([(cx-2, 24), (cx+2, 24), (cx+1, 8), (cx-1, 8)],
              fill=(*rgb("power_wind"), 255))
    # hub
    d.ellipse([cx-2, 6, cx+2, 10], fill=(*rgb("rail_metal"), 255))
    # blades
    for angle in [90, 210, 330]:
        blen = 10
        ex = cx + int(blen * math.cos(math.radians(angle)))
        ey = 8  + int(blen * math.sin(math.radians(angle)))
        d.line([(cx, 8), (ex, ey)], fill=(*rgb("white"), 220), width=2)
    return img

# ─── Vehicles ───────────────────────────────────────────────────────────────

def vehicle_car():
    img = new()
    d = draw(img)
    # body (horizontal car, 16x8)
    bx, by, bw, bh = 8, 13, 16, 8
    rect(d, bx, by, bx+bw, by+bh, "car_body")
    # windshield
    rect(d, bx+2, by+1, bx+6, by+4, "car_window")
    rect(d, bx+9, by+1, bx+14, by+4, "car_window")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # wheels
    for wx in [bx+1, bx+bw-3]:
        d.ellipse([wx, by+bh-1, wx+4, by+bh+3], fill=(*rgb("car_wheel"),255))
    # headlights
    rect(d, bx, by+2, bx+1, by+5, "school_yel")
    rect(d, bx+bw, by+2, bx+bw+1, by+5, "fire_red")
    return img

def vehicle_bus():
    img = new()
    d = draw(img)
    bx, by, bw, bh = 4, 11, 24, 10
    rect(d, bx, by, bx+bw, by+bh, "bus_yellow")
    # windows strip
    rect(d, bx+2, by+2, bx+bw-2, by+6, "car_window")
    # window dividers
    for wx in range(bx+7, bx+bw-2, 5):
        vline(d, wx, by+2, by+6, "black")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # wheels
    for wx in [bx+2, bx+bw-5]:
        d.ellipse([wx, by+bh-1, wx+5, by+bh+4], fill=(*rgb("car_wheel"),255))
    # door
    rect(d, bx+2, by+4, bx+5, by+bh, "road_base")
    return img

def vehicle_train():
    img = new()
    d = draw(img)
    bx, by, bw, bh = 2, 10, 28, 12
    rect(d, bx, by, bx+bw, by+bh, "train_blue")
    # windows
    for wx in range(bx+3, bx+bw-3, 7):
        rect(d, wx, by+2, wx+5, by+7, "train_window")
    outline(d, bx, by, bx+bw, by+bh, "black")
    # nose
    d.polygon([(bx, by+2), (bx-4, by+bh//2), (bx, by+bh-2)],
              fill=(*rgb("train_blue"),255))
    # wheels
    for wx in [bx+3, bx+10, bx+18, bx+24]:
        d.ellipse([wx, by+bh, wx+3, by+bh+4], fill=(*rgb("car_wheel"),255))
    # stripe
    hline(d, by+bh//2, bx, bx+bw, "white")
    return img

# ─── UI Icons (16x16 rendered at 32x32 with border) ─────────────────────────

def icon_power():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    # lightning bolt
    d.polygon([(18,4),(10,16),(16,16),(14,28),(22,14),(16,14)],
              fill=(*rgb("school_yel"), 255))
    return img

def icon_water():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    cx, cy = 16, 18
    # water drop
    d.polygon([(cx, 6), (cx-7, cy), (cx+7, cy)], fill=(*rgb("water_mid"),255))
    d.ellipse([cx-7, cy-4, cx+7, cy+6], fill=(*rgb("water_mid"),255))
    return img

def icon_traffic():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    rect(d, 12, 4, 20, 28, "road_base")
    rect(d, 4, 12, 28, 20, "road_base")
    # arrow
    d.polygon([(16,6),(20,12),(12,12)], fill=(*rgb("road_line"),255))
    return img

def icon_pollution():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    for r, alpha in [(12,80),(8,140),(4,220)]:
        d.ellipse([16-r, 16-r, 16+r, 16+r],
                  fill=(*rgb("ind_smoke"), alpha))
    return img

def icon_crime():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    # star badge
    cx, cy = 16, 16
    pts = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = 11 if i % 2 == 0 else 5
        pts.append((cx + r*math.cos(angle), cy + r*math.sin(angle)))
    d.polygon(pts, fill=(*rgb("police_blue"),255))
    return img

def icon_land_value():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    # house + arrow up
    bx, by = 10, 14
    rect(d, bx, by, bx+12, by+12, "res_wall1")
    d.polygon([(bx-2,by),(bx+8,by-7),(bx+14,by)], fill=(*rgb("res_roof1"),255))
    # up arrow
    d.polygon([(22,4),(26,10),(24,10),(24,16),(20,16),(20,10),(18,10)],
              fill=(*rgb("ui_accent"),255))
    return img

def icon_pop_density():
    img = new()
    d = draw(img)
    rect(d, 2, 2, 29, 29, "ui_bg")
    # three person silhouettes
    for ox in [5, 12, 20]:
        d.ellipse([ox+1,6,ox+6,11], fill=(*rgb("white"),200))
        d.polygon([(ox,11),(ox+7,11),(ox+6,20),(ox+1,20)], fill=(*rgb("white"),200))
    return img

# ─── Power Lines & Pipes (infrastructure) ───────────────────────────────────

def tile_power_line_h():
    img = new("grass_mid")
    d = draw(img)
    # pole
    vline(d, S//2, 4, 28, "ind_chimney")
    hline(d, 8, S//2-5, S//2+5, "ind_chimney")
    # wires
    d.line([(0,10),(S//2-5,9)], fill=(*rgb("black"),200), width=1)
    d.line([(S//2+5,9),(S-1,10)], fill=(*rgb("black"),200), width=1)
    d.line([(0,12),(S//2-5,11)], fill=(*rgb("black"),200), width=1)
    d.line([(S//2+5,11),(S-1,12)], fill=(*rgb("black"),200), width=1)
    return img

def tile_pipe_h():
    img = new("grass_mid")
    d = draw(img)
    rect(d, 0, 13, S-1, 18, "ind_wall1")
    hline(d, 15, 0, S-1, "road_edge")
    rect(d, 14, 11, 18, 20, "ind_wall2")
    outline(d, 0, 13, S-1, 18, "black")
    return img

# ─── Generate all sprites ────────────────────────────────────────────────────

SPRITES = {
    # terrain
    "terrain_grass.png":         tile_grass,
    "terrain_water.png":         tile_water,
    "terrain_hill.png":          tile_hill,
    "terrain_forest.png":        tile_forest,
    # roads & rails
    "road_h.png":                tile_road_h,
    "road_v.png":                tile_road_v,
    "road_cross.png":            tile_road_cross,
    "rail_h.png":                tile_rail_h,
    "rail_v.png":                tile_rail_v,
    # residential
    "building_res_1.png":        building_res_1,
    "building_res_2.png":        building_res_2,
    "building_res_3.png":        building_res_3,
    # commercial
    "building_com_1.png":        building_com_1,
    "building_com_2.png":        building_com_2,
    "building_com_3.png":        building_com_3,
    # industrial
    "building_ind_1.png":        building_ind_1,
    "building_ind_2.png":        building_ind_2,
    "building_ind_3.png":        building_ind_3,
    # services
    "building_police.png":       building_police,
    "building_fire.png":         building_fire,
    "building_hospital.png":     building_hospital,
    "building_school.png":       building_school,
    "building_university.png":   building_university,
    "building_spaceport.png":    building_spaceport,
    # extraction
    "building_mine.png":         building_mine,
    "building_sawmill.png":      building_sawmill,
    "building_oil_pump.png":     building_oil_pump,
    "building_quarry.png":       building_quarry,
    "building_smelter.png":      building_smelter,
    # power
    "building_coal_plant.png":   building_coal_plant,
    "building_solar_plant.png":  building_solar_plant,
    "building_wind_turbine.png": building_wind_turbine,
    # vehicles
    "vehicle_car.png":           vehicle_car,
    "vehicle_bus.png":           vehicle_bus,
    "vehicle_train.png":         vehicle_train,
    # infrastructure
    "infra_power_line.png":      tile_power_line_h,
    "infra_pipe.png":            tile_pipe_h,
    # UI icons
    "icon_power.png":            icon_power,
    "icon_water.png":            icon_water,
    "icon_traffic.png":          icon_traffic,
    "icon_pollution.png":        icon_pollution,
    "icon_crime.png":            icon_crime,
    "icon_land_value.png":       icon_land_value,
    "icon_pop_density.png":      icon_pop_density,
}

if __name__ == "__main__":
    print(f"Generating {len(SPRITES)} sprites → {OUT_TILES}/")
    for filename, fn in SPRITES.items():
        try:
            img = fn()
            save(img, filename)
        except Exception as e:
            print(f"  ! FAILED {filename}: {e}")
    print(f"\nDone. {len(SPRITES)} sprites written.")
