-------------------------------------------------------------------------------
-- Title      : ADS1115 VHDL interfacing
-- Project    : ADS1115
-------------------------------------------------------------------------------
-- File       : ads1115.vhd
-- Author     : kayas-  <kayasdev@gmai.com>
-- Company    : 
-- Created    : 2020-04-05
-- Last update: 2020-04-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Simple example of ads1115 interfacing with FPGA
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
use work.ads1115_package.all;

entity ads1115 is
  generic (
    default_config : config_reg := (os => '1', pin_mux => "010", pga => "000", mode => '1', dr => "111", cmp_mode => '1', cmp_pol => '0', cmp_lat => '0', cmp_que => "11")
    );
  port (
    clk        : in std_LOGIC;
    n_rst      : in std_LOGIC;
    enable     : out std_LOGIC;
    busy       : in std_LOGIC;
    addr       : out std_logic_vector(6 downto 0);
    rw         : out std_logic;
    data_wr    : out std_logic_vector(7 downto 0);
    data_rd    : in std_logic_vector(7 downto 0);
    ack_error  : buffer STD_LOGIC;
    debeg_data : out std_logic_vector(7 downto 0);
    we         : out std_logic;
    led        : out std_logic_vector(2 downto 0));
end entity;
architecture rtl of ads1115 is

  type state is (IDLE, CONFIG, CONV_RDY, CONV_TRY, READ_CONV, SEND_DATA, END_S);

  --constant default_config : config_reg:=(os=>'1',pin_mux=>"010",pga=>"000",mode=>'1',dr=>"111",cmp_mode=>'1',cmp_pol=>'0',cmp_lat=>'0',cmp_que=>"11");
  constant I2CADDR_GND : std_logic_vector(6 downto 0) := "1001000";

  signal s_temp_config : config_reg;
  signal s_state       : state;

  signal read_config   : std_logic_vector(15 downto 0);
  signal read_data     : std_logic_vector(15 downto 0);
  signal lsb_byte      : std_logic;
  signal count         : integer := 0;
  signal busy_prev     : std_logic;
begin
  -- FSM 

  process (ack_error)
  begin
    led <= ack_error & busy & n_rst;
    if ack_error = '1' then
      led(2) <= '0';
    end if;
  end process;
  process (clk)
    variable temp_data : std_logic_vector(15 downto 0);
    variable busy_cnt  : integer range 0 to 3 := 0;
  begin

    addr <= I2CADDR_GND;

    if rising_edge(clk) then
      if n_rst = '0' then
        data_wr <= x"00";
        s_state <= IDLE;
        enable  <= '0';
      else

        we <= '0';

        case s_state is
          when IDLE =>
            s_state    <= CONFIG;
            debeg_data <= x"da";
                                        --we<='1';	
            enable     <= '0';
          when CONFIG =>
            busy_prev <= busy;
            if (busy_prev = '0' and busy = '1') then
              busy_cnt := busy_cnt + 1;
            end if;
            case busy_cnt is

              when 0 =>
                rw      <= '0';
                data_wr <= x"01";
                enable  <= '1';
              when 1 =>
                temp_data := config_to_std_vector(default_config);
                data_wr <= temp_data(15 downto 8);

              when 2 =>

                temp_data := config_to_std_vector(default_config);
                enable  <= '1';
                data_wr <= temp_data(15 downto 8);
              when 3 =>
                enable <= '0';
                if busy = '0' then
                  busy_cnt := 0;
                  s_state    <= CONV_TRY;
                  debeg_data <= x"01";
                                        --we<='1';
                end if;

            end case;
          when CONV_TRY =>
            busy_prev <= busy;
            if (busy_prev = '0' and busy = '1') then
              busy_cnt := busy_cnt + 1;
            end if;
            case busy_cnt is

              when 0 =>
                rw      <= '0';
                data_wr <= x"01";
                enable  <= '1';
              when 1 =>
                temp_data := config_to_std_vector(default_config);
                data_wr <= temp_data(15 downto 8);

              when 2 =>

                temp_data := config_to_std_vector(default_config);
                enable  <= '1';
                data_wr <= temp_data(15 downto 8);
              when 3 =>
                enable <= '0';
                if busy = '0' then
                  busy_cnt := 0;
                  s_state    <= CONV_RDY;
                  debeg_data <= x"02";
                                        --we<='1';
                end if;

            end case;
          when CONV_RDY =>
            busy_prev <= busy;
            if (busy_prev = '0' and busy = '1') then
              busy_cnt := busy_cnt + 1;
            end if;

            case busy_cnt is
              when 0 =>
                enable  <= '1';
                rw      <= '0';
                data_wr <= x"01";
              when 1 =>
                enable <= '0';
                if busy = '0' then
                  rw     <= '1';
                  enable <= '1';
                end if;
              when 2 =>
                if busy = '0' then

                  read_config(15 downto 8) <= data_rd;
                end if;
              when 3 =>
                enable <= '0';
                if busy = '0' then

                  read_config(7 downto 0) <= data_rd;
                  busy_cnt := 0;

                  if read_config(15) = '1' then
                    s_state <= READ_CONV;
                  end if;
                  debeg_data <= read_config(15 downto 8);
                                        --we<='1';
                end if;

            end case;

          when READ_CONV =>

            busy_prev <= busy;
            if (busy_prev = '0' and busy = '1') then
              busy_cnt := busy_cnt + 1;
            end if;

            case busy_cnt is

              when 0 =>
                enable  <= '1';
                rw      <= '0';
                data_wr <= x"00";
              when 1 =>
                enable <= '0';
                                        --rw<='1';
                if busy = '0' then
                  enable     <= '1';
                  rw         <= '1';
                  debeg_data <= X"0c";
                                        --we<='1';
                end if;

              when 2 =>

                if busy = '0' then
                  debeg_data             <= X"0c";
                                        --we<='1';
                  read_data(15 downto 8) <= data_rd;
                end if;

              when 3 =>
                enable <= '0';
                if busy = '0' then
                  debeg_data            <= X"03";
                                        --we<='1';
                  read_data(7 downto 0) <= data_rd;
                  busy_cnt := 0;
                  s_state  <= SEND_DATA;
                  lsb_byte <= '0';
                end if;
              when others =>
            end case;

          when SEND_DATA =>
            if lsb_byte = '0' then
              debeg_data <= read_data(15 downto 8);
              we         <= '1';
              lsb_byte   <= '1';
            else

              debeg_data <= read_data(7 downto 0);
              we         <= '1';
              s_state    <= END_S;
              count      <= 0;
            end if;
          when END_S =>
            if count <= 58000 then
              count    <= count + 1;
            else
              count <= 0;
              busy_cnt := 0;
              s_state <= CONV_TRY;
            end if;

        end case;
      end if;
    end if;
  end process;

end rtl;
