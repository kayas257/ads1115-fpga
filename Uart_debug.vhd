--Author Kayas Ahmed



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Uart_debug is
 generic (
    BAUD_RATE : integer := 9600; 
    SYSTEM_CLK_PERIOD_NS:integer :=20	    -- Needs to be set correctly
    );
port 
(
clk 		: in std_logic;
rst		:in std_LOGIC;
uart_in 	: in std_logic_vector(7 downto 0);
we			: in std_logic;
txd 		: out std_logic
);

end Uart_debug;

architecture rtl of Uart_debug is

--component fifo IS
--	PORT
--	(
--		clock		: IN STD_LOGIC ;
--		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		rdreq		: IN STD_LOGIC ;
--		wrreq		: IN STD_LOGIC ;
--		empty		: OUT STD_LOGIC ;
--		full		: OUT STD_LOGIC ;
--		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
--		usedw		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
--	);
--END component;


component fifo IS
	PORT
(
		clk		: IN STD_LOGIC ;
		data_in		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		re		: IN STD_LOGIC ;
		we		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		data_out			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
--		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
END component;



component uart_tx is
  generic (
    cycles_per_bit : natural := 434);
  port (
   clk : in std_logic;

   -- Serial output bit
   tx : out std_logic := '1';

   -- AXI stream for input bytes
   tready : out std_logic := '0';
   tvalid : in std_Logic;
   tdata : in std_logic_vector(7 downto 0));
END component;	




constant cycles_per_bit : integer := SYSTEM_CLK_PERIOD_NS * 10**6 / BAUD_RATE;

signal  rdreq_s : std_logic;
signal data_out:std_logic_vector(7 downto 0);
signal s_tvalid :std_LOGIC;
signal s_empty :std_LOGIC;
signal count : std_LOGIC_VECTOR(7 downto 0) ;
signal s_tready : std_LOGIC;

begin
fifo_module:fifo
port map(

clk     => 	clk,
data_in	  =>	uart_in,
re     =>	rdreq_s,
we     =>	we,
empty	  =>    s_empty,
full      => 	open,
data_out	  =>	data_out
);
--fifo_module:fifo
--port map(
--
--clock     => 	clk,
--data	  =>	uart_in,
--rdreq     =>	rdreq_s,
--wrreq     =>	we,
--empty	  =>    s_empty,
--full      => 	open,
--q	  =>	data_out,
--usedw => open
--);

transmit_modulw:uart_tx
generic map (cycles_per_bit)
port map(

clk		=>	clk,
tdata		=> data_out,
tready	=>	rdreq_s,
tvalid   => s_tvalid,
tx			=>	txd
);

 
s_tvalid<= not s_empty;


end rtl;





