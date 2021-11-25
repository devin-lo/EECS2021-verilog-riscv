module labM;
    wire [31:0] PCin, PC;
    reg clk, INT;
    reg [2:0] op;
    reg [31:0] entryPoint;

    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, branch;
    wire [31:0] jTarget;
    wire [31:0] memOut, wb;
    wire zero;
    wire [6:0] opCode;
    wire isStype, isRtype, isItype, isLw, isjump, isbranch;
    wire RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg;

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
            // Temporarily set
            op = 3'b010;
            // Add statements to adjust the above defaults
            // I used Figure 4.18 from the textbook as my guide plus Google Images lol - not sure if right

            if (ins[6:0] == 7'h33) // R-type
            begin
                // $display("R-type");
                op = 3'b010;
                if(ins[14:12] == 3'b110) // for R-Type that is or (funct3 is 110) credit to 秘密雪
                    op = 3'b001;
                // NOTE: funct3 111 is never encountered in this prelab exercise
            end
            else if (ins[6:0] == 7'h6F) // UJ-type jal
            begin
                // $display("jal UJ-type");
                // op is dont-care or else set 0 if not working
            end
            else if (ins[6:0] == 7'h3) // lw (I-Type)
            begin
                // $display("lw I-Type");
            end
            else if (ins[6:0] == 7'h13) // addi (I-Type)
            begin
                // $display("addi I-Type");
            end
            else if (ins[6:0] == 7'h23) // sw (S-Type)
            begin
                // $display("sw S-Type");
            end
            else if (ins[6:0] == 7'h63) // SB-Type beq
            begin
                // $display("beq SB-Type");
                op = 3'b110; // from the tables in LabN when building yC4
            end
            
            //---------------------------------Execute the ins
            clk = 0; #1;
            //---------------------------------View results
            // display the following signals ins, rd1, rd2, imm, jTarget, z, zero
            #4 $display("%8h: rd1=%d rd2=%d imm=%d jTarget=%d z=%d zero=%b wb=%d", ins, rd1, rd2, imm, jTarget, z, zero, wb);
            //---------------------------------Prepare for the next ins - no longer needed as it's in circuit
        end
        $finish;
    end
endmodule