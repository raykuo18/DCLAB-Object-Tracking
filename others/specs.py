import yaml

from yaml.loader import SafeLoader

from model import Net
from model import AlexNetV1_fused

from utils import *

import torch
import math
# from operator import add
import numpy as np
np.random.seed(0)
# parser = argparse.ArgumentParser()

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

class HWRKS():
    def __init__(self, h:int, w:int, r:int, k:int, s:int):
        assert isinstance(h, int)
        assert isinstance(w, int)
        assert isinstance(r, int)
        assert isinstance(k, int)
        assert isinstance(s, int)

        self._h = h
        self._w = w
        self._r = r
        self._k = k
        self._s = s

    def get_hwrks(self):
        return (self._h, self._w, self._r, self._k, self._s)

    def get_row_col_ch(self):
        row, col, ch = self._h-self._r, self._w-self._s, self._k 
        return row, col, ch
        
class OA_Addr():
    def __init__(self, row:int, col:int, ch:int):
        assert isinstance(row, int)
        assert isinstance(col, int)
        assert isinstance(ch, int)

        self._row = row
        self._col = col
        self._ch = ch
    
    def get_addr(self):
        return (self._row, self._col, self._ch)

class OA_AddrController():
    def __init__(self):
        pass
    def get_case_OA_Addrs(self, HWRKSs):

        assert isinstance(HWRKSs, list)
        assert len(HWRKSs) == 3
        assert all(isinstance(hwrks, HWRKS) for hwrks in HWRKSs)

        row0, col0, ch0 = HWRKSs[0].get_row_col_ch()
        row1, col1, ch1 = HWRKSs[1].get_row_col_ch()
        row2, col2, ch2 = HWRKSs[2].get_row_col_ch()

        OA_Addr0 = OA_Addr(row=row0, col=col0, ch=ch0)
        OA_Addr1 = OA_Addr(row=row1, col=col1, ch=ch1)
        OA_Addr2 = OA_Addr(row=row2, col=col2, ch=ch2)
        OA_Addrs = [OA_Addr0, OA_Addr1, OA_Addr2]

        comp_01 = self.compare_OA_Addrs(OA_Addr0, OA_Addr1)
        comp_12 = self.compare_OA_Addrs(OA_Addr1, OA_Addr2)

        if (comp_01 and comp_12):
            _case = 0
        elif (comp_01 and  not comp_12):
            _case = 1
        elif (not comp_01 and  comp_12):
            _case = 2
        elif (not comp_01 and  not comp_12):
            _case = 3
        else:
            print(f"OA_Addr0._ch: {OA_Addr0._ch}")
            print(f"OA_Addr1._ch: {OA_Addr1._ch}")
            print(f"OA_Addr2._ch: {OA_Addr2._ch}")
            raise ValueError("OA_Addrs.ch emerge weird condition")

        return _case, OA_Addrs
    
    def compare_OA_Addrs(self, oa_addr0: OA_Addr, oa_addr1: OA_Addr):
            if (oa_addr0._row == oa_addr1._row and oa_addr0._col == oa_addr1._col and oa_addr0._ch == oa_addr1._ch):
                return True
            else:
                return False

class AIM():
    def __init__(self, N: int):
        assert isinstance(N, int)
        self._N = N
        self._IA_c_idx = None
        self._V = [0]*self._N
        self._P = [0]*self._N
    
    def put_IA_c_idx(self, IA_c_idx: list):
        assert isinstance(IA_c_idx, list)
        self._IA_c_idx = IA_c_idx
    
    def get_VPpairs(self, W_c_idx: list):

        assert self._IA_c_idx != None
        assert isinstance(W_c_idx,  list)

        # print(f"len(W_c_idx): {len(W_c_idx)}")
        assert len(W_c_idx) == self._N

        for w in range(self._N):
            if (W_c_idx[w] not in self._IA_c_idx):
                self._V[w] = 0
                self._P[w] = None
            else:
                self._V[w] = 1
                self._P[w] = self._IA_c_idx.index(W_c_idx[w])
        return self._V, self._P
    
class Sequence_Decoder():
    def __init__(self):
        
        self.IA_buffer0 = [0]*3
        self.IA_buffer1 = [0]*3
        self.W_buffer0 = [0]*3
        self.W_buffer1 = [0]*3

        self._V = None
        self._P = None
        self._VPlen = 0

        self._counter = 0
        self._which_buffer = False # False:0 or True:1
    
    def put_VPpairs(self, V: list, P: list):
        assert isinstance(V, list)
        assert isinstance(P, list)
        assert len(V) == len(P)

        self._V = V
        self._V = P
        self._VPlen = len(V)
        
    # def get_WIApairs(self): # todo how to compute r, k and what's use of  pos_ptr
    #     buffer_index = 0
    #     while (buffer_index < 3 and self._counter < self._VPlen):
    #         if (self._V[self._counter] == 1):
    #             if (self._which_buffer):
    #                 self.IA_buffer1                
    #         return
    #     pass
    

class PE():
    def __init__(self, id: int):
        self._N = 32
        self._AIM = AIM(N=self._N)
        self._id = id
        self._OAshape = None
        self._OAbuffer = None

        
    def put_wbundle(self, wbundle: WBundle):
        assert isinstance(wbundle, WBundle)
        self._wbundle = wbundle
        self._V = [0]*self._wbundle.get_len_c_idx()
        self._P = [0]*self._wbundle.get_len_c_idx()

    def init_VPpairs(self, iabundle: IABundle):
        assert isinstance(iabundle, IABundle)

        
        IA_c_idx = iabundle.get_c_idx()
        self._AIM.put_IA_c_idx(IA_c_idx)

        W_c_idx = self._wbundle.get_c_idx()
        W = math.ceil( self._wbundle.get_len_c_idx()/self._N)

        w_len_c = self._wbundle.get_len_c_idx()
        for w_start in range(W):
            
            if ( w_start == W-1 and W*self._N > w_len_c):
                difference = W*self._N - w_len_c
                V, P = self._AIM.get_VPpairs(W_c_idx[w_start*self._N : (w_start+1)*self._N ] + [0]*difference)
                self._V[w_start*self._N : w_len_c] = V[0: self._N - difference]
                self._P[w_start*self._N : w_len_c] = P[0: self._N - difference]
            else:
                V, P = self._AIM.get_VPpairs(W_c_idx[w_start*self._N : (w_start+1)*self._N ])
                self._V[w_start*self._N : w_start*(self._N+1)] = V
                self._P[w_start*self._N : w_start*(self._N+1)] = P
        return

    def put_OAshape(self, Hout: int, Wout: int, Cout: int):
        assert isinstance(Hout, int)
        assert isinstance(Wout, int)
        assert isinstance(Cout, int)
        self._OAshape = (Hout, Wout, Cout)
        
    def get_OA(self):
        Hout, Wout, Cout = self._OAshape

        self._OAbuffer = np.random.rand(3,Cout,1)
        self._OAbuffer -= 0.5
        self._OAbuffer = self._OAbuffer.tolist()
        # self._OAbuffer = [ [1]*Cout for x in range(3)      ] 
        return self._OAbuffer


  
class WMemory():
    def __init__(self, weight_path='checkpoints/siamfc_alexnet_e50_fused_prune_80.pth'):

        pass

        # ---------------- for testing ---------------------------
        self._model = Net(backbone=AlexNetV1_fused())
        self._model.load_state_dict(torch.load(weight_path, map_location='cpu'))
        self._model.eval()

        self._weights = {}

        for name, module in self._model.named_modules():
            if isinstance(module, torch.nn.Conv2d):
                self._weights[name] = module.weight


    def get_WBundle(self, layer: int, group: int, s: int): # todo tsai

        assert isinstance(layer, int)
        assert isinstance(group, int)
        assert isinstance(s, int)
        assert 1 <= layer <=5

        WB = loadWBundle(f"WBundles_50000_fused/layer{layer}_g{group}_s{s}.json")

        
        return WBundle(s=WB['s'], data=WB['data'], c_idx=WB['c_idx'], pos_ptr=WB['pos_ptr'], r_idx=WB['r_idx'], k_idx=WB['k_idx'] )

    # ---------------- for testing ---------------------------

    def get_Weight(self, layer: int, index: int):  # todo yu

        assert isinstance(layer, int)
        assert isinstance(index, int)
        assert 1 <= layer <=5

        if layer == 1:
            return None
        elif layer == 3:
            return self._weights[f'backbone.conv3.0'][:, :, :, index]  # Co, Ci, kh, kw
        else:
            return None

    def get_Weight_shape(self, layer: int):  # todo yu

        assert isinstance(layer, int)
        assert 1 <= layer <=5

        if layer == 1:
            return None
        elif layer == 3:
            return self._weights[f'backbone.conv3.0'].shape  # Co, Ci, kh, kw
        else:
            return None

class IAMemory():
    def __init__(self, weight_path='checkpoints/siamfc_alexnet_e50_fused_prune_80.pth'):

        
        #---------------- for testing ---------------------------

        self._model = Net(backbone=AlexNetV1_fused())
        self._model.load_state_dict(torch.load(weight_path, map_location='cpu'))
        self._model.eval()

        self._IAs = {}

        def forward_hook(name):
            def hook(module, in_act, out_act):
                self._IAs[name] = in_act[0]
            return hook
        for name, module in self._model.named_modules():
            if isinstance(module, torch.nn.Conv2d):
                module.register_forward_hook(forward_hook(name))
        
        self._batch_size = 1
        self._testinput = torch.ones(self._batch_size, 3, 255, 255)
        self._test_output = self._model(self._testinput)

    def get_IABundle(self, layer: int, h: int, w: int): # tsai todo 

        assert isinstance(layer, int)
        assert isinstance(h, int)
        assert isinstance(w, int)
        assert 1 <= layer <=5

        IAB = load_IABundle(f'IABundles/layer{layer}.json')

        return IABundle(h=h, w=w, data=IAB[f"{h}_{w}"]["data"], c_idx=IAB[f"{h}_{w}"]["c_idx"])
    

    

    # ---------------- for testing ---------------------------

    def get_IA(self, layer: int, row: int, col: int): 

        assert isinstance(layer, int)
        assert isinstance(row, int)
        assert isinstance(col, int)
        assert 1 <= layer <=5
        return self._IAs[f'backbone.conv{layer}.0'][:, :, row, col] # batch_size, Ci, Hi, Wi => batch_size, Ci

    def get_IA_shape(self, layer: int): 
        assert isinstance(layer, int)
        assert 1 <= layer <=5
        return self._IAs[f'backbone.conv{layer}.0'].shape


    def put_IA(self, layer: int, row: int, col: int): # yu todo 

        pass
      
class Top():
    def __init__(self ):
        self._WMemory  = WMemory()
        self._IAMemory = IAMemory()
        self._Specs = Specs()
        self._PEs = [ [PE(row*3+col) for col in range(3)] for row in range(7)]

        self._Ho =   [-1, 14, 12]
        self._Wo =   [-1, 14, 12]
        self._Co =   [-1, 8,  8]
        self._pool = [-1, False, True]

        self._IAshape =     [-1, (1,3,16,16), (1,8,14,14) ]
        self._Weightshape = [-1, (8,3,3,3), (8,8,3,3) ]

        self._OAreducebuffers = None
        self._OAbuffers = None
        self._IAbuffers = None
        
        
        self._OA_counter = 0
        self._OA_c_idx = None
        self._OA_data = None
        self._OA_offset = None
        self._OA_len = None

        

    def put_PEs_wbundles(self, layer: int):
        WBundles = [ self._WMemory.get_WBundle(layer=layer, group=0, s=i) for i in range(3)]
        for row in range(7):
            for col in range(3):
                self._PEs[row][col].put_wbundle(WBundles[col])
                self._PEs[row][col].put_OAshape(self._Ho[layer], self._Wo[layer], self._Co[layer])

        self._OAreducebuffers = [ [[ [0.0] for ch in range(self._Co[layer]) ] for row in range(3) ] for id in range(9)]
        self._OAbuffers = [[[0.0]*self._Co[layer] for col in range(self._Wo[layer]) ] for row in range(self._Ho[layer]) ]
        
        self._OA_counter = 0
        self._OA_c_idx = [0]*(self._Ho[layer]*self._Wo[layer]*self._Co[layer])
        self._OA_data = [0.0]*(self._Ho[layer]*self._Wo[layer]*self._Co[layer])
        self._OA_offset = [0]*(self._Ho[layer]*self._Wo[layer])
        self._OA_len = [0]*(self._Ho[layer]*self._Wo[layer])
        


    def Conv(self, layer: int):

        assert isinstance(layer, int)
        assert 1 <= layer <=5

        # Start computing
       
        N, Ci, Hi, Wi = self._IAshape[layer] # (batch_size, Ci, H, W)
        Co, Ci, kh, kw = self._Weightshape[layer] # (Co, Ci, kh, kw)

        w_start_max = math.ceil(Wi/7) 

        print(f"layer: {layer}")
        print(f"N, Ci, Hi, Wi = {N, Ci, Hi, Wi}")
        print(f"Co, Ci, kh, kw = {Co, Ci, kh, kw}")
        print(f"w_start_max: {w_start_max}")

        self._OAbuffers = np.array(self._OAbuffers)
        self._OAreducebuffers = np.array(self._OAreducebuffers)
        for w_start in range( w_start_max ) :
            for h in range(Hi):
                ## Init IABundle
                # IABundles = [ self._IAMemory.get_IABundle(layer=layer, h=h, w=w_start*7 + i) for i in range(7)] # 7
                for row in range(7):
                    for col in range(3):
                        self._PEs[row][col].get_OA()
                
                ## Put to OAreducebuffers
                for id in range(9):
                    if (id==0):
                        self._OAreducebuffers[id] = np.array(self._PEs[0][2]._OAbuffer[:])#.tolist()
                    elif (id==1):
                        self._OAreducebuffers[id] = ( np.array(self._PEs[0][1]._OAbuffer[:]) + np.array(self._PEs[1][2]._OAbuffer[:]) )#.tolist()
                    elif (id==7):
                        self._OAreducebuffers[id] = ( np.array(self._PEs[5][0]._OAbuffer[:]) + np.array(self._PEs[6][1]._OAbuffer[:]) )#.tolist()  
                    elif (id==8):
                        self._OAreducebuffers[id] = np.array(self._PEs[6][0]._OAbuffer[:])#.tolist
                    else:
                        self._OAreducebuffers[id] = ( np.array(self._PEs[id-2][0]._OAbuffer[:]) + np.array(self._PEs[id-1][1]._OAbuffer[:]) + np.array(self._PEs[id][2]._OAbuffer[:]) )#.tolist()  
                       
                
                ## Put to OAbuffers

                ## self._OAbuffers       [  row, col,      ch  ]
                ## self._OAreducebuffers [  id,  row(0:2), ch  ]
                if (w_start == 0):
                    if (h == 0):
                        self._OAbuffers[0,0:7,:] += self._OAreducebuffers[2:9,2,:,-1]
                    elif (h == 1):
                        self._OAbuffers[0,0:7,:] += self._OAreducebuffers[2:9,1,:,-1]
                        self._OAbuffers[1,0:7,:] += self._OAreducebuffers[2:9,2,:,-1]
                    elif (h == Hi-2):
                        self._OAbuffers[h-2,0:7,:] += self._OAreducebuffers[2:9,0,:,-1]
                        self._OAbuffers[h-1,0:7,:] += self._OAreducebuffers[2:9,1,:,-1]  
                    elif (h == Hi-1):
                        self._OAbuffers[h-2,0:7,:] += self._OAreducebuffers[2:9,0,:,-1]
                    else:
                        self._OAbuffers[h-2,0:7,:] += self._OAreducebuffers[2:9,0,:,-1]
                        self._OAbuffers[h-1,0:7,:] += self._OAreducebuffers[2:9,1,:,-1]
                        self._OAbuffers[h-0,0:7,:] += self._OAreducebuffers[2:9,2,:,-1]
                elif (w_start == w_start_max-1):
                    row_left = w_start*7-2
                    row_right = Wi-1
                    # row_right = self._Wo[layer]+1
                    diff = row_right-row_left -1
                    if (h == 0):
                        self._OAbuffers[0,row_left:row_right,:] += self._OAreducebuffers[0:diff,2,:,-1]
                    elif (h == 1):
                        self._OAbuffers[0,row_left:row_right,:] += self._OAreducebuffers[0:diff,1,:,-1]
                        self._OAbuffers[1,row_left:row_right,:] += self._OAreducebuffers[0:diff,2,:,-1]
                    elif (h == Hi-2):
                        self._OAbuffers[h-2,row_left:row_right,:] += self._OAreducebuffers[0:diff,0,:,-1]
                        self._OAbuffers[h-1,row_left:row_right,:] += self._OAreducebuffers[0:diff,1,:,-1]  
                    elif (h == Hi-1):
                        self._OAbuffers[h-2,row_left:row_right,:] += self._OAreducebuffers[0:diff,0,:,-1]
                    else:
                        self._OAbuffers[h-2,row_left:row_right,:] += self._OAreducebuffers[0:diff,0,:,-1]
                        self._OAbuffers[h-1,row_left:row_right,:] += self._OAreducebuffers[0:diff,1,:,-1]
                        self._OAbuffers[h-0,row_left:row_right,:] += self._OAreducebuffers[0:diff,2,:,-1]
                else:
                    row_left = w_start*7-2
                    row_right = (w_start+1) *7
                    if (h == 0):
                        self._OAbuffers[0,row_left:row_right,:] += self._OAreducebuffers[0:9,2,:,-1]
                    elif (h == 1):
                        self._OAbuffers[0,row_left:row_right,:] += self._OAreducebuffers[0:9,1,:,-1]
                        self._OAbuffers[1,row_left:row_right,:] += self._OAreducebuffers[0:9,2,:,-1]
                    elif (h == Hi-2):
                        self._OAbuffers[h-2,row_left:row_right,:] += self._OAreducebuffers[0:9,0,:,-1]
                        self._OAbuffers[h-1,row_left:row_right,:] += self._OAreducebuffers[0:9,1,:,-1]  
                    elif (h == Hi-1):
                        self._OAbuffers[h-2,row_left:row_right,:] += self._OAreducebuffers[0:9,0,:,-1]
                    else:
                        self._OAbuffers[h-2,row_left:row_right,:] += self._OAreducebuffers[0:9,0,:,-1]
                        self._OAbuffers[h-1,row_left:row_right,:] += self._OAreducebuffers[0:9,1,:,-1]
                        self._OAbuffers[h-0,row_left:row_right,:] += self._OAreducebuffers[0:9,2,:,-1]
                # self._OAbuffers = self._OAbuffers.tolist()
                # self._OAreducebuffers =self._OAreducebuffers.tolist()
                
                
                ## ReLU
                if (h >= 2):
                    # self._OAbuffers = np.array(self._OAbuffers)
                    if (w_start == 0):                  
                        self._OAbuffers[h-2,0:5,:] *= (self._OAbuffers[h-2,0:5,:] > 0)
                    elif (w_start == w_start_max-1):
                        row_left = w_start*7-2
                        row_right = self._Wo[layer]+1
                        self._OAbuffers[h-2,row_left:row_right,:] *=  (self._OAbuffers[h-2,row_left:row_right,:]>0)
                    else:
                        row_left = w_start*7-2
                        row_right = (w_start+1)*7
                        self._OAbuffers[h-2,row_left:row_right-2,:] *= (self._OAbuffers[h-2,row_left:row_right-2,:]>0)
                    # self._OAbuffers = self._OAbuffers.tolist()
        
        ## Maxpool
        if (self._pool[layer]):
            tmp00 = self._OAbuffers[::2, ::2, :]
            tmp01 = self._OAbuffers[::2, 1::2, :]
            tmp10 = self._OAbuffers[1::2, ::2, :]
            tmp11 = self._OAbuffers[1::2, ::2, :]

            tmp0 = np.maximum(tmp00,tmp01)
            tmp1 = np.maximum(tmp0 ,tmp10)
            tmp2 = np.maximum(tmp1 ,tmp11)

            self._OAbuffers[0:(self._Ho[layer] >>1), 0:(self._Wo[layer]>>1), :] = tmp2

        
        
        
        self._OAbuffers = self._OAbuffers.tolist()
        self._OAreducebuffers =self._OAreducebuffers.tolist()      




        ## Compress
        if (self._pool[layer]):
            for _row in range(self._Ho[layer]>>1):
                for _col in range(self._Wo[layer]>>1):
                    self._OA_offset[_row*self._Ho[layer]+_col] = self._OA_counter
                    for _ch in range(self._Co[layer]): 
                        if  (self._OAbuffers[_row][_col][_ch] > 0 ):
                            try: 
                                # print(f"r:{_row}, c: {_col}, ch: {_ch}, ctr{self._OA_counter}")
                                self._OA_data[self._OA_counter]  =  self._OAbuffers[_row][_col][_ch]
                                self._OA_c_idx[self._OA_counter] =  _ch
                                self._OA_counter += 1
                            except: 
                                print(f"r:{_row}, c: {_col}, ch: {_ch}, ctr{self._OA_counter}")
                                print(len(self._OA_data))
                                print(self._Ho[layer],self._Wo[layer],self._Co[layer])
                                print(self._Ho[layer]*self._Wo[layer]*self._Co[layer])
                                raise ValueError("")
                    self._OA_len[_row*self._Ho[layer]+_col] = self._OA_counter - self._OA_offset[_row*self._Ho[layer]+_col]
        else:
            for _row in range(self._Ho[layer]):
                for _col in range(self._Wo[layer]):
                    self._OA_offset[_row*self._Ho[layer]+_col] = self._OA_counter
                    for _ch in range(self._Co[layer]): 
                        if  (self._OAbuffers[_row][_col][_ch] > 0 ):
                            try: 
                                # print(f"r:{_row}, c: {_col}, ch: {_ch}, ctr{self._OA_counter}")
                                self._OA_data[self._OA_counter]  =  self._OAbuffers[_row][_col][_ch]
                                self._OA_c_idx[self._OA_counter] =  _ch
                                self._OA_counter += 1
                            except: 
                                print(f"r:{_row}, c: {_col}, ch: {_ch}, ctr{self._OA_counter}")
                                print(len(self._OA_data))
                                print(self._Ho[layer],self._Wo[layer],self._Co[layer])
                                print(self._Ho[layer]*self._Wo[layer]*self._Co[layer])
                                raise ValueError("")
                    self._OA_len[_row*self._Ho[layer]+_col] = self._OA_counter - self._OA_offset[_row*self._Ho[layer]+_col]
                                


                 
                    







            
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
            #     print(key, ':', value)#
        return data
    
if __name__ == '__main__':
    Specs()
    print(Specs.specs)