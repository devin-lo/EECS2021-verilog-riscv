module labM;
    wire [31:0] PCin, PC;
    reg clk, INT;
    wire [2:0] op, funct3;
    reg [31:0] entryPoint;

    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, branch;
    wire [31:0] jTarget;
    wire [31:0] memOut, wb;
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

    assign wd = wb; 
    yPC myPC(PCin, PC, PCp4, INT, entryPoint, branch, jTarget, zero, isbranch, isjump);

    assign opCode = ins[6:0];
    yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
    yC2 myC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);

    yC3 myC3(ALUop, isRtype, isbranch);
    assign funct3=ins[14:12];
    yC4 myC4(op, ALUop, funct3);

    // zero flag test
    wire [15:0] z16;
    wire [7:0] z8;
    wire [3:0] z4;
    wire [1:0] z2;
    wire z1, exp_zero;

    or or16[15:0] (z16, z[15:0], z[31:16]);
    or or8[7:0] (z8, z16[7:0], z16[15:8]);
    or or4[3:0] (z4, z8[3:0], z8[7:4]);
    or or2[1:0] (z2, z4[1:0], z4[3:2]);
    or or1 (z1, z2[1], z2[0]);
    not zero_not(exp_zero, z1);

    initial
    begin
        //------------------------------------Entry point
        INT = 1;
        entryPoint = 16'h28; #1;
        //------------------------------------Run program
        repeat (43)
        begin
            //---------------------------------Fetch an ins
            clk = 1; #1;
            INT = 0;
            
            //---------------------------------Execute the ins
            clk = 0; #1;
            //---------------------------------View results
            // display the following signals ins, rd1, rd2, imm, jTarget, z, zero
            #4 $display("%8h: rd1=%d rd2=%d imm=%d jTarget=%d z=%d zero=%b wb=%d ALUop=%b funct3=%b op=%b", ins, rd1, rd2, imm, jTarget, z, zero, wb, ALUop, funct3, op);
            //---------------------------------Prepare for the next ins - no longer needed as it's in circuit
        end
        $finish;
    end
endmodule