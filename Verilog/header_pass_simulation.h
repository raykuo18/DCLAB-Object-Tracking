// --------------------- `define for WMem ------------------------
`define W_DATA_BITWIDTH 16
`define W_C_BITWIDTH 5 // log2(# Channel)
`define W_R_BITWIDTH 2 
`define W_K_BITWIDTH 5 
`define W_POS_PTR_BITWIDTH 11 

`define W_C_LENGTH_L1_S0 123
`define W_R_LENGTH_L1_S0 48
`define W_C_LENGTH_L1_S1 130
`define W_R_LENGTH_L1_S1 48
`define W_C_LENGTH_L1_S2 124
`define W_R_LENGTH_L1_S2 48

`define W_C_LENGTH_L2_S0 474
`define W_R_LENGTH_L2_S0 48
`define W_C_LENGTH_L2_S1 460
`define W_R_LENGTH_L2_S1 48
`define W_C_LENGTH_L2_S2 446
`define W_R_LENGTH_L2_S2 48

`define W_C_LENGTH 474 // max of C_LENGTH
`define W_R_LENGTH 48 // max of R_LENGTH

    // --------------------- `define for IA ------------------------
`define IA_DATA_BITWIDTH 16
`define IA_C_BITWIDTH 5 // log2(# Channel)
`define IA_CHANNEL 8
`define IA_ROW 16
`define IA_COL 16
    // ----------------------------- OAReducer ----------------------
    // `define OAReducer_LENGTH    216 // IA_CHANNEL*kh(=3)*9

    // ----------------------------- PE Arrays----------------------
`define PE_ROW 7
`define PE_COL 3

    // `define W_S_BITWIDTH       2
    // `define W_ITERS_BITWIDTH   6