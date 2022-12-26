from specs import *
import numpy as np



WMem = WMemory()

Wbundles = [[None, None, None]] + [ [WMem.get_WBundle(layer=layer, group=0, s=s) for s in range(3)] for layer in range(1,3) ]

layer = 2
s = 1
for layer in range(1,3):
    for s in range(3):
        W = Wbundles[layer][s]
        print(f"layer: {layer}, s: {s}, len_c: {W.get_len_c_idx()}, len_r: {W.get_len_r_idx()}, max_data: {max(W.get_data())}, min_data: {min(W.get_data())}, max_c: {max(W.get_c_idx())} ")


DIR = './verilog_weights'


def write_w_data():
    FILENAME = DIR + '/w_data.sv'
    int_bits = 5
    dec_bits = 16-int_bits
    
    with open(FILENAME , 'w') as f:
        f.write("// w_data\n")
        for layer in range(1,3):
            for s in range(3):
                W = Wbundles[layer][s]
                data = np.array(W.get_data())      
                data = (np.round(data*2**dec_bits)).astype(int)
                data = [np.binary_repr(i,16) for i in data]
                # data = [ b[0:5]+"_"+b[5:16]for b in data]
                f.write(f"    localparam logic signed [`W_DATA_BITWIDTH-1:0] w_data_l{layer}_s{s} [0:`W_C_LENGTH_L{layer}_S{s}-1] =\n")
                f.write("    '{\n")
                for b in data[:-1]:
                    f.write(f"        `W_DATA_BITWIDTH'b{b},\n")
                f.write(f"        `W_DATA_BITWIDTH'b{b}\n")
                f.write("    };\n")
        f.write("\n")      
        f.write("// w_data\n")



def write_w_c_idx():
    TARGET = "w_c_idx"
    FILENAME = DIR + f'/{TARGET}.sv'
    BITWIDTH = "W_C_BITWIDTH"
    LEN = "C"
    bitwidth = 5

    with open(FILENAME , 'w') as f:
        f.write(f"// {TARGET}\n")
        for layer in range(1,3):
            for s in range(3):
                W = Wbundles[layer][s]
                data = np.array(W.get_c_idx())      
                data = [np.binary_repr(i,bitwidth) for i in data]
                # data = [ b[0:5]+"_"+b[5:16]for b in data]
                f.write(f"    localparam logic [`{BITWIDTH}-1:0] {TARGET}_l{layer}_s{s} [0:`W_{LEN}_LENGTH_L{layer}_S{s}-1] =\n")
                f.write("    '{\n")
                for b in data[:-1]:
                    f.write(f"        `{BITWIDTH}'b{b},\n")
                f.write(f"        `{BITWIDTH}'b{b}\n")
                f.write("    };\n")
        f.write("\n")      
        f.write(f"// {TARGET}\n")       




def write_w_r_idx():
    TARGET = "w_r_idx"
    FILENAME = DIR + f'/{TARGET}.sv'
    BITWIDTH = "W_R_BITWIDTH"
    LEN = "R"
    bitwidth = 2

    with open(FILENAME , 'w') as f:
        f.write(f"// {TARGET}\n")
        for layer in range(1,3):
            for s in range(3):
                W = Wbundles[layer][s]
                data = np.array(W.get_r_idx())      
                data = [np.binary_repr(i,bitwidth) for i in data]
                # data = [ b[0:5]+"_"+b[5:16]for b in data]
                f.write(f"    localparam logic [`{BITWIDTH}-1:0] {TARGET}_l{layer}_s{s} [0:`W_{LEN}_LENGTH_L{layer}_S{s}-1] =\n")
                f.write("    '{\n")
                for b in data[:-1]:
                    f.write(f"        `{BITWIDTH}'b{b},\n")
                f.write(f"        `{BITWIDTH}'b{b}\n")
                f.write("    };\n")
        f.write("\n")      
        f.write(f"// {TARGET}\n")       




def write_w_k_idx():
    TARGET = "w_k_idx"
    FILENAME = DIR + f'/{TARGET}.sv'
    BITWIDTH = "W_K_BITWIDTH"
    LEN = "R"
    bitwidth = 5

    with open(FILENAME , 'w') as f:
        f.write(f"// {TARGET}\n")
        for layer in range(1,3):
            for s in range(3):
                W = Wbundles[layer][s]
                data = np.array(W.get_k_idx())      
                data = [np.binary_repr(i,bitwidth) for i in data]
                # data = [ b[0:5]+"_"+b[5:16]for b in data]
                f.write(f"    localparam logic [`{BITWIDTH}-1:0] {TARGET}_l{layer}_s{s} [0:`W_{LEN}_LENGTH_L{layer}_S{s}-1] =\n")
                f.write("    '{\n")
                for b in data[:-1]:
                    f.write(f"        `{BITWIDTH}'b{b},\n")
                f.write(f"        `{BITWIDTH}'b{b}\n")
                f.write("    };\n")
        f.write("\n")      
        f.write(f"// {TARGET}\n")       





def write_w_pos_ptr():
    TARGET = "w_pos_ptr"
    FILENAME = DIR + f'/{TARGET}.sv'
    BITWIDTH = "W_POS_PTR_BITWIDTH"
    LEN = "R"
    bitwidth = 11

    with open(FILENAME , 'w') as f:
        f.write(f"// {TARGET}\n")
        for layer in range(1,3):
            for s in range(3):
                W = Wbundles[layer][s]
                data = np.array(W.get_pos_ptr())      
                data = [np.binary_repr(i,bitwidth) for i in data]
                # data = [ b[0:5]+"_"+b[5:16]for b in data]
                f.write(f"    localparam logic [`{BITWIDTH}-1:0] {TARGET}_l{layer}_s{s} [0:`W_{LEN}_LENGTH_L{layer}_S{s}-1] =\n")
                f.write("    '{\n")
                for b in data[:-1]:
                    f.write(f"        `{BITWIDTH}'b{b},\n")
                f.write(f"        `{BITWIDTH}'b{b}\n")
                f.write("    };\n")
        f.write("\n")      
        f.write(f"// {TARGET}\n")       




# write_w_data()
# write_w_c_idx()
# write_w_r_idx()
# write_w_k_idx()
# write_w_pos_ptr()


#  '{
#      24'b1000_0000_0_1001_000_0010_1100,
#      24'b1001_1000_0_0001_000_0010_1100,
#      24'b0100_0010_0_1110_000_0010_1100,
#      24'b0000_0000_0_0110_000_0010_1100,
#      24'b0000_0000_0_1010_000_0010_1100,
#      24'b1010_1000_0_0010_000_0010_1100,
#      24'b0000_0000_0_1111_000_0010_1100
#  };














