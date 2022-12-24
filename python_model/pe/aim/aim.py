import sys
sys.path.append('/Users/ray_kuo/Documents/NTUEE/111-1/DCLab/DCLAB-Object-Tracking/python_model')

from config import Config
from specs import VPPairs
from encoder.encoder import Encoder

conf = Config()('PE/AIM')

class AIM():
    arry_size = conf['cmp_array_size']
    
    def __init__(self):
        self._ia_cmp_arr = []
        self._w_cmp_arr = []
        self._ia_c_idx = []
        self._ia_iter_times = 0
    
    def input_ia_c_idx(self, ia_c_idx: list, ia_iter_times: int):
        assert isinstance(ia_c_idx, list)
        assert isinstance(ia_iter_times, int)
        assert all(isinstance(x, int) for x in ia_c_idx)
        
        self._ia_c_idx = ia_c_idx
        self._ia_iter_times = ia_iter_times
    
    def input_w_c_idx_and_compare(self, w_c_idx: list) -> VPPairs:
        assert isinstance(w_c_idx, list)
        assert all(isinstance(x, int) for x in w_c_idx)
        assert len(w_c_idx) == AIM.arry_size
        
        encoder_input = []
        encoder = Encoder()
        valids = []
        poses = []
        v = None
        p = None
        
        # This for loop should be parallel in hardware
        # Marginal probelm (ia channel idx: -1, w channel idx: -2)
        for w in range(AIM.arry_size):
            encoder_input = [] # a row in comaprator array
            encoder.reset()
            
            # Go throught the whole IA channel index array
            for ia_iter in range(self._ia_iter_times):
                encoder_input = []
                
                # Generate Encoder input
                for ia in range(AIM.arry_size):
                    match = 1 if w_c_idx[w] == self._ia_c_idx[ia + ia_iter * Encoder.step_size] else 0
                    encoder_input.append(match)
                
                v, p = encoder.encode(encoder_input)
            
            valids.append(v)
            poses.append(p)
        
        v_p_pairs = VPPairs(valids, poses)
        return v_p_pairs
    
if __name__ == "__main__":
    aim = AIM()
    
    aim.input_ia_c_idx(list(range(64)), 2)
    print("ia_c_idx:", list(range(64)))
    
    input = list(range(17, 49))
    print("Input:", input)
    
    v, p = aim.input_w_c_idx_and_compare(input).get_v_p_pairs()
    print("val:", v)
    print("pos:", p)
