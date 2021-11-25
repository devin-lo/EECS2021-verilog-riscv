module labL;
    reg signed [31:0] a, b;
    reg [31:0] expect;
    reg [2:0] op, tmp;
    wire ex;
    wire [31:0] z, zAnd;
    reg ok, flag, zero;
    integer i;

    and ab_and[31:0](zAnd, a, b);
    yAlu mine(z, ex, a, b, op);

    initial
    begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            tmp = $random % 2;
            if (tmp == 0)
            begin
                $display("b will now equal a");
                b = a;
            end
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
            zero = (expect == 0) ? 1 : 0;
            #1;
            // Compare the circuit's output with "expect"
            // and set "ok" accordingly

            $display("expected=%b", expect);
            
            ok = 0;
            if (expect === z)
                ok = 1;
            // Display ok and the various signals

            if (ok)
            begin
                $display("PASS: a=%b b=%b op=%b z=%b", a, b, op, z);
                $display("expected zero flag value=%b", zero);
                if (zero && zero === ex)
                    $display("PASS: zero flag exception correctly raised. zero=%b", ex);
                else if (zero && zero !== ex)
                    $display("FAIL: zero flag exception was not raised when it should've been. zero=%b", ex);
                else if (!(zero) && zero !== ex)
                    $display("FAIL: zero flag exception raised incorrectly. zero=%b", ex);
                else if (!(zero) && zero === ex)
                    $display("PASS: zero flag exception not raised, and it shouldn't be!. zero=%b", ex);
            end
            else
                $display("FAIL: a=%b b=%b op=%b z=%b", a, b, op, z);
        end
    $finish;
    end
endmodule