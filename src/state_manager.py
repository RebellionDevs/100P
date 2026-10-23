import pygame

class StateManager():
    def __init__(self):
        self.current_state = "MENU" # or 'PLAYING'

    def handle_event(self, event):
        # menu -> game interaction
        pass 

    def update(self, dt):
        # menu | game update cycles here
        pass

    def draw(self, screen):
        # for drawing, no shit Sherlock
        pass