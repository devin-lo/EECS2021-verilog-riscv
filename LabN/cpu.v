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
module yIF(ins, PC, PCp4, PCin, clk);
    output [31:0] ins, PC, PCp4;
    input [31:0] PCin;
    input clk;

    wire zero;
    wire read, write, enable;
    wire [31:0] a, memIn;
    wire [2:0] op;

    register #(32) pcReg(PC, PCin, clk, enable);
    mem insMem(ins, PC, memIn, clk, read, write);
    yAlu myAlu(PCp4, zero, a, PC, op);

    assign enable = 1'b1;
    assign a = 32'h0004;
    assign op = 3'b010;
    assign read = 1'b1;
    assign write = 1'b0;
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
module yPC(PCin, PC, PCp4,INT,entryPoint,branchImm,jImm,zero,isbranch,isjump);
    output [31:0] PCin;

    input [31:0] PC, PCp4, entryPoint, branchImm;
    input [31:0] jImm;
    input INT, zero, isbranch, isjump;

    wire [31:0] branchImmX4, jImmX4, jImmX4PPCp4, bTarget, choiceA, choiceB;
    wire doBranch, zf;

    // Shifting left branchImm twice
    assign branchImmX4[31:2] = branchImm[29:0];
    assign branchImmX4[1:0] = 2'b00;

    // Shifting left jump twice
    assign jImmX4[31:2] = jImm[29:0];
    assign jImmX4[1:0] = 2'b00;

    // adding PC to shifted twice, branchImm
    //Replace ? in the yPC module with proper entries.
    yAlu bALU(bTarget, zf, PC, branchImmX4, 3'b010);

    // adding PC to shifted twice, jImm
    //Replace ? in the yPC module with proper entries.
    yAlu jALU(jImmX4PPCp4, zf, PC, jImmX4, 3'b010);

    // deciding to do branch
    and decide_do(doBranch, isbranch, zero);
    yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
    yMux #(32) mux2(choiceB, choiceA, jImmX4PPCp4, isjump);
    yMux #(32) mux3(PCin, choiceB, entryPoint, INT);
endmodule
module yC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    output isStype, isRtype, isItype, isLw, isjump, isbranch;
    input [6:0] opCode;
    wire lwor, ISselect, JBselect, sbz, sz;

    // opCode
    //         6543210
    //
    // lw      0000011
    // I-Type  0010011
    // R-Type  0110011
    // SB-Type 1100011 beq
    // UJ-Type 1101111 jal
    // S-Type  0100011

    // Detect UJ-type
    assign isjump= opCode[3];

    // Detect lw
    or lw_detect(lwor, opCode[6], opCode[5], opCode[4], opCode[3], opCode[2]); not (isLw, lwor);

    // Select between S-Type and I-Type
    xor s_i_xor(ISselect, opCode[6], opCode[3], opCode[2], opCode[1], opCode[0]);
    and s_and(isStype, ISselect, opCode[5]);
    and i_and(isItype, ISselect, opCode[4]);

    // Detect R-Type
    and r_and(isRtype, opCode[5], opCode[4]);

    // Select between JAL and Branch
    and JB_and(JBselect, opCode[6], opCode[5]); // SB and UJ are the only ones with bits 5 and 6
    not branch_detect(sbz, opCode[3]); // SB has 0 in bits 2 and 3
    and branch_and(isbranch, JBselect, sbz);
endmodule
module yC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);
    output RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg;
    input isStype, isRtype, isItype, isLw, isjump, isbranch;

    // You need two or gates and 3 assignments;

    // ALUSrc is 1 for I-Type and sw and UJ
    // Mem2Reg is 1 for lw
    // RegWrite is 1 for R-format and lw and UJ
    // MemRead is 1 for lw
    // MemWrite is 1 for sw

    // the 2 lines of code below from the vishal0027 GitHub worked better than my own lol
    // https://github.com/vishal0027/EECS2021-MIPS/blob/master/LabN/yC2.v
    nor (ALUSrc, isRtype, isbranch);			//0 - do calculation; 1 - add immediate
    nor (RegWrite, isStype, isbranch);			//need to write to a register

    assign Mem2Reg = isLw;
    assign MemRead = isLw;
    assign MemWrite = isStype;
endmodule
module yC3(ALUop, isRtype, isbranch);
    output [1:0] ALUop;
    input isRtype, isbranch;
    // build the circuit
    // Hint: you can do it in only 2 lines
    // Originally I tried to use if-else lol - this clever way is credited to RayM
    assign ALUop[1] = isRtype;
    assign ALUop[0] = isbranch;
endmodule
module yC4(op, ALUop, funct3);
    output [2:0] op;
    input [2:0] funct3;
    input [1:0] ALUop;
    wire f21out, f10out, upperAndOut, notALU, notf3;
    // instantiate and connect
    // use the circuit diagram with 5 gates

    // bit 2
    xor f21 (f21out, funct3[2], funct3[1]); // lmfao I can't read, i really said this was nor at first
    and upperAnd(upperAndOut, ALUop[1], f21out);
    or upperOr(op[2], ALUop[0], upperAndOut);

    // bit 1
    // lol I misread the circuit diagram at first, didn't realize I needed to not the inputs
    not ALUop1no(notALU, ALUop[1]);
    not f3no(notf3, funct3[1]);
    or lowerOr(op[1], notALU, notf3);

    // bit 0
    xor f10 (f10out, funct3[1], funct3[0]);
    and lowerAnd(op[0], ALUop[1], f10out);

endmodule
module yChip(ins, rd2, wb, entryPoint, INT, clk);
    output [31:0] ins, rd2, wb;
    input [31:0] entryPoint;
    input INT, clk;

    wire [31:0] PCin, PC;
    wire [2:0] op, funct3;

    wire [31:0] wd, rd1, imm, PCp4, z, branch;
    wire [31:0] jTarget;
    wire [31:0] memOut;
    wire zero;
    wire [6:0] opCode;
    wire isStype, isRtype, isItype, isLw, isjump, isbranch;
    wire RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg;
    wire [1:0] ALUop;

    yIF myIF(ins, PC, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);

    yPC myPC(PCin, PC, PCp4, INT, entryPoint, branch, jTarget, zero, isbranch, isjump);

    assign opCode = ins[6:0];
    yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    yC2 myC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);

    yC3 myC3(ALUop, isRtype, isbranch);
    assign funct3=ins[14:12];
    yC4 myC4(op, ALUop, funct3);

    assign wd = wb; 
endmodule