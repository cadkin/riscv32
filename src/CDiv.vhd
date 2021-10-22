--Divide clock Cin down to a lower frequency
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all;

ENTITY CDiv IS
	PORT ( Cin	: IN 	STD_LOGIC ;
	  Cout : OUT STD_LOGIC ) ;
END CDiv ;

ARCHITECTURE Behavior OF CDiv IS
	constant TC: integer := 20; --Time Constant for 100Mhz to ~1.5Hz 
                                --Use TC 15 for 100Mhz to ~1Khz
	signal c0,c1,c2,c3: integer range 0 to 1000;
	signal D: std_logic := '0';
BEGIN
	PROCESS(Cin)
	BEGIN
		if (Cin'event and Cin='1') then
			c0 <= c0 + 1;
			if c0 = TC then
				c0 <= 0;
				c1 <= c1 + 1;
			elsif c1 = TC then
				c1 <= 0;
				c2 <= c2 + 1;
			elsif c2 = TC then
				c2 <= 0;
				c3 <= c3 + 1;
			elsif c3 = TC then
				c3 <= 0;
				D <= NOT D;
			end if;
		end if;
		Cout <= D;
	END PROCESS ;
END Behavior ;
