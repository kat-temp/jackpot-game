#include <xparameters.h>
#include <xgpio.h>
#include <xstatus.h>
#include <xil_printf.h>

// definitions visible and modifiable everywhere
// GPIO device that the leds are connected to 
#define LED_DEVICE_ID XPAR_LED_DEVICE_ID
// GPIO device that the switches and buttons are connected to
#define SW_BTN_DEVICE_ID XPAR_SW_BTN_DEVICE_ID
// value used in the delay function 
#define WAIT_VAL 0x1000000

int delay(void);	// declaring the delay function defined later in the program

int main() {

    int count;		// an integer used to keep track of the counter value
    int led_output;	// an integer for the value of the leds printed to the console
    XGpio leds;	// variable in the gpio block for the output of the leds
    XGpio sw_btns;	// variable in the gpio block for the input of the switches and buttons
    int status;		// integer to ensure correct initialization for the leds
    int status1;		// integer to ensure correct initialization for the switches and buttons
    int switches;	// integer holding the read value of the switches

    // initialing the gpio drivers
    status = XGpio_Initialize(&leds, LED_DEVICE_ID);
    status1 = XGpio_Initialize(&sw_btns, SW_BTN_DEVICE_ID);
    // setting the direction of the leds to be outputs
    XGpio_SetDataDirection(&leds, 1, 0x00);
    // setting the direction of the switches and buttons to be inputs
    XGpio_SetDataDirection(&sw_btns,1,0xFF);
    // checking for correct initializaton
    if(status != XST_SUCCESS) {
        xil_printf("Initialization failed");
    }
    count = 0;	// setting the initial count value
    while(1) {	// function that will loop indefinitely 
        // if the first 4 bits of the discrete read value of the inputs is equal to 0001
        // its means the first button was pressed 
        if((0xF0 & XGpio_DiscreteRead(&sw_btns, 1))==0x10){	
        // the current action and value of the leds is printed to the screen
        xil_printf("BUTTON ONE PRESSED : LEDs = 0x%x \n\r", led_output);
        count++; // increasing the value of the counter at the time set by the delay function
        }
        // if the first 4 bits of the discrete read value of the inputs is equal to 0010
        // its means the second button was pressed
        else if((0xF0 & XGpio_DiscreteRead(&sw_btns, 1))==0x20){
        // the current action and value of the leds is printed to the screen
        xil_printf("BUTTON TWO PRESSED : LEDs = 0x%x \n\r", led_output);
        count--;  // decreasing the value of the counter at the time set by the delay function
        }
        // if the first 4 bits of the discrete read value of the inputs is equal to 0100
        // its means the third button was pressed
        else if((0xF0 & XGpio_DiscreteRead(&sw_btns, 1))==0x40){
        // integer switches is given the value of the board inputs from the discrete read 
        switches=XGpio_DiscreteRead(&sw_btns, 1);
        // masked so the only the 4 lower bits corresponding to the switches are used        
        led_output=switches & 0xF;	
        // masked value is written to the leds on the board 
        XGpio_DiscreteWrite(&leds, 1, led_output);
        // the current action and value of the leds is printed to the screen
        xil_printf("BUTTON THREE PRESSED : LEDs = 0x%x \n\r", led_output);
        count=count;	// integer count does not change
        }
        // if the first 4 bits of the discrete read value of the inputs is equal to 1000
        // its means the fourth button was pressed
        else if((0xF0 & XGpio_DiscreteRead(&sw_btns, 1))==0x80){
        count=count;	// integer count does not change
        // counter value masked so only the 4 lower bits are used        
        led_output = count & 0xF;	
        // write the masked value to the leds on the board
        XGpio_DiscreteWrite(&leds, 1, led_output);
        // print the current action and value of the leds to the console
        xil_printf("BUTTON FOUR PRESSED : LEDs = 0x%x \n\r", led_output);
        }
        else {	// in case of error
        count=count;	// integer count stays the same 
        switches=switches;	// integer switches stays the same 
        }

        delay();	// calling the delay function to slow down the incrementation of count
    }
    return (0);
}

int delay(void) {	// delay function that takes no arguements
    volatile int delay_count = 0;	// integer keeping track of delay value initialized to 0
    // declared as volatile b/c value can change any time w/o action of the code around it
    while(delay_count < WAIT_VAL)
    // if the delayed count value is the less than the definition at the top of the code
    // the delayed count value gets incremented by one
        delay_count++;
    // once it reaches the definition value it gets set back to one
    return(0);
}
