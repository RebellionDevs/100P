import pygame

class Character():

    def __init__(self):

        self.health = 100
        self.pos = pygame.Vector2(0, 0)
        self.deck = [] #