module labM; reg [31:0] d, e;
    reg clk, enable, flag;
    wire [31:0] z;
    register #(32) mine(z, d, clk, enable);

    always
    begin
        #5 clk = ~clk;
        if (clk)
            e = d;
    end

    initial begin
        flag = $value$plusargs("enable=%b", enable);
        clk = 0;

        repeat (20)
        begin
            #2 d = $random;
            if (z === e)
                $monitor("PASS %5d:clk=%b,d=%d,z=%d,expect=%d", $time,clk,d,z, e);
            else
                $monitor("FAIL %5d:clk=%b,d=%d,z=%d,expect=%d", $time,clk,d,z, e);
        end
        
        $finish;
    end
endmodule
