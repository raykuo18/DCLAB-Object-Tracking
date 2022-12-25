import sys
sys.path.append('/Users/ray_kuo/Documents/NTUEE/111-1/DCLab/DCLAB-Object-Tracking/python_model')

from specs import VPPairs
from three_way_encoder.three_way_encoder import ThreeWayEncoder

class SequenceDecoder():
    def __init__(self) -> None:
        self.three_way_encoder = ThreeWayEncoder()
        # self.valids = []
        # self.poses = []
        self.idx = 0
        # self.write_addr = 0
        
    def decode(self, vp_pairs: VPPairs):
        valids, poses = vp_pairs.get_v_p_pairs()
        w_data_addr_arr = []
        ia_data_addr_arr = []
        
        while self.idx <= len(vp_pairs):
            dec_input = valids[self.idx:self.idx+3]
            while len(dec_input) < 3:
                dec_input += [0]
            w_data_addr, step, write_data = self.three_way_encoder.input_valid_bits(dec_input)
            self.idx += step
            if write_data:
                ia_data_addr = poses[w_data_addr]
                w_data_addr_arr.append(w_data_addr)
                ia_data_addr_arr.append(ia_data_addr)
            
        return w_data_addr_arr, ia_data_addr_arr
    
    def reset(self):
        self.idx = 0
        self.three_way_encoder.reset()
        
if __name__ == "__main__":
    valids = [0] * 5 + [1] * 3 + [0,1,0,1]
    poses = list(range(100, 112))
    print(valids)
    print(poses)
    print('-----------------------')
    vp_pairs = VPPairs(valids, poses)
    sequence_decoder = SequenceDecoder()
    w_data_addr_arr, ia_data_addr_arr = sequence_decoder.decode(vp_pairs)
    print(w_data_addr_arr)
    print(ia_data_addr_arr)
    print('-----------------------')
    sequence_decoder.reset()
    w_data_addr_arr, ia_data_addr_arr = sequence_decoder.decode(vp_pairs)
    print(w_data_addr_arr)
    print(ia_data_addr_arr)