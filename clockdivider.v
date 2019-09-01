// module used in both counter and jackpot game

module clockdivider(
    input CLOCK,		// input is the ZYBO board’s standard clock signal
    input RESET,		// input reset to manually reset slowed clock signal
    output reg clockdiv	// output is new clock signal with far smaller frequency
    );
    
    reg [31:0] clockcount;		// large register that increment at every CLOCK cycle

    localparam clockconstant = 70000000;	// maximum clockcount value
    // controls the period and frequency of the new clock signal 
    // at this value the period of clockdivider would be times larger than CLOCK’s period
       
always@(posedge RESET or posedge CLOCK) begin // trigger if reset is pressed and at rising edge of CLOCK
         if(RESET==1'b1) begin	// if reset button is pressed reset clockcount to 0
             clockcount<=32'b0;
         end
         else if (clockcount==clockconstant-1) begin // if clockcount reaches its maximum value reset it to 0
             clockcount<=32'b0;
         end
         else begin	// if the reset button is not pressed or the clockcount is not at its max value, increment by 1
             clockcount<=clockcount+1; 
         end
     end
     
always@(posedge RESET or posedge CLOCK) begin // trigger if reset is pressed and at rising edge of CLOCK
         if(RESET==1'b1) begin	// if reset button is pressed the new clock signal is set to zero
             clockdiv<=1'b0;
         end
         else if (clockcount==clockconstant-1) begin	// if clockcount reaches maximum value clockdiv flips value
             clockdiv<=~clockdiv;
         end
         else begin
             clockdiv<=clockdiv;	// if clockcount is not at max, clock div stays at current value
         end
     end

// because clockdiv flips value once every time clockconstant is reached, the period of the new clock is twice
// that of the clockconstant value.

endmodule
