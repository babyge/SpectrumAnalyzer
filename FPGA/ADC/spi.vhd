----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:14:17 03/05/2019 
-- Design Name: 
-- Module Name:    spi_slave - Behavioral 
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

entity spi_slave is
	generic ( W : integer);
    Port ( SPI_CLK : in  STD_LOGIC;
           MISO : out  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           CS : in  STD_LOGIC;
			  BUF_OUT : out STD_LOGIC_VECTOR (W-1 downto 0) := (others => '0');
			  BUF_IN : in STD_LOGIC_VECTOR (W-1 downto 0);
           CLK : in  STD_LOGIC;
			  COMPLETE : out STD_LOGIC);
end spi_slave;

architecture Behavioral of spi_slave is
	signal miso_buffer : STD_LOGIC_VECTOR (W-1 downto 0);
	signal mosi_buffer : STD_LOGIC_VECTOR (W-1 downto 0);

	signal data_valid : STD_LOGIC_VECTOR(1 downto 0);
	signal data_synced : STD_LOGIC_VECTOR(1 downto 0);
	signal data : STD_LOGIC_VECTOR(W-1 downto 0);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			data_valid(1) <= data_valid(0);
			if data_valid(1) = '1' then
				if data_synced(0) = '0' then
					BUF_OUT <= data;
					COMPLETE <= '1';
					data_synced(0) <= '1';
				else
					COMPLETE <= '0';
				end if;
			else
				COMPLETE <= '0';
				data_synced(0) <= '0';
			end if;
		end if;
	end process;

	MISO <= miso_buffer(W-1);-- when CS = '0' else 'Z';

	process(SPI_CLK, CS)
	begin
		if CS = '1' then
			-- reset state machine
			miso_buffer <= BUF_IN;
			mosi_buffer <= (W-1 downto 1 => '0') & '1';
		else
			if rising_edge(SPI_CLK) then
				data_synced(1) <= data_synced(0);
				if mosi_buffer(W-1) = '1' then
					-- this was the last bit
					data_valid(0) <= '1';
					data <= mosi_buffer(W-2 downto 0) & MOSI;
					mosi_buffer <= (W-1 downto 1 => '0') & '1';
				else
					if data_valid(0) = '1' and data_synced(1) = '1' then
						data_valid(0) <= '0';
					end if;
					mosi_buffer <= mosi_buffer(W-2 downto 0) & MOSI;
				end if;
			end if;
			if falling_edge(SPI_CLK) then
				if mosi_buffer = (W-2 downto 0 => '0') & '1' then
					miso_buffer <= BUF_IN;
				else
					miso_buffer <= miso_buffer(W-2 downto 0) & '0';
				end if;
			end if;
		end if;
	end process;

end Behavioral;

