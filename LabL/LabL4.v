module labL;
    reg [1:0] c;
    reg [31:0] a, b, d, e, zLo, zHi, expect;
    wire [31:0] z;
    integer i;

    // call function
    yMux4to1 #(.SIZE(32)) my_mux[31:0](z, a, b, d, e, c);

    // exhaustive testing
    initial begin
        repeat (10)
        begin
            a = $random;
            b = $random;
            d = $random;
            e = $random;
            c = $random % 4;
            for (i = 0; i < 32; i = i + 1) // need a for loop to calculate each bit of expect properly. credit to RayM
            begin
                zLo[i] = ((a[i] & ~c[0]) + (b[i] & c[0]));
                zHi[i] = ((d[i] & ~c[0]) + (e[i] & c[0]));
                expect[i] = ((zLo[i] & ~c[1]) + (zHi[i] & c[1])); // boolean logic representation of the circuit
            end
            #1; // wait for z - propagation delay

            // oracle
            // $display("EXPECT: expect=%b", expect);
            if (expect === z)
                $display("PASS: a0=%b a1=%b a2=%b a3=%b c=%b z=%b", a, b, d, e, c, z);
            else
                $display("FAIL: a0=%b a1=%b a2=%b a3=%b c=%b z=%b", a, b, d, e, c, z);
        end
    $finish;
    end
endmodule