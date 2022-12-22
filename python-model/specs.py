import yaml

from yaml.loader import SafeLoader

from model import Net
from model import AlexNetV1_fused

from utils import *

import torch
import math

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


class HWRK():
    def __init__(self, h:int, w:int, r:int, k:int):
        assert isinstance(h, int)
        assert isinstance(w, int)
        assert isinstance(r, int)
        assert isinstance(k, int)

        self._h = h
        self._w = w
        self._r = r
        self._k = k

    def get_hwrk(self):
        return (self._h, self._w, self._r, self._k)

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
        
        self._HWRKs = None
        

    def put_HWRKs(self, HWRKs: list):
        assert isinstance(HWRKs, list)
        assert len(HWRKs) == 3
        assert all(isinstance(hwrk, HWRK) for hwrk in HWRKs)

        self._HWRKs = HWRKs

    def get_case(self):
        assert self._HWRKs != None

        # todo
        _case = 0 # 0, 1, 2, 3

        return _case

    def get_OA_Addrs(self):

        # todo
        OA_Addr0 = OA_Addr(row=0, col=0, ch=0)
        OA_Addr1 = OA_Addr(row=0, col=0, ch=0)
        OA_Addr2 = OA_Addr(row=0, col=0, ch=0)

        OA_Addrs = [OA_Addr0, OA_Addr1, OA_Addr2]
        return OA_Addrs


    

















class Fake_PE_output():
    def __init__(self, row: int, col: int, ch: int, data: float):
        assert isinstance(row, int)
        assert isinstance(col, int)
        assert isinstance(ch, int)
        assert isinstance(data, float)

        self._row = row
        self._col = col
        self._ch = ch
        self._data = data

    def get_row_col_ch(self):
        return(self._row, self._col, self._ch)

    def get_data(self):
        return self._data
        

      

    

class Fake_PE_Arrays():
    def __init__(self, row: int, col: int):

        assert isinstance(row, int)  # row should be 7
        assert isinstance(col, int)  # col should be 3
    
        self._row = row
        self._col = col
        self._WBundles = None   # should be list of WBundle
        self._IABundles = None  # should be list of IABundle

        # --- For testing, yu todo  ---
        self._Ws = None  # should be list of torch.Tensor(Co, Ci, kh, kw)
        self._IAs = None 
        self._temp_OAs = None
    
    def put_WBundles(self,  WBundles: list):

        assert isinstance(WBundles, list)
        assert all(isinstance(x, WBundle) for x in WBundles)
        assert len(WBundles) == self._col

        self._WBundles = WBundles
    
    def put_IABundles(self,  IABundles: list):

        assert isinstance(IABundles, list)
        assert all(isinstance(x, IABundle) for x in IABundles)
        assert len(IABundles) == self._row

        self._IABundles = IABundles
    
    def get_PE_output(self):  
        # assert isinstance(PE_index, int)
        # assert 0 <= PE_index <= self._row + self._col - 2 

        kh = 3
        width = 1
        Co = 10

        temp = [ [ [Fake_PE_output(row=0, col=col, ch=ch, data=1.0) for ch in range(Co)] for col in range(width)] for row in range(kh) ]

        return [temp for _ in range(self._row + self._col - 1 )]


    # ------------------------ For testing, yu todo  ----------------------

    def put_Weights(self,  Weights: list):
        assert isinstance(Weights, list)
        assert all(isinstance(x, torch.Tensor) for x in Weights)
        assert len(Weights) == self._col
        self._Ws = Weights
    
    def put_IAs(self, IAs: list):
        assert isinstance(IAs, list)
        assert all(isinstance(x, torch.Tensor) for x in IAs)
        assert len(IAs) == self._row

        self._IAs = IAs

    def put_temp_OAs(self, temp_OAs: list):
        assert isinstance(temp_OAs, list)
        assert all(isinstance(x, torch.Tensor) for x in temp_OAs)
        assert len(temp_OAs) == self._col - 1 

        self._temp_OAs = temp_OAs
    
    def get_OAs(self): # yu todo
        assert self._Ws != None
        assert self._IAs != None
        assert self._temp_OAs != None

        Co, Ci, kh = self._Ws[0].shape # 384, 256, 3
        OA = [torch.zeros(1, Co, kh, 1) for x in range(self._row + self._col - 1)]
        return  OA
    








class WMemory():
    def __init__(self, weight_path='../checkpoints/siamfc_alexnet_e50_fused_prune_80.pth'):

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

        WB = loadWBundle(f"../WBundles/layer{layer}_g{group}_s{s}.json")

        
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
    def __init__(self, weight_path='../checkpoints/siamfc_alexnet_e50_fused_prune_80.pth'):

        
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

        IAB = load_IABundle(f'../IABundles/layer{layer}.json')

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

        # self._states = Enum(
        #     'states',(
        #         'IDLE',
        #         'INIT'
        #     )
        # )
        self._WMemory  = WMemory()
        self._IAMemory = IAMemory()
        self._Specs = Specs()
        self._Fake_PE_Arrays = Fake_PE_Arrays(row=self._Specs.specs['Fake_PE_Arrays']['row'], col=self._Specs.specs['Fake_PE_Arrays']['col'] )

        self.state = 'IDLE'

        self._OA_buffer = None

    def Conv(self, layer: int, group: int, S: int ):

        assert isinstance(layer, int)
        assert isinstance(group, int)
        assert isinstance(S, int)
        assert S%3 == 0 # S should be 0, 3, 6, 9
        assert 1 <= layer <=5

        WBundles = [ self._WMemory.get_WBundle(layer=layer, group=group, s=S+i) for i in range(3)]
        self._Fake_PE_Arrays.put_WBundles(WBundles)

        # Start computing
        N, Ci, Hi, Wi = self._IAMemory.get_IA_shape(layer=layer) # (batch_size, Ci, H, W)
        Co, Ci, kh, kw = self._WMemory.get_Weight_shape(layer=layer) # (Co, Ci, kh, kw)

        for w_start in range( math.ceil(Wi/self._Fake_PE_Arrays._row ) ) :
            for h in range(Hi):
                ## Init IABundle
                IABundles = [ self._IAMemory.get_IABundle(layer=layer, h=h, w=w_start*self._Fake_PE_Arrays._row + i) for i in range(self._Fake_PE_Arrays._row)] # 7
                self._Fake_PE_Arrays.put_IABundles(IABundles) 

                ## Get Fake_PE_outputs [0,1,2,3,4,5,6,7,8]
                Fake_PE_outputs = self._Fake_PE_Arrays.get_PE_output()
                pass







    def Conv_test(self, layer: int ):

        assert isinstance(layer, int)
        assert 1 <= layer <=5



        # -------------------- For testing ---------------

        # Init Weights
        Weights = [ self._WMemory.get_Weight(layer=layer, index=i) for i in range(3)]
        self._Fake_PE_Arrays.put_Weights(Weights)

        # Start computing
        N, Ci, Hi, Wi = self._IAMemory.get_IA_shape(layer=layer) # (batch_size, Ci, H, W)
        Co, Ci, kh, kw = self._WMemory.get_Weight_shape(layer=layer) # (Co, Ci, kh, kw)


        
        # Hi = 1
        # for row in range(Hi):
        #     temp_OAs = [torch.zeros(1, 384, 3, 1) for x in range(self._Fake_PE_Arrays._col - 1)]  # For Conv 3
        #     for col_start in range( math.ceil(Wi/self._Fake_PE_Arrays._row ) ) :
        #         IAs = [ self._IAMemory.get_IA(layer=layer, row=row, col=col_start*self._Fake_PE_Arrays._row + c) for c in range(self._Fake_PE_Arrays._row)]
        #         self._Fake_PE_Arrays.put_IAs(IAs) 
        #         self._Fake_PE_Arrays.put_temp_OAs(temp_OAs)
        #         # Get output
        #         OAs = self._Fake_PE_Arrays.get_OAs()
        #         # update temp
        #         temp_OAs = [OAs[8], OAs[7]]

        # if (layer==1):
        #     self._OA_buffer = None
        # elif (layer ==3):
        #     self._OA_buffer = [ [torch.zeros(1, Co, kh, 1)]*26 for x in range(26)]

        # Hi = 1
        # for row in range(Hi):
        #     temp_OAs = [torch.zeros(1, Co, kh, 1) for x in range(3 - 1)]  # For Conv 3
        #     for col_start in range( math.ceil(Wi/7 ) ) :
        #         IAs = [ self._IAMemory.get_IA(layer=layer, row=row, col=col_start*7 + c) for c in range(7)]
        #         self._Fake_PE_Arrays.put_IAs(IAs) 
        #         self._Fake_PE_Arrays.put_temp_OAs(temp_OAs)

        #         # Get output
        #         OAs = self._Fake_PE_Arrays.get_OAs()

        #         if (col_start==0):
        #             for i in range(2,7):
        #                 torch.add(self._OA_buffer[row][col_start*7+i-2] , OAs[i])
        #         elif(col_start == math.ceil(Wi/7 )-1):
        #             for i in range(0,7):
        #                 torch.add(self._OA_buffer[row][col_start*7+i-2] , OAs[i])
        #         else:
        #             for i in range(0,7):
        #                 torch.add(self._OA_buffer[row][col_start*7+i-2] , OAs[i])
        #         # need to do pooling and self._IA.putIA here

        #         # update temp
        #         temp_OAs = [OAs[8], OAs[7]]
        return 
                

        






    





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