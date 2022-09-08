#include <16f887.h>
#FUSES XT,NOPROTECT,NOWDT,NOBROWNOUT,PUT,NOLVP
#use delay(clock=20M)
#byte trisb=0x86
#byte portb=0x06
#byte trisc=0x87
#byte portc=0x07
#byte trisd=0x88
#byte portd=0x08

Byte CONST display[16]= {
      00111111,       //0
      00000110 ,       //1
      01011011 ,       //2
      01001111  ,      //3
      01100110 ,       //4
      01101101  ,      //5
      01111101 ,         //6
      00000111 ,         //7
      01111111  ,        //8
      01101111 ,         //9
      01110111  ,        //A
      01111100  ,        //B
      00111001 ,         //C
      01011110  ,        //D
      01111001  ,        //E
      01110001          //F
};
int b=0;
int c=0;
int d=0;

void main(){
trisb=0;
portb=0;
trisc=0;
portc=0;
trisd=0;
portd=0;

   while(TRUE)
   {
   for (b=0; b<=255; b++){
   delay_ms(250);
   portb=b;
   portc=b;
   }
   d = c+b;
   delay_ms(1000);
   portd= d;

   }
}
