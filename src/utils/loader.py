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

    def load_image_tiled(self, filename : str, width : int, height : int, scale_factor : float = 0.4) -> pygame.Surface:
      cache_key = f"tiled_{filename}_{width}_{height}_{scale_factor}"

      if cache_key not in self._images:
        path = os.path.join(self.assets_dir, "sprites", filename)
        try:
          image = pygame.image.load(path).convert_alpha()

          if scale_factor != 1.0:
            orig_w, orig_h = image.get_size()
            new_w = max(1, int(orig_w * scale_factor))
            new_h = max(1, int(orig_h * scale_factor))
            image = pygame.transform.smoothscale(image, (new_w, new_h))

          img_w, img_h = image.get_size()

          surface = pygame.Surface((width, height))
          for x in range(0, width, img_w):
            for y in range(0, height, img_h):
              surface.blit(image, (x, y))

          self._images[cache_key] = surface

        except (pygame.error, FileNotFoundError) as e:
          print("I listening to mommy asmr, but nobody will see it.")

      return self._images[cache_key]       

    def load_sound(self, filename : str) -> pygame.mixer.Sound | None:
        pass

    def load_music(self, filename : str, loops : int = -1, volume : float = 0.5):
        pass

assets = AssetLoader()