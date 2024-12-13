module delay (
    input clk,
    input rst, 
    input start,
    output reg done
);

    // State registers
    reg [2:0] S, NS;
    reg [31:0] i;

    // State encoding
    parameter START = 3'd0, CHECK = 3'd1, INCREMENT = 3'd2, DONE = 3'd3;

    // State register update
    always @(posedge clk or negedge rst) begin
        if (!rst) 
            S <= START;
        else 
            S <= NS;
    end

    // Next state logic
    always @(*) begin
        case (S)
            START: 
                if (start) 
                    NS = CHECK;
                else 
                    NS = START;
            CHECK:
                if (i < 10000000) 
                    NS = INCREMENT;
                else 
                    NS = DONE; 
            INCREMENT: 
                NS = CHECK;
            DONE: 
                NS = DONE;
        endcase 
    end

    // Output logic and counter update
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            i <= 0;
            done <= 0; 
        end else begin
            case (S)
                START: begin
                    i <= 0;
                    done <= 0; 
                end
                CHECK: begin
                    if (i == 10000000)
                        done <= 1;
                end
                INCREMENT: begin
                    i <= i + 1;
                end
                DONE: begin
                    done <= 1;
                end
            endcase
        end
    end

endmodule
