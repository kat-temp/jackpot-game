`timescale 1ns / 1ps

module jackpot(
    input RESET,		// one bit input signal for manual reset button
    input CLOCK,		// one bit input signal for ZYBO board’s standard clock signal
    input [3:0] SWITCHES,		// four bit input signal for the switches
    output reg [3:0] LEDS		// four bit output register for the LEDs
    );
    
    wire clockdiv;		// slowed clock signal and output of clockdivider
    reg [2:0] count;	// register used as three bit counter
    reg [3:0] S;		// register used to hold switches value for a short period of time
    reg [31:0] n;		// incrementer to control how to S has the value of switches
    
    localparam clockconstant = 7000000;	// parameter also used in clockdivider module
    localparam countconstant = 3;		// maximum value for counter
    
    initial begin 
    assign count=3'b0;			// initializing count as 000
    end
    
    clockdivider clockdivider(CLOCK, RESET, cd);  // instantiated clockdivider module
    // the local parameter clockconstant would be changed to 7000000 in the clockdivder module
          
     always@(posedge CLOCK) begin	// triggers at every positive edge of CLOCK
         // if any of the switches are flipped n will increment at every clock signal
         if (SWITCHES[0]==1|SWITCHES[1]==1|SWITCHES[2]==1|SWITCHES[3]==1) begin
         n<=n+1;
         end
         else begin	// if none of the switches are on then n will return back to 0 
         n<=32'b0;
         end
     end
    
   // always block to ensure that jackpot only triggers on the first time the switch is flipped rather than activating     
   // every time the lights cycle back around

    always@(posedge CLOCK) begin	// triggers at every positive edge of CLOCK
        if (n<=clockconstant*2) begin 
        // if n is less than or equal to the amount of CLOCK periods in a clockdiv period 
        // then S will take the value of SWITCHES
        // this way no matter when a switch is flipped, as long as it during a clockdiv period of a corresponding	         
        // LED lighting up, the jackpot will activate
            S<=SWITCHES;
        end
        else begin	// if n is larger than the twice the clockconstant, then S will be reset to zer0
            S<=4'b0;
        end 
    end
    
   // always block that controls in incrementation of the counter  
   // triggers if reset button is pushed or at the positive edge of slow clock

    always@(posedge RESET or posedge clockdiv) begin	
        if (RESET==1'b1) begin	// if the reset button is pressed count resets to 0
            count<=3'b0;
        end
        else if (S==LEDS) begin	// if the S value matches the value of the cycling LEDS 
            count<=3'b111;		// count will be set to its maximum value, 7
        end
        else begin
            if (count==countconstant) begin	// if count reaches its two bit max value, 3
                count<=3'b0;			// count will be reset to 0
            end
            else begin
                if (count==3'b111) begin	// if count is equal to 7
                    count<=count;		// then count will continually be driven with the value 7
                end
                else begin			// if count is not equal to 7 
                    count<=count+1;		// then count will continue to increment and be reset from 0-3
                end
            end
        end
    end
    
   // the maximum value of count, 7, was added to stop the incrementation of count if the jackpot was activated
   
   // always block to control the one-hot-encoding of LEDS according to the value of the counter

    always@(count) begin	// triggers if the value of count changes
        if (count==3'b0) begin	// if count is equal to zero
            LEDS<=4'b0;		// reset the value of LEDs
            LEDS[0]<=1'b1;		// LEDS=0001
        end
        else if (count==countconstant-2) begin	// if count is equal to one
            LEDS<=4'b0;				// reset the value of LEDs
            LEDS[1]<=1'b1;				// LEDS=0010
        end
        else if (count==countconstant-1) begin	// if count is equal to two
            LEDS<=4'b0;				// reset the value of LEDs
            LEDS[2]<=1'b1;				// LEDS=0100
        end
        else if (count==countconstant) begin		// if count is equal to three
            LEDS<=4'b0;				// reset the value of LEDs
            LEDS[3]<=1'b1;				// LEDS=1000
        end
        else if (count==3'b111) begin			// if count is equal to seven
            LEDS<=4'b1111;				// all LEDs will light up and jackpot is activated
        end
        else begin					// error case: no LEDs will light up
            LEDS<=4'b0;
        end 
    end
    
endmodule
