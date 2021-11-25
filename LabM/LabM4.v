module labM;
    reg clk, read, write;
    reg [31:0] address, memIn;
    wire [31:0] memOut;

    mem data(memOut, address, memIn, clk, read, write);

    initial begin
        clk = 0;
        address = 16; write = 1; read = 0;
        memIn = 32'h12345678;
        clk = 1;
        #1;
        clk = 0;
        write = 1; read = 0;
        address = address + 8;
        memIn = 32'h89abcdef;
        clk = 1;
        #1;

        write = 0; read = 1; address = 16;
        repeat (3)
        begin
            #1; $display("Address %d contains %h", address, memOut); address = address + 4;
        end
        
        $finish;
    end
endmodule
