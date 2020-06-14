-------------------------------------------------------------------------------
-- Title      : VHDL ADS1115 Interfacing 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi-core-adc.vhd
-- Author     : Kayas Ahmed  <kayadev@gmail.com>
-- Company    : - 
-- Created    : 2020-04-05
-- Last update: 2020-04-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: ADS1115 is interfaced receving sample data in uart interface
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-04-05  1.0      kayas-ws	Created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ads1115_top is

  port (
    clk   : in std_logic;
    n_rst : in std_logic;
    sda   : inout std_logic;
    scl   : inout std_logic;
    tx    : out std_logic;
    led   : out std_logic_vector(2 downto 0));
end entity;
architecture rtl of ads1115_top is

  signal s_debeg_data : std_logic_vector(7 downto 0);
  signal s_enbale_log : std_logic;
  signal s_ena        : std_logic; --latch in command
  signal s_addr       : std_logic_vector(6 downto 0); --address of target slave
  signal s_rw         : std_logic; --'0' is write, '1' is read
  signal s_data_wr    : std_logic_vector(7 downto 0); --data to write to slave
  signal s_busy       : std_logic; --indicates transaction in progress
  signal s_data_rd    : std_logic_vector(7 downto 0); --data read from slave
  signal s_ack_error  : std_logic; --flag if improper acknowledge from slave

  component i2c_master is
    generic (
      input_clk : integer := 50_000_000; --input clock speed from user logic in Hz
      bus_clk   : integer := 400_000); --speed the i2c bus (scl) will run at in Hz
    port (
      clk       : in std_logic; --system clock
      reset_n   : in std_logic; --active low reset
      ena       : in std_logic; --latch in command
      addr      : in std_logic_vector(6 downto 0); --address of target slave
      rw        : in std_logic; --'0' is write, '1' is read
      data_wr   : in std_logic_vector(7 downto 0); --data to write to slave
      busy      : out std_logic; --indicates transaction in progress
      data_rd   : out std_logic_vector(7 downto 0); --data read from slave
      ack_error : buffer std_logic; --flag if improper acknowledge from slave
      sda       : inout std_logic; --serial data output of i2c bus
      scl       : inout std_logic); --serial clock output of i2c bus
  end component;

begin

  uart_logger : entity work.Uart_debug
    generic map(
      BAUD_RATE            => 115200,
      SYSTEM_CLK_PERIOD_NS => 50)
    port map(

      clk     => clk,
      rst	=>n_rst,
      uart_in => s_debeg_data,
      we      => s_enbale_log,
      txd     => tx);

  i2c_core : entity work.i2c_master
    port map(
      clk       => clk,
      reset_n   => n_rst,
      ena       => s_ena,
      addr      => s_addr,
      rw        => s_rw,
      data_wr   => s_data_wr,
      busy      => s_busy,
      data_rd   => s_data_rd,
      ack_error => s_ack_error,
      sda       => sda,
      scl       => scl
      );

  ADC1115 : entity work.ads1115
    port map(
      clk        => clk,
      n_rst      => n_rst,
      enable     => s_ena,
      busy       => s_busy,
      addr       => s_addr,
      rw         => s_rw,
      data_wr    => s_data_wr,
      data_rd    => s_data_rd,
      ack_error  => s_ack_error,
      debeg_data => s_debeg_data,
      we         => s_enbale_log,
      led        => led
      );
end rtl;
