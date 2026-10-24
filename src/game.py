import pygame

from utils.loader import assets
from entities.player import Player
from entities.enemy import Enemy

class Game():
    def __init__(self):
        
        self.game_state = "PLAYER_SELECT_CARD" # PLAYER_AIMING, REVOLVING, ENEMY_TURN and etc.

        self.cards = [] # all cards
        self.discard = [] # used cards
