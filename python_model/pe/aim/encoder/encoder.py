from config import Config
from typing import Tuple

conf = Config()('PE/AIM/Encoder')

class Encoder():
    step_size = conf['step_size'] # 32
    
    def __init__(self) -> None:
        self.counter = 0
        self.valid = 0
        self.pos = 0
        
    def encode(self, input: list) -> Tuple[int, int]:
        assert isinstance(input, list)
        assert all(isinstance(x, int) for x in input)
        assert len(input) == Encoder.step_size
        
        if self.valid == 1:
            return self.valid, self.pos
        elif 1 in input:
            index = input.index(1)
            self.pos = Encoder.step_size * self.counter + index
            self.valid = 1
            return self.valid, self.pos
        else:
            self.counter += 1
            return self.valid, self.pos
    
    def reset(self):
        self.counter = 0
        self.valid = 0
        self.pos = 0