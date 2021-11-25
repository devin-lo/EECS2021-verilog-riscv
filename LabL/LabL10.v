module labL;
    reg signed [31:0] a, b;
    reg [31:0] expect;
    reg [2:0] op;
    wire ex;
    wire [31:0] z, zAnd;
    reg ok, flag;
    integer i;

    and ab_and[31:0](zAnd, a, b);
    yAlu mine(z, ex, a, b, op);

    initial
    begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            flag = $value$plusargs("op=%d", op);
            // The oracle: compute "expect" based on "op"
            if (op == 3'b000)
            begin
                $display("and detected");
                for (i = 0; i < 32; i++)
                begin
                    expect[i] = a[i] & b[i];
                end
            end
            else if (op == 3'b001)
            begin
                $display("or detected");
                for (i = 0; i < 32; i++)
                begin
                    expect[i] = a[i] | b[i];
                end
            end
            else if (op == 3'b010)
            begin
                $display("add detected");
                expect = a + b;
            end
            else if (op == 3'b110)
            begin
                $display("subtract detected");
                expect = a + ~b + 1;
            end
            else if (op == 3'b111)
                expect = (a < b) ? 1 : 0;
            else
            begin
                $display("unsupported operation detected");
                expect = 0; // unsupported operation somehow
            end
            #1;
            // Compare the circuit's output with "expect"
            // and set "ok" accordingly

            $display("expected=%b", expect);
            
            ok = 0;
            if (expect === z)
                ok = 1;
            // Display ok and the various signals

            if (ok)
                $display("PASS: a=%b b=%b op=%b z=%b", a, b, op, z);
            else
                $display("FAIL: a=%b b=%b op=%b z=%b", a, b, op, z);
        end
    $finish;
    end
endmodule