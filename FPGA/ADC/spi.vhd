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
use IEEE.numeric_std.all;

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
			  COMPLETE : out STD_LOGIC
--			  RISING_TOGGLE : inout STD_LOGIC;
--			  FALLING_TOGGLE : inout STD_LOGIC
				);
end spi_slave;

architecture Behavioral of spi_slave is
	signal miso_buffer : STD_LOGIC_VECTOR (W-1 downto 0);
	signal mosi_buffer : STD_LOGIC_VECTOR (W-1 downto 0);

	signal data_valid : STD_LOGIC_VECTOR(2 downto 0);
	signal data_synced : STD_LOGIC_VECTOR(2 downto 0);
	signal data : STD_LOGIC_VECTOR(W-1 downto 0);
	
	signal bit_cnt : STD_LOGIC_VECTOR(W-1 downto 0);
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			data_valid(2 downto 1) <= data_valid(1 downto 0);
			if data_valid(2) = '1' then
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

	MISO <= miso_buffer(W-1) when CS = '0' else 'Z';

	slave_in: process(SPI_CLK)
	begin
		if rising_edge(SPI_CLK) then
--			FALLING_TOGGLE <= not FALLING_TOGGLE;
			data_synced(2 downto 1) <= data_synced(1 downto 0);
			if bit_cnt(W-2) = '1' then
				-- this was the last bit
				data_valid(0) <= '1';
				data <= mosi_buffer(W-2 downto 0) & MOSI;
			else
				if data_valid(0) = '1' and data_synced(2) = '1' then
					data_valid(0) <= '0';
				end if;
				mosi_buffer <= mosi_buffer(W-2 downto 0) & MOSI;
			end if;
		end if;
	end process;
	
	slave_out: process(SPI_CLK, CS)
	begin
		if CS = '1' then
			miso_buffer <= BUF_IN;
			bit_cnt <= (others => '0');
		elsif falling_edge(SPI_CLK) then
--			RISING_TOGGLE <= not RISING_TOGGLE;
			if bit_cnt(W-2) = '1' then
				bit_cnt <= (others => '0');
				miso_buffer <= BUF_IN;
			else
				bit_cnt <= bit_cnt(W-2 downto 0) & '1';
				miso_buffer <= miso_buffer(W-2 downto 0) & '0';
			end if;
		end if;
	end process;

end Behavioral;
