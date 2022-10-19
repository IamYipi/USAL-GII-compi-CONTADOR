/*
Computadores I - GIV - USAL

TRABAJO COMPUTADORES: SECUENCIA CON NUMEROS REPETIDOS

SECUENCIA ORIGINAL..:

6 - 4 - 2 - 2 - 4 - 14 - 3 - 13 - 0 - 0

SECUENCIA MODIFICADA:

6 - 4 - 2 - 5 - 7 - 14 - 3 - 13 - 0 - 1 

-----------------------------------------------------
En esta solución se incluyen:
 
14 AND de 2 entradas 
4  OR  de 3 entradas
3  OR  de 2 entradas 
4  biestables JK 
===========
21 PUERTAS

Por:    JAVIER GARCÍA PECHERO 
		Y
	ÁLVARO GARCÍA LABRADOR
*/


//Modulo del biestable JK
module JK(output reg Q, output wire NQ, input wire J, input wire K,   input wire C);
  not(NQ,Q);

  initial
  begin
    Q=0;
  end    

  always @(posedge C)
    case ({J,K})
      2'b10: Q=1;
      2'b01: Q=0;
      2'b11: Q=~Q;
    endcase
endmodule

//Módulo que contiene el contador y la circuitería auxiliar.
module contador (output wire[3:0] Q, input wire C);
  wire [3:0] nQ;

 //Cables de entrada a los biestables.
 wire sJ3,sK3,sJ2,sK2,sJ1,sK1,sJ0,sK0;
 //Cables auxiliares
 wire nq1q2,nq2q0,q1nq0;            //BIESTABLE J3K3
 wire nq0q3,nq1nq0,nq1q3;           //BIESTABLE J2K2
 wire q0nq2,nq3q2,nq0nq3,kq0nq2;    //BIESTABLE J1K1
 wire q1q3,nq1nq2,q1q2;             //BIESTABLE J0K0

  //Puertas correspondientes al contador dividido en biestables
//J3
 and J3 (sJ3, Q[0],Q[1]);
//K3
 and K31(nq1q2,nQ[1],Q[2]);
 and K32(nq2q0,nQ[2],Q[0]);
 and K33(q1nq0,Q[1],nQ[0]);
 or K3O(sK3,nq1q2,nq2q0,q1nq0);
//J2
 or J21(sJ2,Q[0],Q[1],Q[3]);
//K2
 and K21(nq0q3,nQ[0],Q[3]);
 and K22(nq1nq0,nQ[1],nQ[0]);
 and K23(nq1q3,nQ[1],Q[3]);
 or K2o(sK2,nq0q3,nq1nq0,nq1q3);
//J1
 and j11(q0nq2,Q[0],nQ[2]);
 and j12(nq3q2,nQ[3],Q[2]);
 or j1o(sJ1,q0nq2,nq3q2);
//K1
 and k11(nq0nq3,nQ[0],nQ[3]);
 and k12(kq0nq2,Q[0],nQ[2]);
 or k1o(sK1,nq0nq3,kq0nq2);
//J0
 and j01(q1q3,Q[1],Q[3]);
 or j0o(sJ0,q1q3,nQ[2]);
//K0
 and k01(nq1nq2,nQ[1],nQ[2]);
 and k02(q1q2,Q[1],Q[2]);
 or k0o(sK0,nq1nq2,q1q2,Q[3]);

//LLAMAMIENTO MÓDULO DE CADA BIESTABLE
  JK jk3 (Q[3], nQ[3], sJ3, sK3, C);
  JK jk2 (Q[2], nQ[2], sJ2, sK2, C);
  JK jk1 (Q[1], nQ[1], sJ1, sK1, C);
  JK jk0 (Q[0], nQ[0], sJ0, sK0, C);

endmodule

/*
 =============================
   SECUENCIA        ORIGINAL
 =============================
 En esta solucion se incluye:
  4 NOT    de 1 entrada
  7 AND    de 2 entradas
  1 AND    de 3 entradas
  1 AND    de 4 entradas
  1 OR 	   de 2 entradas
  1 OR 	   de 3 entradas
  1 OR 	   de 4 entradas
  1 BUFFER de 1 entrada
==============================
17 PUERTAS
			*/

//Módulo cambio secuencia
module convertir(output wire [3:0] O, input wire [3:0] I);
wire nI0,nI1,nI2,nI3;			//CABLES NOT
wire nI2I1I0,I3I0;			//CABLES SO0
wire nI3I2nI1I0,nI2I1,I1nI0,I3I1;	//CABLES S01
wire nI0I2,I1I2,I3I2;			//CABLES SO2

//NOT
	not (nI0,I[0]);
	not (nI1,I[1]);
	not (nI2,I[2]);
	not (nI3,I[3]);


//O0
	and O01(nI2I1I0,nI2,I[1],I[0]);
	and O02(I3I0,I[3],I[0]);
	or O0o(O[0],nI2I1I0,I3I0);
//O1
	and (nI3I2nI1I0,nI3,I[2],nI1,I[0]);
	and (nI2I1,nI2,I[1]);
	and (I1nI0,I[1],nI0);
	and (I3I1,I[3],I[1]);

	or (O[1],nI3I2nI1I0,nI2I1,I1nI0,I3I1); 
//O2
	and (nI0I2,nI0,I[2]);
	and (I1I2,I[1],I[2]);
	and (I3I2,I[3],I[2]);

	or (O[2],nI0I2,I1I2,I3I2);
//O3
	buf (O[3],I[3]);
endmodule

//Módulo para probar el circuito.
module testreal;
  wire [3:0] D;
  wire [3:0] Q;
  reg I, C;
  contador c(Q,C);
  convertir c1 (D,Q);
  
  always 
  begin
    #10 C=~C;
  end

  initial
  begin
    $monitor($time," Q = %b (%d) , D = %b (%d) , C = %b (%d)", Q,Q,D,D,C,C);
    $dumpfile("dump.dmp");
    $dumpvars(2, c1, D);  
    $dumpvars(2, c, Q);
    C=0;
    #500 $finish;
  end
endmodule

