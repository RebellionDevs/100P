import pygame

class MenuState:

    def __init__(self):

        # Buttons pos, fonts, etc
        self.play_rect = pygame.Rect(100, 200, 200, 50) # TEST
        self.settings_rect = pygame.Rect(100, 280, 200, 50)

    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            if self.play_rect.collidepoint(event.pos):
                print("play button pressed")
                # from game import GameState (?)
                # return GameState()
                pass
            elif self.settings_rect.collidepoint(event.pos):
                print("settings button pressed")
                # from ui.settings import SettingsState
                # return SettingsState()
                pass
        return None

    def update(self):
        pass

    def draw(self, surface):
        surface.fill((30, 30, 30))
        font = pygame.font.SysFont(None, 36)

        pygame.draw.rect(surface, (200, 200, 200), self.play_rect)
        surface.blit(font.render("PLAY", True, (0, 0, 0)), (135, 212))

        pygame.draw.rect(surface, (200, 200, 200), self.settings_rect)
        surface.blit(font.render("SETTINGS", True, (0, 0, 0)), (115, 292))