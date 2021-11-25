module labM;
    wire [31:0] PCin, PC;
    reg RegWrite, clk, ALUSrc, MemRead, MemWrite, Mem2Reg, INT, isbranch, isjump;
    reg [2:0] op;
    reg [31:0] entryPoint;

    wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, branch;
    wire [31:0] jTarget;
    wire [31:0] memOut, wb;
    wire zero;

    yIF myIF(ins, PC, PCp4, PCin, clk);
    yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
    yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
    yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
    yWB myWB(wb, z, memOut, Mem2Reg);
    yPC myPC(PCin, PC, PCp4, INT, entryPoint, branch, jTarget, zero, isbranch, isjump);

    assign wd = wb;

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
            isjump = 0;
            isbranch = 0;
            RegWrite = 0;
            ALUSrc = 1;
            op = 3'b010;
            MemRead = 0;
            MemWrite = 0;
            Mem2Reg = 0;

            // Add statements to adjust the above defaults
            // I used Figure 4.18 from the textbook as my guide plus Google Images lol - not sure if right
            // need to add isjump and isbranch

            if (ins[6:0] == 7'h33) // R-type
            begin
                // $display("R-type");
                ALUSrc = 0;
                RegWrite = 1;
                op = 3'b010;
                MemRead = 0;
                MemWrite = 0;
                Mem2Reg = 0;
                if(ins[14:12] == 3'b110) // for R-Type that is or (funct3 is 110) credit to 秘密雪
                    op = 3'b001;
                // NOTE: funct3 111 is never encountered in this prelab exercise
            end
            else if (ins[6:0] == 7'h6F) // UJ-type jal
            begin
                // $display("jal UJ-type");
                RegWrite = 1;
                ALUSrc = 1; // is NOT dont-care
                // op is dont-care or else set 0 if not working
                MemRead = 0;
                MemWrite = 0;
                isjump = 1;
            end
            else if (ins[6:0] == 7'h3) // lw (I-Type)
            begin
                // $display("lw I-Type");
                ALUSrc = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                Mem2Reg = 1;
            end
            else if (ins[6:0] == 7'h13) // addi (I-Type)
            begin
                // $display("addi I-Type");
                ALUSrc = 1;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Mem2Reg = 0;
            end
            else if (ins[6:0] == 7'h23) // sw (S-Type)
            begin
                // $display("sw S-Type");
                ALUSrc = 1;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                // Mem2Reg is don't care
            end
            else if (ins[6:0] == 7'h63) // SB-Type beq
            begin
                // $display("beq SB-Type");
                ALUSrc = 0;
                RegWrite = 0;
                op = 3'b110; // from the tables in LabN when building yC4
                MemRead = 0;
                MemWrite = 0;
                isbranch = 1;
                // Mem2Reg is don't care
            end
            
            //---------------------------------Execute the ins
            clk = 0; #1;
            //---------------------------------View results
            // display the following signals ins, rd1, rd2, imm, jTarget, z, zero
            #4 $display("%8h: rd1=%d rd2=%d imm=%d jTarget=%d z=%d zero=%b wb=%d", ins, rd1, rd2, imm, jTarget, z, zero, wb);
            //---------------------------------Prepare for the next ins
            /*
            deactivated the prepare for next ins because it's been put in a circuit
            if (INT == 1)
                PCin = entryPoint;
            else if (ins[6:0] == 7'h63 && zero == 1)
                PCin = PCin + (imm << 2);
            else if (ins[6:0] == 7'h6F)
                PCin = PCin + (jTarget << 2);
            else
                PCin = PCp4;
            */
        end
        $finish;
    end
endmodule