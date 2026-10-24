import pygame
import os

class AssetLoader:
    def __init__(self):

        # caching
        self._images = {}
        self._sounds = {}
        self._music = {}

        self.assets_dir = "assets"

        if not pygame.mixer.get_init():
            pygame.mixer.init()

    def load_image(self, filename : str, scale : tuple[int, int] = None) -> pygame.Surface:
        if filename not in self._images:
            path = os.path.join(self.assets_dir, "sprites", filename)
            try:
                image = pygame.image.load(path).convert_alpha()
                if scale:
                    image = pygame.transform.scale(image, scale)
                self._images[filename] = image

            except (pygame.error, FileNotFoundError) as e:
                print("wrong aswer, son!")
                print(e)

        return self._images[filename]

    def load_sound(self, filename : str) -> pygame.mixer.Sound | None:
        pass

    def load_music(self, filename : str, loops : int = -1, volume : float = 0.5):
        pass

assets = AssetLoader()