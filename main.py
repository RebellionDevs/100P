import pygame
import sys
from src.config import SCREEN_WIDTH, SCREEN_HEIGHT, FPS
from src.state_manager import StateManager

class Game:
    def __init__(self):

        pygame.init()
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption('100P')
        self.clock = pygame.time.Clock()

        self.state_manager = StateManager()
        self.dt = 0 # delta-time

    def run(self): # main game cycle
        while True:

            self.dt = self.clock.tick(FPS) / 1000.0

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    sys.exit()

                self.state_manager.handle_event(event)

            self.state_manager.update(self.dt)

            self.screen.fill('black')
            self.state_manager.draw(self.screen)
            pygame.display.update()

if __name__ == "__main__":
    game = Game()
    game.run()