LIBRARY IEEE;
USE std.standard;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY display7 IS
	PORT (
		input :IN integer RANGE 0 TO 10;
		output :OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END display7;

ARCHITECTURE dcse OF display7 IS
	BEGIN
	PROCESS(input)
		BEGIN
		CASE input IS               
  			when 0 => output <= "00000011";
			when 1 => output <= "10011111";
			when 2 => output <= "00100101";
			when 3 => output <= "00001101";
			when 4 => output <= "10011001";
			when 5 => output <= "01001001";
			when 6 => output <= "01000001";
			when 7 => output <= "00011111";
			when 8 => output <= "00000001";
			when 9 => output <= "00011001";
			when others => output <= "11111101";
		END CASE;
	END PROCESS;
END dcse;