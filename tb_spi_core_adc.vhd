

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_spi_core_adc is
end entity;
architecture tb of tb_spi_core_adc is

signal clk: std_LOGIC;
signal n_rst: std_LOGIC;
signal sda	: std_LOGIC;
signal scl 	: std_LOGIC;
signal led 		:std_logic_vector(2 downto 0);
begin


module: entity work.spi_core_adc

port map(
	clk     => clk,
	n_rst   => n_rst,
   sda     => sda ,                
   scl     => SCL ,
	tx		=> OPEN,	
	led	 => led);
	end tb;