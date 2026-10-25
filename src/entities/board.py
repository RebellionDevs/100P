import json
import os
import pygame

from utils.loader import assets
from config import SCREEN_HEIGHT, SCREEN_WIDTH

class Board():

    def __init__(self, level_id : int|str = "test"):
        level_name = f"level_{level_id}"

        # graphics
        display_surf = pygame.display.get_surface()
        screen_w = display_surf.get_width() if display_surf else SCREEN_WIDTH
        screen_h = display_surf.get_height() if display_surf else SCREEN_HEIGHT

        self.surface = assets.load_image(f"{level_name}.png", (screen_w, screen_h))
        
        self.rect = self.surface.get_rect(
            center=(screen_w // 2, screen_h // 2)
        )

        self.walls = []
        self.zones = []

        self._load_json_data(f"{level_name}.json")

    def _load_json_data(self, filename):
        level_path = os.path.join("assets", "levels", filename)

        with open(level_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        self._parse_level(data.get("elements", []))

    def _parse_level(self, elements):
        valid_elements = [el for el in elements if not el.get("isDeleted", False)]
        if not valid_elements:
            return

        all_x = []
        all_y = []
        for el in valid_elements:
            x, y = el.get("x", 0), el.get("y", 0)
            all_x.append(x)
            all_y.append(y)
            
            el_type = el.get("type")
            if el_type in ["line", "freedraw"]:
                for p in el.get("points", []):
                    all_x.append(x + p[0])
                    all_y.append(y + p[1])
            elif el_type == "rectangle":
                all_x.append(x + el.get("width", 0))
                all_y.append(y + el.get("height", 0))

        min_x, max_x = min(all_x), max(all_x)
        min_y, max_y = min(all_y), max(all_y)

        box_w = max_x - min_x
        box_h = max_y - min_y

        img_w, img_h = self.surface.get_size()

        scale_x = img_w / box_w if box_w > 0 else 1.0
        scale_y = img_h / box_h if box_h > 0 else 1.0

        for el in valid_elements:
            el_type = el.get("type")
            x = el.get("x", 0)
            y = el.get("y", 0)
            stroke_color = el.get("strokeColor", "#1e1e1e")

            if el_type in ["line", "freedraw"]:
                points = el.get("points", [])
                if len(points) >= 2:
                    p1 = (
                        int(self.rect.left + ((x + points[0][0]) - min_x) * scale_x),
                        int(self.rect.top + ((y + points[0][1]) - min_y) * scale_y)
                    )
                    p2 = (
                        int(self.rect.left + ((x + points[-1][0]) - min_x) * scale_x),
                        int(self.rect.top + ((y + points[-1][1]) - min_y) * scale_y),
                    )

                    if stroke_color == "#1971c2":
                        self.walls.append({"type": "FUNCTION_WALL", "p1": p1, "p2": p2})
                    else:
                        self.walls.append({"type": "SOLID", "p1": p1, "p2": p2})

            elif el_type == "rectangle":
                w = el.get("width", 0)
                h = el.get("height", 0)
                rx = int(self.rect.left + (x - min_x) * scale_x)
                ry = int(self.rect.top + (y - min_y) * scale_y)
                rw = int(w * scale_x)
                rh = int(h * scale_y)

                if stroke_color == "#e03131":
                    self.zones.append(
                        {"rect": pygame.Rect(rx, ry, rw, rh), "type": "INTEGRAL_ZONE"}
                    )
                else:
                    self.walls.extend([
                        {"type": "SOLID", "p1": (rx, ry), "p2": (rx + rw, ry)},
                        {"type": "SOLID", "p1": (rx + rw, ry), "p2": (rx + rw, ry + rh)},
                        {"type": "SOLID", "p1": (rx + rw, ry + rh), "p2": (rx, ry + rh)},
                        {"type": "SOLID", "p1": (rx, ry + rh), "p2": (rx, ry)},
                    ])

    def draw(self, screen):
        screen.blit(self.surface, self.rect.topleft)

        for wall in self.walls:
            color = (0, 0, 255) if wall["type"] == "FUNCTION_WALL" else (0, 255, 0)
            pygame.draw.line(screen, color, wall["p1"], wall["p2"], 2)

        for zone in self.zones:
            pygame.draw.rect(screen, (220, 50, 50), zone["rect"], 2)