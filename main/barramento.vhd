----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:02:53 06/01/2016 
-- Design Name: 
-- Module Name:    barramento - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barramento is
		port(
				clock, reset : in std_logic;
				hold : out std_logic;
				addressIn : in std_logic_vector(31 downto 0);
				addressOut: out std_logic_vector(31 downto 0);
				dataIn, dataOut : inout std_logic_vector(31 downto 0)
				);

end barramento;

architecture Behavioral of barramento is
signal counter : integer;
signal address : std_logic_vector(31 downto 0);
signal data : std_logic_vector(31 downto 0);

begin
--hold<='0';

process(clock, reset)
begin	
	if (reset = '1') then
		counter <= 0;
		hold <='0';
	elsif clock'event and clock='1' then
		address <= addressIn;
		data <= dataIn;
		if counter<2 then
			hold<='1';
			counter<= counter +1;
		else
			counter <= 0;
			addressOut <= address;
			dataOut <= data;
		end if;
	end if;
end process;
end Behavioral;

