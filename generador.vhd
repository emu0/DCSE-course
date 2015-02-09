LIBRARY lpm;
LIBRARY ieee;

USE ieee.std_logic_1164.All;
USE ieee.std_logic_arith.All;
USE ieee.std_logic_unsigned.All;
USE lpm.lpm_components.All;

ENTITY generador IS
  PORT(
    clk:		IN STD_LOGIC;
    swt_frecuencia:	IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    swt_amplitud:	IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    swt_tipo:		IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		
    SALIDAA:		BUFFER STD_LOGIC;
    CS:			BUFFER STD_LOGIC;                        
    WR:			BUFFER STD_LOGIC;                                   
    CLEAR		OUT STD_LOGIC;
    DATA:		OUT INTEGER RANGE 0 TO 255;
    LDAC:		OUT STD_LOGIC
  );
END generador;

ARCHITECTURE proceso OF generador IS	

  CONSTANT referencia:		INTEGER := 98;
  SIGNAL contador:		INTEGER RANGE 0 TO 25175;
  SIGNAL conversion:		STD_LOGIC;
  SIGNAL frecuencia: 		INTEGER RANGE 0 TO 50;            
  SIGNAL amplitud: 		INTEGER RANGE 1 TO 5;                        
  SIGNAL salida: 		STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL puntero:		STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL muestra_seno:		STD_LOGIC_VECTOR(7 DOWNTO 0);    
  SIGNAL muestra_sierra:	STD_LOGIC_VECTOR(7 DOWNTO 0); 
  SIGNAL muestra_triangular:	STD_LOGIC_VECTOR(7 DOWNTO 0);      
	
  COMPONENT LPM_ROM
    GENERIC (
      INTENDED_DEVICE_FAMILY:	STRING;
      LPM_WIDTH:		POSITIVE; 
      LPM_WIDTHAD:		POSITIVE;
      LPM_NUMWORDS:		NATURAL:= 0;
      LPM_ADDRESS_CONTROL:	STRING:= "REGISTERED";
      LPM_OUTDATA:		STRING:= "REGISTERED";
      LPM_FILE:			STRING;
      LPM_TYPE:			STRING:= "LPM_ROM";
      LPM_HINT:			STRING:= "UNUSED"
    );
    PORT (
      address:			IN STD_LOGIC_VECTOR(LPM_WIDTHAD-1 DOWNTO 0);
      inclock, outclock:	IN STD_LOGIC := '0';
      memenab:			IN STD_LOGIC := '1';
      q:			OUT STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0)
    );
  END COMPONENT;

  BEGIN
    SALIDAA<='0';	
    LDAC<='0';		
    CLEAR<='1';		
    DATA <= CONV_INTEGER(salida)/amplitud;
    CS<=conversion;
    WR<=conversion;

    WITH swt_frecuencia SELECT
    frecuencia<=2 WHEN "01", --frecuencia de 1Khz
		3 WHEN "10", --frecuencia de 1.5 Khz
		4 WHEN "11", --frecuencia de 2Khz
		1 WHEN OTHERS; --frecuencia de 500 hz
				
    --Para la amplitud
    WITH swt_amplitud SELECT
    amplitud<=2 WHEN "01",--(5/2)V
	      3 WHEN "10",--(5/3)V
	      5 WHEN "11",--1V
	      1 WHEN OTHERS;-- 5V 

    tabla_seno: LPM_ROM 
      GENERIC MAP(
	intended_device_family => "FLEX10K",
	lpm_width=>8, 
	lpm_widthad=>8,
	lpm_file=>"seno.mif"
      )
      PORT MAP(
	address=>puntero, 
	inclock=>conversion, 
	outclock=>conversion, 
	q=>muestra_seno					
      );
		
    tabla_sierra: LPM_ROM 
      GENERIC MAP(
	intended_device_family => "FLEX10K",
	lpm_width=>8,
	lpm_widthad=>8,
	lpm_file=>"sierra.mif"
      )
      PORT MAP(
	address=>puntero, 
	inclock=>conversion, 
	outclock=>conversion, 
	q=>muestra_sierra			
      );
	
    tabla_triangular: LPM_ROM 
      GENERIC MAP(
	intended_device_family => "FLEX10K",
	lpm_width=>8, 
	lpm_widthad=>8,
	lpm_file=>"triangular.mif"
      )
      PORT MAP(
	address=>puntero, 
	inclock=>conversion, 
	outclock=>conversion, 
	q=>muestra_triangular	
      );
	
    PROCESS(clk)--genera reloj
      BEGIN
	IF clk'event AND clk='1' THEN
	  contador<=contador+1;
	  IF contador=(referencia/frecuencia) THEN
	    conversion<=NOT (conversion);
	    contador<=0;
	  END IF;
	END IF;
    END PROCESS;
	
    PROCESS (conversion) --muestrea tabla
      BEGIN
	IF conversion'event AND conversion='0' THEN
	  puntero<=puntero+1;
	    IF puntero="11111111" THEN
	      puntero<="00000000";
	    END IF;
	END IF;
    END PROCESS;
	
    PROCESS(WR) --salida de función
      BEGIN
	IF  WR'event AND wr = '0' THEN
	  IF swt_tipo = "01" THEN 		
	    salida <= muestra_triangular;
	  ELSIF swt_tipo = "10" THEN 	
	    salida <= muestra_sierra;
	  ELSE						
	    salida <= muestra_seno;		
	  END IF;
	END IF;
    END PROCESS;
END proceso;