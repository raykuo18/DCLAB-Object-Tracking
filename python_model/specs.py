class VPPairs():
    def __init__(self, valids: list, poses: list) -> None:
        assert isinstance(valids, list)
        assert all(isinstance(x, int) for x in valids)
        assert isinstance(poses, list)
        assert all(isinstance(x, int) for x in poses)
        assert len(valids) == len(poses)
        
        self._valids = valids
        self._poses = poses
        
    def get_v_p_pairs(self):
        return self._valids, self._poses
<<<<<<< HEAD
    
    def __add__(self, add_vppairs):
        assert isinstance(add_vppairs, VPPairs)
        
        valids, poses = add_vppairs.get_v_p_pairs()
        new_valids = self._valids + valids
        new_poses = self._poses + poses
        new_vppairs = VPPairs(new_valids, new_poses)
        return new_vppairs
=======
>>>>>>> f804d45 (Finisah aim module)

    
    def __len__(self):
        return len(self._valids)
    
    def __add__(self, add_vppairs):
        assert isinstance(add_vppairs, VPPairs)
        
        valids, poses = add_vppairs.get_v_p_pairs()
        new_valids = self._valids + valids
        new_poses = self._poses + poses
        new_vppairs = VPPairs(new_valids, new_poses)
        return new_vppairs

class IABundle():
    def __init__(self, h: int, w: int, data: list, c_idx: list):
        assert isinstance(h, int)
        assert isinstance(w, int)
        assert isinstance(data, list)
        assert isinstance(c_idx, list)
        assert all(isinstance(x, float) for x in data)
        assert all(isinstance(x, int) for x in c_idx)
        assert len(data) == len(c_idx)
   
        self._h = h
        self._w = w
        self._data = data
        self._c_idx = c_idx
        self._len_c_idx = len(c_idx)
        
        

    def get_len_c_idx(self):
        return self._len_c_idx

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

        self._len_c_idx = len(c_idx)
        self._len_r_idx = len(r_idx) 
        
    def get_len_c_idx(self):
        return self._len_c_idx
    
    def get_len_r_idx(self):
        return self._len_r_idx
    
    def get_s(self):
        return self._s
    
    def get_data(self):
        return self._data

    def get_c_idx(self):
        return self._c_idx
    
    def get_pos_ptr(self):
        return self._pos_ptr
    
    def get_r_idx(self):
        return self._r_idx
    
    def get_k_idx(self):
        return self._k_idx
