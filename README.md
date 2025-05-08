This project is about UART protocol implementation on FPGA(zedboard),
The design verification approaches of uart are of two approaches,


1. Parallel-Serial-Parallel(PSP)
   ""Giving serial input to receiver, connecting output of receiver to the input of     transmitter and verifying the output of transmiiter, which is serial output""           uarttop00.v,uarttoptb00.v

2. Serial-Parallel-Serial(SPS)
   ""Giving serial input to receiver, connecting output of receiver to the input of     transmitter and verifying the output of transmiiter, which is serial output""
   RESPECTIVE FILES OF THIS APPROACH,    uarttop01.v,uarttoptb01.v



But only the second part is realizable on the FPGA(Zed board).


FOR THE ABOVE TWO APPROACHES, BIST CAN ALSO BE ADDED FOR INBUILT CIRCUIT VERIFICATION.
RESPECTIVE FILES FOR "PSP": bist00.v,bisttb00.v   
RESPECTIVE FILES FOR "SPS": bist01.v,bisttb01.v

