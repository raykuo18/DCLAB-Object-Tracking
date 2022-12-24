import sys
sys.path.append('/Users/ray_kuo/Documents/NTUEE/111-1/DCLab/DCLAB-Object-Tracking/python_model')

from config import Config

<<<<<<< HEAD

class PE():
    def __init__(self, id: int) -> None:

        assert isinstance(id, int)

        self._id = id
        self._OAshape = None


    def put_OAshape(self, Hout: int, Wout: int, Cout: int):
        assert isinstance(Hout, int)
        assert isinstance(Wout, int)
        assert isinstance(Cout, int)

        self._OAshape = (Hout, Wout, Cout)
        

    
    def get_OA(self):
        Hout, Wout, Cout = self._OAshape

        return [ [1]*Cout for x in range(3)      ]  
        
    
=======
class PE():
    def __init__(self) -> None:
        pass
    pass
>>>>>>> f804d45 (Finisah aim module)

if __name__ == "__main__":
    print("Nice")