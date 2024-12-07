.INCLUDE "AVR64DU32def.inc"
//Define MACROS
.MACRO LoadTwoBytes	//low, high, value
    LDI R16, HIGH(@2)	//generating delay 0xFFFF - 0xFEA0 + 1
    STS @1, R16		//I can reuse this again
    LDI R16, LOW(@2)
    STS @0, R16
.ENDMACRO

.MACRO LoadOneByte  //location, numberToLoad
    LDI R16, @1	    // load 1 byte into r16
    STS @0, R16	    // store to data space the value stored in r16
.ENDMACRO

.EQU GREEN  = 0b00000001 // Green light PA0
.EQU YELLOW = 0b00000010 // Yellow light PA1
.EQU AIN1   = 0b00000100 //AIN1 = PA2
.EQU AIN2   = 0b00001000 //AIN2 = PA3
.EQU BIN1   = 0b00010000 //BIN1 = PA4
.EQU BIN2   = 0b00100000 //BIN2 = PA5
.EQU RED    = 0b01000000 //Red light PA6

.EQU C0 = 1000 //20% CMP value
.EQU C1 = 1250 //25% CMP value
.EQU C2 = 2500 //50% CMP value
.EQU C3 = 3750 //75% CMP value
.EQU TO = 5000 //TOP value
.EQU B = 0x683 //BAUD, 9600bps

.ORG 0x00
RJMP Main

//RXC for USART1:
.ORG 0x34 
RJMP ReceiveISR

.ORG 0x100
Main:
//Initialize SP:
LoadTwoBytes CPU_SPL, CPU_SPH, RAMEND

//Setup TCA0:
//Dual slope mode, BOTTOM,CMP0,CMP1 enable:
//CMP0->WO0
//CMP1->WO1
LoadOneByte TCA0_SINGLE_CTRLB,0b110111
LoadOneByte PORTMUX_TCAROUTEA,0b11
//PD0 is WO0 & PD1 is WO1:
LoadOneByte PORTD_DIRSET,0b11
//Enable peripheral, N = 8:
LoadOneByte TCA0_SINGLE_CTRLA,0b111
//Load CMP0 & CMP1 value:
LoadTwoBytes TCA0_SINGLE_CMP0L,TCA0_SINGLE_CMP0H,C2
LoadTwoBytes TCA0_SINGLE_CMP1L,TCA0_SINGLE_CMP1H,C2
//Load PER value:
LoadTwoBytes TCA0_SINGLE_PERL,TCA0_SINGLE_PERH,TO

//Set direction for my outputs:
LoadOneByte PORTA_DIRSET,AIN1
LoadOneByte PORTA_DIRSET,AIN2
LoadOneByte PORTA_DIRSET,BIN1
LoadOneByte PORTA_DIRSET,BIN2
LoadOneByte PORTA_DIRSET,GREEN
LoadOneByte PORTA_DIRSET,YELLOW
LoadOneByte PORTA_DIRSET,RED

//Setup USART1:
//Set BAUD rate to 9600:
LoadTwoBytes USART1_BAUDL, USART1_BAUDH,B
//Change route of USART1 to PD:
LoadOneByte PORTMUX_USARTROUTEA, 0b10000
//Make PD6 input for Tx
LoadOneByte PORTD_DIRSET, 0b1000000
//Make PD7 input for Rx
LoadOneByte PORTD_DIRCLR, 0b10000000
//Tx and Rx sends 8-bits:
LoadOneByte USART1_CTRLC, 0b11
//Enable interrupts:
//RXC:
LoadOneByte USART1_CTRLA, 0b10000000
//Enable USART0 Tx and Rx:
LoadOneByte USART1_CTRLB, 0b11000000

SEI

Transmit:
CALL DelaySR1
LDS R16, USART1_STATUS
//Check if data register is empty:
SBRC R16, 5
LoadOneByte USART1_TXDATAL, 0x55
RJMP Transmit

//*****************************************************************************
/* So this is how it works:
 * The distance window is: 100mm <= d <= 300mm
 * If d <= 100mm, start spinning.
 * Inside the window, slow down.
 * If d >= 300mm, move forward at high speed.
 */
.ORG 0x200
ReceiveISR:
//Load high byte of distance:
LDS R17, USART1_RXDATAL
//Wait for US100 to send the next byte of data:
CALL DelaySR1
//Load low byte of distance:
LDS R16, USART1_RXDATAL
//Checking high byte:
//If high byte is zero->need to check low byte if less than...
//...100 or greater than 100:
CPI R17, 0x0
BREQ CheckLowByte0
//If high byte is 0x1->Check low byte since 0x1FF = 511 and ...
//...0x100 = 256
CPI R17, 0x1
BREQ CheckLowByte1
//If high byte is 0x2->Move fast since 0x2FF = 767 and...
//...0x200 = 512, therefore we don't care about low byte.
CPI R17, 0x2
BREQ MoveFast
RETI //For safety, return from interrupt
//*****************************************************************************
CheckLowByte1:
//If d >= 300mm -> move fast, else if d < 300 -> spin
CPI R16, 0x2C
BRGE MoveFast
RJMP StartSpinning
CheckLowByte0:
//If d >= 100mm -> move slow, else if d < 100mm -> spin.
CPI R16, 100
BRGE MoveSlow
RJMP StartSpinning
//*****************************************************************************
StartSpinning:
LoadOneByte PORTA_OUTCLR, GREEN
LoadOneByte PORTA_OUTCLR, YELLOW
LoadOneByte PORTA_OUTSET, RED
//Configure speed of motors:
CALL SpeedUpMotorA
CALL SlowMotorB
//Configure direction of motors:
CALL Spin
//Spin longer:
//30ms Delay
//CALL DelaySR1
RETI
//*****************************************************************************
MoveSlow:
//Set Slow Speed, move forward:
LoadOneByte PORTA_OUTCLR, GREEN
LoadOneByte PORTA_OUTSET, YELLOW
LoadOneByte PORTA_OUTCLR, RED
//Configure speed of motors:
CALL SlowMotorB
CALL SlowMotorA
//Configure direction of motors:
CALL Forward
RETI
//*****************************************************************************
MoveFast:
//Set Normal Speed, move forward:
LoadOneByte PORTA_OUTSET, GREEN
LoadOneByte PORTA_OUTCLR, YELLOW
LoadOneByte PORTA_OUTCLR, RED
//Configure speed of motors:
CALL SpeedUpMotorB
CALL SpeedUpMotorA
CALL Forward
RETI
//*****************************************************************************
//**************DIRECTION SUBROUTINES**************************
//Forward Subroutine
Forward:
.ORG 0x250
LoadOneByte PORTA_OUTSET,AIN1 //AIN1 High
LoadOneByte PORTA_OUTCLR,AIN2 //AIN2 Low
LoadOneByte PORTA_OUTCLR,BIN1 //BIN1 Low
LoadOneByte PORTA_OUTSET,BIN2 //BIN2 High
RET
//*****************************************************************************
//Spin Subroutine
Spin:
.ORG 0x300
LoadOneByte PORTA_OUTSET,AIN1 //AIN1 High
LoadOneByte PORTA_OUTCLR,AIN2 //AIN2 Low
LoadOneByte PORTA_OUTSET,BIN1 //BIN1 High
LoadOneByte PORTA_OUTCLR,BIN2 //BIN2 Low
RET
//*****************************************************************************
//**************SPEED SUBROUTINES**************************
//Slow motors subroutines:
SlowMotorB:
.ORG 0x350
//Load CMP0 value:
LoadTwoBytes TCA0_SINGLE_CMP0L,TCA0_SINGLE_CMP0H,C0
RET
SlowMotorA:
.ORG 0x400
//Load CMP1 value:
LoadTwoBytes TCA0_SINGLE_CMP1L,TCA0_SINGLE_CMP1H,C0
RET
//*****************************************************************************
//Speed Up Subroutine:
SpeedUpMotorB:
.ORG 0x450
//Load CMP value:
LoadTwoBytes TCA0_SINGLE_CMP0L,TCA0_SINGLE_CMP0H,C3//+90//Since...
//...motor B seems to be spinning slower.
RET
SpeedUpMotorA:
.ORG 0x500
//Load CMP value:
LoadTwoBytes TCA0_SINGLE_CMP1L,TCA0_SINGLE_CMP1H,C3
RET
//*****************************************************************************
//**************DELAY SUBROUTINES**************************
.ORG 0x550
//30ms delay
DelaySR1:
LoadTwoBytes TCB0_CNTL, TCB0_CNTH, 5536
//Enable TCB counter, N = 2
LoadOneByte TCB0_CTRLA, 0b11 
OF_FLAG1:
LDS R24, TCB0_INTFLAGS
SBRS R24, 1
RJMP OF_FLAG1
LoadOneByte TCB0_INTFLAGS, 0b10
RET

