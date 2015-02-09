LIBRARY IEEE;
USE std.standard.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY voltimetro IS
  PORT(
    clk:		IN STD_LOGIC; --reloj interno
    bcdUnids:		OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --display 1
    bcdDecen:		OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --display 2
    muestreo_analogico: IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    CANAL: 		OUT STD_LOGIC_VECTOR(2 DOWNTO 0);		
    CS:			OUT STD_LOGIC;
    RD:			OUT STD_LOGIC;
    INT:		IN STD_LOGIC;
    MODE:		OUT STD_LOGIC
  );
END voltimetro;

ARCHITECTURE proceso OF voltimetro IS

  COMPONENT display7 --display
    PORT ( 
      input : integer RANGE 0 TO 10;
      output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL unidades : integer RANGE 0 TO 10;
  SIGNAL decenas : integer RANGE 0 TO 10;
  SIGNAL senal : STD_LOGIC:='1';
	
  BEGIN
    displayUnids : display7			
      PORT MAP (
	input => unidades,
	output => bcdDecen
      );
	
    displayDecen : display7			
      PORT MAP (
	input => decenas,
	output => bcdUnids
      );

    MODE <= '0';
    CANAL <= "000";
    CS <= senal;
    RD <= senal;
    --A/D
    PROCESS (clk)
      VARIABLE ciclos: INTEGER RANGE 0 TO 251750:=0; --Contador de ciclos
      BEGIN
	IF clk'event AND clk = '1' THEN
	  ciclos:=ciclos+1;
	    IF (ciclos >= 251748) THEN
	      senal <= NOT(senal);
	    END IF;
	END IF;
    END PROCESS;

    PROCESS (INT)
      VARIABLE tension:INTEGER RANGE 0 TO 255:=0;
	BEGIN
	  IF INT'event AND INT='0' THEN
	    tension:= (conv_integer(unsigned(muestreo_analogico))*50)/255;
	    unidades <= tension/10;
	    decenas <= tension rem 10;
	  END IF;
    END PROCESS;
END proceso;