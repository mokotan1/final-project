from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Build"
bg = Image.open(ROOT / "sprites/spr_menu_background/spr_menu_background.png").convert("RGBA")
emblem = Image.open(ROOT / "sprites/spr_menu_emblem/spr_menu_emblem.png").convert("RGBA")
table = Image.open(next((ROOT / "sprites/spr_table").glob("*.png"))).convert("RGBA")
try:
    regular = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 16)
    bold = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 30)
    title = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 58)
except OSError:
    regular = bold = title = ImageFont.load_default()

BRASS = (211, 169, 78, 255)
CREAM = (236, 231, 204, 255)
FELT = (19, 62, 53, 255)
FELT_DARK = (11, 38, 35, 255)
WALNUT = (35, 27, 23, 255)
MUTED = (164, 188, 173, 255)

def rr(d, box, fill, outline=None, width=1, radius=12):
    d.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)

def centered(d, xy, text, font, fill):
    d.text(xy, text, font=font, fill=fill, anchor="mm")

def main_preview():
    im = bg.copy(); d = ImageDraw.Draw(im)
    rr(d, (340, 82, 940, 620), WALNUT, radius=18)
    rr(d, (354, 96, 926, 606), None, BRASS, 2, 18)
    rr(d, (360, 102, 920, 600), FELT_DARK, radius=15)
    im.alpha_composite(emblem.resize((158, 130)), (84, 90))
    centered(d, (640, 188), "CUSHION", title, CREAM)
    centered(d, (640, 226), "CHALLENGE", regular, BRASS)
    centered(d, (640, 270), "A POOL OF RISK, REWARD, AND PERFECT ANGLES", regular, MUTED)
    for y, label in ((310, "PLAY"), (392, "SETTINGS"), (474, "EXIT")):
        rr(d, (490, y, 790, y + 60), FELT, BRASS, 2)
        centered(d, (640, y + 30), label, bold, CREAM)
    im.save(OUT / "menu_preview_main.png")

def static_menu_art():
    im = Image.new("RGBA", (600, 520), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    rr(d, (0, 0, 600, 520), FELT_DARK, radius=18); rr(d, (14, 14, 586, 506), None, BRASS, 2, 18)
    centered(d, (300, 106), "CUSHION", title, CREAM); centered(d, (300, 144), "CHALLENGE", regular, BRASS)
    centered(d, (300, 188), "A POOL OF RISK, REWARD, AND PERFECT ANGLES", regular, MUTED)
    for y, label in ((228, "PLAY"), (310, "SETTINGS"), (392, "EXIT")):
        rr(d, (150, y, 450, y + 60), FELT, BRASS, 2); centered(d, (300, y + 30), label, bold, CREAM)
    im.save(ROOT / "sprites/spr_menu_static/spr_menu_static.png")

def mode_static_art():
    for selected, filename in (("ENDLESS", "spr_mode_endless.png"), ("CLASSIC", "spr_mode_classic.png")):
        im = Image.new("RGBA", (1280, 720), (7, 24, 26, 255)); d = ImageDraw.Draw(im)
        rr(d, (55, 48, 610, 672), WALNUT, radius=18); rr(d, (670, 48, 1225, 672), WALNUT, radius=18)
        rr(d, (67, 60, 598, 660), None, BRASS, 2, 18); rr(d, (682, 60, 1213, 660), None, BRASS, 2, 18)
        rr(d, (80, 74, 585, 646), FELT_DARK, radius=14); rr(d, (695, 74, 1200, 646), FELT_DARK, radius=14)
        d.rectangle((108, 95, 557, 365), fill=(211, 214, 207, 255)); d.rectangle((124, 111, 541, 349), fill=(19, 62, 53, 255)); im.alpha_composite(table.resize((417, 239)), (124, 111))
        d.rectangle((108, 388, 557, 560), fill=(211, 214, 207, 255)); centered(d, (332, 414), "SELECTED MODE", regular, WALNUT); centered(d, (332, 449), selected, bold, BRASS)
        desc = ("Items, milestones, and escalating foul pressure." if selected == "ENDLESS" else "Pure shots with no items and foul cap four.")
        centered(d, (332, 486), desc, regular, WALNUT); centered(d, (332, 515), "Best score", regular, WALNUT)
        rr(d, (195, 578, 445, 632), FELT, BRASS, 2); centered(d, (320, 605), "START", bold, CREAM)
        for box, label, sub in [((750,165,1145,265), "ENDLESS", "ITEMS / MILESTONES"), ((750,345,1145,445), "CLASSIC", "PURE SHOT / FOUL CAP 4")]:
            fill = BRASS if label == selected else FELT; text = WALNUT if label == selected else CREAM
            rr(d, box, fill, BRASS, 2); x=(box[0]+box[2])//2; centered(d, (x, box[1]+40), label, bold, text); centered(d, (x, box[1]+73), sub, regular, MUTED)
        rr(d, (845, 578, 1050, 632), WALNUT, BRASS, 2); centered(d, (947, 605), "BACK", bold, CREAM)
        im.save(ROOT / f"sprites/{filename}")

def px_text(d, xy, text, scale, fill, anchor="mm"):
    font = ImageFont.load_default()
    box = d.textbbox((0, 0), text, font=font)
    tile = Image.new("RGBA", (box[2] - box[0] + 4, box[3] - box[1] + 4), (0, 0, 0, 0))
    ImageDraw.Draw(tile).text((2 - box[0], 2 - box[1]), text, font=font, fill=fill)
    alpha = tile.getchannel("A").point(lambda p: 255 if p >= 128 else 0)
    tile.putalpha(alpha)
    tile = tile.resize((tile.width * scale, tile.height * scale), Image.Resampling.NEAREST)
    x, y = xy
    if anchor == "mm": x -= tile.width // 2; y -= tile.height // 2
    d._image.alpha_composite(tile, (int(x), int(y)))

def save_px(im, path):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    im.convert("RGB").quantize(colors=8, dither=Image.Dither.NONE).convert("RGBA").save(path)

def pixel_art():
    near = (7, 29, 22, 255); dark = (16, 79, 58, 255); cloth = (23, 124, 90, 255); walnut = (68, 40, 27, 255); gold = (213, 168, 85, 255); hi = (240, 211, 138, 255); paper = (210, 214, 194, 255)
    # Main menu: hard pixel blocks and a deliberately tiny bitmap font scaled by integers.
    im = Image.new("RGBA", (600, 520), (0, 0, 0, 0)); d = ImageDraw.Draw(im); d._image = im
    d.rectangle((0, 0, 599, 519), fill=walnut); d.rectangle((8, 8, 591, 511), fill=near); d.rectangle((14, 14, 585, 505), outline=gold, width=2); d.rectangle((20, 20, 579, 499), fill=dark)
    px_text(d, (300, 106), "CUSHION", 6, hi); px_text(d, (300, 145), "CHALLENGE", 3, gold); px_text(d, (300, 188), "POOL OF RISK / REWARD / ANGLES", 2, (165, 194, 160, 255))
    for y, label in ((228, "PLAY"), (310, "SETTINGS"), (392, "EXIT")):
        d.rectangle((150, y, 450, y + 59), fill=cloth); d.rectangle((150, y, 450, y + 59), outline=gold, width=2); px_text(d, (300, y + 30), label, 4, hi)
    save_px(im, ROOT / "sprites/spr_menu_static/spr_menu_static.png")
    # Mode screens share the same pixel frame and use one of two selected-state palettes.
    for selected, filename in (("ENDLESS", "spr_mode_endless.png"), ("CLASSIC", "spr_mode_classic.png")):
        im = Image.new("RGBA", (1280, 720), near); d = ImageDraw.Draw(im); d._image = im
        for box in ((55, 48, 610, 672), (670, 48, 1225, 672)):
            d.rectangle(box, fill=walnut); d.rectangle((box[0]+8, box[1]+8, box[2]-8, box[3]-8), fill=dark); d.rectangle((box[0]+12, box[1]+12, box[2]-12, box[3]-12), outline=gold, width=2)
        d.rectangle((108, 95, 557, 365), fill=paper); d.rectangle((124, 111, 541, 349), fill=cloth); im.alpha_composite(table.resize((417, 239), Image.Resampling.NEAREST), (124, 111))
        d.rectangle((108, 388, 557, 560), fill=paper); px_text(d, (332, 414), "SELECTED MODE", 2, walnut); px_text(d, (332, 449), selected, 4, gold)
        desc = "ITEMS / MILESTONES" if selected == "ENDLESS" else "PURE SHOT / FOUL CAP 4"; px_text(d, (332, 486), desc, 2, walnut); px_text(d, (332, 515), "BEST SCORE", 2, walnut)
        d.rectangle((195, 578, 445, 632), fill=cloth); d.rectangle((195, 578, 445, 632), outline=gold, width=2); px_text(d, (320, 605), "START", 4, hi)
        for box, label, sub in (((750,165,1145,265), "ENDLESS", "ITEMS / MILESTONES"), ((750,345,1145,445), "CLASSIC", "PURE SHOT / FOUL CAP 4")):
            fill = gold if label == selected else cloth; text = walnut if label == selected else hi; subtext = walnut if label == selected else hi; d.rectangle(box, fill=fill); d.rectangle(box, outline=gold, width=2); px_text(d, ((box[0]+box[2])//2, box[1]+40), label, 4, text); px_text(d, ((box[0]+box[2])//2, box[1]+75), sub, 2, subtext)
        d.rectangle((845, 578, 1050, 632), fill=walnut); d.rectangle((845, 578, 1050, 632), outline=gold, width=2); px_text(d, (947, 605), "BACK", 3, hi)
        save_px(im, ROOT / f"sprites/{filename.split('.')[0]}/{filename}")
    for enabled, filename in (("ON", "spr_menu_settings_on.png"), ("OFF", "spr_menu_settings_off.png")):
        im = Image.new("RGBA", (1280, 720), near); d = ImageDraw.Draw(im); d._image = im
        d.rectangle((390, 150, 890, 570), fill=dark); d.rectangle((402, 162, 878, 558), outline=gold, width=2)
        px_text(d, (640, 235), "SETTINGS", 5, hi); px_text(d, (640, 295), "AUDIO CUES", 3, (165, 194, 160, 255))
        d.rectangle((460, 332, 820, 388), fill=cloth); d.rectangle((460, 332, 820, 388), outline=gold, width=2); px_text(d, (640, 360), enabled + "  -  CLICK TO TOGGLE", 2, hi)
        d.rectangle((540, 460, 740, 514), fill=walnut); d.rectangle((540, 460, 740, 514), outline=gold, width=2); px_text(d, (640, 487), "DONE", 3, hi)
        save_px(im, ROOT / f"sprites/{filename.split('.')[0]}/{filename}")

def mode_preview():
    im = Image.new("RGBA", (1280, 720), (7, 24, 26, 255)); d = ImageDraw.Draw(im)
    rr(d, (55, 48, 610, 672), WALNUT, radius=18); rr(d, (670, 48, 1225, 672), WALNUT, radius=18)
    rr(d, (67, 60, 598, 660), None, BRASS, 2, 18); rr(d, (682, 60, 1213, 660), None, BRASS, 2, 18)
    rr(d, (80, 74, 585, 646), FELT_DARK, radius=14); rr(d, (695, 74, 1200, 646), FELT_DARK, radius=14)
    d.rectangle((108, 95, 557, 365), fill=(211, 214, 207, 255)); d.rectangle((124, 111, 541, 349), fill=(19, 62, 53, 255))
    preview = table.resize((417, 239)); im.alpha_composite(preview, (124, 111))
    d.rectangle((108, 388, 557, 560), fill=(211, 214, 207, 255))
    centered(d, (332, 414), "SELECTED MODE", regular, WALNUT); centered(d, (332, 449), "ENDLESS", bold, BRASS)
    centered(d, (332, 486), "Items, milestones, and escalating foul pressure.", regular, WALNUT); centered(d, (332, 515), "Best score  1005370", regular, WALNUT)
    rr(d, (195, 578, 445, 632), FELT, BRASS, 2); centered(d, (320, 605), "START", bold, CREAM)
    for box, label, sub in [((750,165,1145,265), "ENDLESS", "ITEMS / MILESTONES"), ((750,345,1145,445), "CLASSIC", "PURE SHOT / FOUL CAP 4")]:
        rr(d, box, FELT, BRASS, 2); x=(box[0]+box[2])//2; centered(d, (x, box[1]+40), label, bold, CREAM); centered(d, (x, box[1]+73), sub, regular, MUTED)
    rr(d, (845, 578, 1050, 632), WALNUT, BRASS, 2); centered(d, (947, 605), "BACK", bold, CREAM)
    im.save(OUT / "menu_preview_mode_select.png")

if __name__ == "__main__":
    main_preview(); mode_preview(); static_menu_art(); mode_static_art(); pixel_art()
