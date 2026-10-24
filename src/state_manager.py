import pygame

class StateManager():
    def __init__(self, initial_state):
        self.current_state = initial_state

    def change_state(self, new_state):
        self.current_state = new_state

    def handle_event(self, event):
        next_state = self.current_state.handle_event(event)
        if next_state:
            self.change_state(next_state)

    def update(self, dt):
        self.current_state.update()

    def draw(self, screen):
        self.current_state.draw(screen)