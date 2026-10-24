import pygame

from utils.loader import assets
from entities.player import Player
from entities.enemy import Enemy
from config import *

class GameState():
    def __init__(self):
        
        self.sub_state = "PLAYER_SELECT_CARD" # PLAYER_AIMING, REVOLVING, ENEMY_TURN and etc.

        self.player = Player()
        self.enemy = Enemy()

        self.cards = [] # all cards
        self.discard = [] # used cards

        # graphics
        self.bg = assets.load_image("game_background.jpg", (SCREEN_WIDTH, SCREEN_HEIGHT))

    def handle_event(self, event):
        # self.sub_state changes here
        pass

    def update(self, dt):
        # game logic here
        pass

    def draw(self, screen):
        screen.blit(self.bg, (0, 0))