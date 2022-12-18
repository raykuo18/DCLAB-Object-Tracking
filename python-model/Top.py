

from specs import *




# top = Top()

# top.Conv(layer=3)




# fake_PE_Arrays_spec = Specs().specs['Fake_PE_Arrays']
# fake_PE_Arrays = Fake_PE_Arrays(row=fake_PE_Arrays_spec['row'], col=fake_PE_Arrays_spec['col'] )

WMem = WMemory()


wbundle = WMem.get_WBundle(layer=3, group=0, s=0)
print(wbundle._s)
print(len(wbundle._data))
print(len(wbundle._c_idx))
print(len(wbundle._pos_ptr))
print(len(wbundle._r_idx))
print(len(wbundle._k_idx))
print("")



IAMem = IAMemory()

iabundle = IAMem.get_IABundle(layer=3, h=3, w=4)
print(len(iabundle._c_idx))
print(len(iabundle._data))

# --- Compute Layer 3  -----

# Weights = [ WMem.get_Weight(layer=3, index=i) for i in range(3)]

# fake_PE_Arrays.put_Weights(Weights)

# IAs = [ IAMem.get_IA(layer=3, row=r, col=0) for r in range(7)]

# fake_PE_Arrays.put_IAs(IAs)
# fake_PE_Arrays.put_temp_OAs([torch.zeros(1, 384, 3, 1) for x in range(2)])

# print(len(fake_PE_Arrays._Ws), fake_PE_Arrays._Ws[0].shape)
# print(len(fake_PE_Arrays._IAs), fake_PE_Arrays._IAs[0].shape)



# OAs = fake_PE_Arrays.get_OAs()

# print(len(OAs))
# print(OAs[0].shape)




# print(fake_PE_Arrays._Ws[2].shape)
# print(fake_PE_Arrays._IAs[6].shape)


# print(OAs[8].shape)
# print(len(OAs))

# print(IAMem.get_IA_shape(layer=3))


# print(WMem._weights.keys())

# Weight = WMem.get_Weight(layer=3, index=0)

# print(type(Weight))
# print(Weight.shape)

# for layer in range(1,6):
#     IA = IAMem.get_IA(layer=layer, row=0, col=0)
#     print(IA.shape)













