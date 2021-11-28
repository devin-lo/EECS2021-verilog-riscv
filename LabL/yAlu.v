module yAlu(z, ex, a, b, op);
    // op=000: z=a AND b, op=001: z=a|b, op=010: z=a+b, op=110: z=a-b
    input [31:0] a, b;
    input [2:0] op;
    output [31:0] z;
    output ex;

    wire [15:0] z16;
    wire [7:0] z8;
    wire [3:0] z4;
    wire [1:0] z2;
    wire z1;

    wire cout;
    wire [31:0] zAnd, zOr, zArith, slt;
    wire condition;
    wire [31:0] aSubB;
    assign slt[31:1] = 0; // not supported
    // assign ex = 0; // not supported <- must be removed for LabL11 and beyond, credit to 秘密雪
    // instantiate the components and connect them
    // Hint: takes about 4 lines of code
    and ab_and[31:0](zAnd, a, b);
    or ab_or[31:0](zOr, a, b);

    // zero flag
    or or16[15:0] (z16, z[15:0], z[31:16]);
    or or8[7:0] (z8, z16[7:0], z16[15:8]);
    or or4[3:0] (z4, z8[3:0], z8[7:4]);
    or or2[1:0] (z2, z4[1:0], z4[3:2]);
    or or1 (z1, z2[1], z2[0]);
    not zero_not(ex, z1);

    // slt - credit to Alex L.
    xor slt_xor(condition, a[31], b[31]);
    yArith slt_arith(aSubB, cout, a, b, 1'b1);
    yMux1 my_mux_slt(slt[0], aSubB[31], a[31], condition); // aSubB[31] is the 0 case, and a[31] is the 1 case

    yArith ab_arith[31:0](zArith, cout, a, b, op[2]);
    yMux4to1 #(.SIZE(32)) my_mux(z, zAnd, zOr, zArith, slt, op[1:0]);
endmodule