module labL;
    reg a, b, cin;
    reg [1:0] expect;
    wire z, cout;
    integer i, j, k;

    // call function
    yAdder1 mine(z, cout, a, b, cin);

    // exhaustive testing
    initial begin
        for (i = 0; i < 2; i = i + 1)
        begin
            for (j = 0; j < 2; j = j + 1)
            begin
                for (k = 0; k < 2; k = k + 1)
                begin
                    a = i; b = j; cin = k;
                    expect = a + b + cin; // boolean logic representation of the circuit
                    #1; // wait for z - propagation delay

                    // oracle
                    if (expect[0] === z && expect[1] === cout)
                        $display("PASS: a=%b b=%b c=%b z=%b", a, b, cin, z);
                    else
                        $display("FAIL: a=%b b=%b c=%b z=%b", a, b, cin, z);
                end
            end
        end
    $finish;
    end
endmodule