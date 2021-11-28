module yMux1(z, a, b, c);
    output z;
    input a, b, c;
    wire notC, upper, lower;
    not my_not(notC, c);
    and upperAnd(upper, a, notC);
    and lowerAnd(lower, c, b);
    or my_or(z, upper, lower);
endmodule
module yMux(z, a, b, c);
    parameter SIZE = 2;
    output [SIZE-1:0] z;
    input [SIZE-1:0] a, b;
    input c;
    yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule
module yMux4to1(z, a0,a1,a2,a3, c);
    parameter SIZE = 2;
    output [SIZE-1:0] z;
    input [SIZE-1:0] a0, a1, a2, a3;
    input [1:0] c;
    wire [SIZE-1:0] zLo, zHi;
    yMux #(SIZE) lo(zLo, a0, a1, c[0]);
    yMux #(SIZE) hi(zHi, a2, a3, c[0]);
    yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule
module yAdder1(z, cout, a, b, cin);
    output z, cout;
    input a, b, cin;
    xor left_xor(tmp, a, b);
    xor right_xor(z, cin, tmp);
    and left_and(outL, a, b);
    and right_and(outR, tmp, cin);
    or my_or(cout, outR, outL);
endmodule
module yAdder(z, cout, a, b, cin);
    // outputs
    output [31:0] z;
    output cout;

    // inputs
    input [31:0] a, b;
    input cin;

    // interconnects
    wire[31:0] in, out;

    // yAdder1 is defined in yAdder1.v
    yAdder1 mine[31:0](z, out, a, b, in);
    
    assign in[0] = cin;
    assign in[31:1] = out[30:0];
endmodule
module yArith(z, cout, a, b, ctrl);
    // add if ctrl=0, subtract if ctrl=1
    output [31:0] z;
    output cout;
    input [31:0] a, b;
    input ctrl;
    wire[31:0] notB, tmp;
    wire cin;

    // instantiate the components and connect them
    // Hint: about 4 lines of code
    not c_not[31:0](notB, b);
    yMux #(.SIZE(32)) my_mux[31:0](tmp, b, notB, ctrl);
    assign cin = ctrl;
    yAdder my_add[31:0](z, cout, a, tmp, cin);
endmodule
module yAlu(z, zero, a, b, op);
    // op=000: z=a AND b, op=001: z=a|b, op=010: z=a+b, op=110: z=a-b
    input [31:0] a, b;
    input [2:0] op;
    output [31:0] z;
    output zero;

    wire [15:0] z16;
    wire [7:0] z8;
    wire [3:0] z4;
    wire [1:0] z2;
    wire z1;

    wire cout;
    wire [31:0] zAnd, zOr, zArith, slt;
    wire condition;
    wire [31:0] aSubB;
    assign slt[31:1] = 0; // the rest of the slt bits have to be 0
    // assign ex = 0; // zero flag default value <- must be removed for LabL11 and beyond, credit to 秘密雪
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
    not zero_not(zero, z1);

    // slt - credit to Alex L.
    xor slt_xor(condition, a[31], b[31]);
    yArith slt_arith(aSubB, cout, a, b, 1'b1);
    yMux1 my_mux_slt(slt[0], aSubB[31], a[31], condition); // aSubB[31] is the 0 case, and a[31] is the 1 case

    yArith ab_arith[31:0](zArith, cout, a, b, op[2]);
    yMux4to1 #(.SIZE(32)) my_mux(z, zAnd, zOr, zArith, slt, op[1:0]);
endmodule
module yIF(ins, PCp4, PCin, clk);
    output [31:0] ins, PCp4;
    input [31:0] PCin;
    input clk;
    wire zerflag;
    wire [31:0] regOut;
    // build and connect the circuit
    // refer to the 2nd diagram on pg 9 - needs a reg, alu, and mem
    
    register #(32) my_reg(regOut, PCin, clk, 1'b1);
    yAlu pc_inc(PCp4, zerflag, 4, regOut, 3'b010);
    mem data(ins, regOut, , clk, 1'b1, 1'b0); // the memIn port is left unconnected
endmodule
module yID(rd1, rd2, immOut, jTarget, branch, ins, wd, RegWrite, clk);
    output [31:0] rd1, rd2, immOut;
    output [31:0] jTarget;
    output [31:0] branch;

    input [31:0] ins, wd;
    input RegWrite, clk;

    wire [19:0] zeros, ones; // For I-Type and SB-Type
    wire [11:0] zerosj, onesj; // For UJ-Type
    wire [31:0] imm, saveImm; // For S-Type

    rf myRF(rd1, rd2, ins[19:15], ins[24:20], ins[11:7], wd, clk, RegWrite);

    assign imm[11:0] = ins[31:20];
    assign zeros = 20'h00000;
    assign ones = 20'hFFFFF;
    yMux #(20) se(imm[31:12], zeros, ones, ins[31]);

    assign saveImm[11:5] = ins[31:25];
    assign saveImm[4:0] = ins[11:7];

    yMux #(20) saveImmSe(saveImm[31:12], zeros, ones, ins[31]);
    yMux #(32) immSelection(immOut, imm, saveImm, ins[5]);

    assign branch[11] = ins[31];
    assign branch[10] = ins[7];
    assign branch[9:4] = ins[30:25];
    assign branch[3:0] = ins[11:8];
    yMux #(20) bra(branch[31:12], zeros, ones, ins[31]);

    assign zerosj = 12'h000;
    assign onesj = 12'hFFF;
    assign jTarget[19] = ins[31];
    assign jTarget[18:11] = ins[19:12];
    assign jTarget[10] = ins[20];
    assign jTarget[9:0] = ins[30:21];
    yMux #(12) jum(jTarget[31:20], zerosj, onesj, jTarget[19]);
endmodule
module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
    output [31:0] z;
    output zero;
    input [31:0] rd1, rd2, imm;
    input [2:0] op;
    input ALUSrc;
    wire [31:0] muxOut;

    yMux #(32) reg_or_imm(muxOut, rd2, imm, ALUSrc);
    yAlu execAlu(z, zero, rd1, muxOut, op);
endmodule
module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
    output [31:0] memOut;
    input [31:0] exeOut, rd2;
    input clk, MemRead, MemWrite;

    // instantiate the circuit (only one line)
    mem data_mem(memOut, exeOut, rd2, clk, MemRead, MemWrite);
endmodule
module yWB(wb, exeOut, memOut, Mem2Reg);
    output [31:0] wb;
    input [31:0] exeOut, memOut;
    input Mem2Reg;

    // instantiate the circuit (only one line)
    yMux #(32) writeback(wb, exeOut, memOut, Mem2Reg);
endmodule