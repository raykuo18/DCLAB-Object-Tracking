class ThreeWayEncoder():
    def __init__(self) -> None:
        self.idx_base = 0
        self.write_addr = 0
        
    def input_valid_bits(self, valid_bits: list):
        assert isinstance(valid_bits, list)
        assert all(isinstance(x, int) for x in valid_bits)
        assert len(valid_bits) == 3
        
        w_data_addrs = [self.idx_base, self.idx_base+1, self.idx_base+2]
        # case = None
        # write_data = 0
        
        
        if valid_bits[0] == 1: # case 3
            temp_w_data_addr = 0
            self.idx_base += 1
            step = 1
            write_data = 1
        elif valid_bits[1] == 1: # case 2
            temp_w_data_addr = 1
            self.idx_base += 2
            step = 2
            write_data = 1
        elif valid_bits[2] == 1: # case 1
            temp_w_data_addr = 2
            self.idx_base += 3
            step = 3
            write_data = 1
        else: # case 0
            temp_w_data_addr = 0
            self.idx_base += 3
            step = 3
            write_data = 0
            
        w_data_addr = w_data_addrs[temp_w_data_addr]
            
        return w_data_addr, step, write_data
            
    def reset(self):
        self.idx_base = 0
        self.write_addr = 0
        
if __name__ == '__main__':
    three_way_encoder =  ThreeWayEncoder()
    valids = [0] * 5 + [1] * 3 + [0,1,0,1]
    print(valids)
    idx = 0
    
    while True:
        input = valids[idx:idx+3]
        while len(input) < 3:
            input += [0]
        w_data_addr, step, write_data = three_way_encoder.input_valid_bits(input)
        print("input:", input)
        print("w_data_addr:", w_data_addr)
        print("step:", step)
        print("write_data:", write_data)
        idx += step
        if idx > len(valids):
            break
        
    three_way_encoder.reset()
    idx = 0
    
    while True:
        input = valids[idx:idx+3]
        while len(input) < 3:
            input += [0]
        w_data_addr, step, write_data = three_way_encoder.input_valid_bits(input)
        print("input:", input)
        print("w_data_addr:", w_data_addr)
        print("step:", step)
        print("write_data:", write_data)
        idx += step
        if idx > len(valids):
            break