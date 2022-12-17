import yaml

from yaml.loader import SafeLoader

# parser = argparse.ArgumentParser()

class IABundle():
    def __init__(self, h: int, w: int, data: list, c_idx: list):
        assert isinstance(h, int)
        assert isinstance(w, int)
        assert isinstance(data, list)
        assert isinstance(c_idx, list)
        assert all(isinstance(x, float) for x in data)
        assert all(isinstance(x, int) for x in c_idx)
        assert len(data) == len(c_idx), ''
        
        self._h = h
        self._w = w
        self._data = data
        self._c_idx = c_idx
    
    def get_h_w(self):
        return (self._h, self._w)
    
    def get_data(self):
        return self._data
    
    def get_c_idx(self):
        return self._c_idx

class WBundle():
    def __init__(self, s: int, data: list, c_idx: list, pos_ptr: list, r_idx: list, k_idx: list):
        assert isinstance(s, int)
        assert isinstance(data, list)
        assert isinstance(c_idx, list)
        assert isinstance(pos_ptr, list)
        assert isinstance(r_idx, list)
        assert isinstance(k_idx, list)
        assert all(isinstance(x, float) for x in data)
        assert all(isinstance(x, int) for x in c_idx)
        assert all(isinstance(x, int) for x in pos_ptr)
        assert all(isinstance(x, int) for x in r_idx)
        assert all(isinstance(x, int) for x in k_idx)
        assert len(data) == len(c_idx)
        assert len(pos_ptr) == len(r_idx) and len(r_idx) == len(k_idx)
        
        self._s = s
        self._data = data
        self._c_idx = c_idx
        self._pos_ptr = pos_ptr
        self._r_idx = r_idx
        self._k_idx = k_idx
    
    def get_s(self):
        return self._s
    
    def get_data(self):
        return self._data
    
    def get_pos_ptr(self):
        return self._pos_ptr
    
    def get_r_idx(self):
        return self._r_idx
    
    def get_k_idx(self):
        return self._k_idx

class Specs():
    initialized = False
    specs = {}

    def __init__(self):
        if Specs.initialized:
            return
        Specs.initialized = True

        Specs.specs = Specs.read_yaml('specs.yml')
        # print(Specs.specs)

    @staticmethod
    def read_yaml(file):
        data = []
        with open(file, 'r') as f:
            data = list(yaml.load_all(f, Loader=SafeLoader))[0]
            # for key, value in data.items():
            #     print(key, ':', value)
        return data
    
if __name__ == '__main__':
    Specs()
    print(Specs.specs)