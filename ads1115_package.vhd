--Author Kayas Ahmed

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package ads1115_package is

	type config_reg is record
		os       : std_LOGIC;
		pin_mux  : std_logic_vector(2 downto 0);
		pga      : std_logic_vector(2 downto 0);
		mode     : std_LOGIC;
		dr       : std_logic_vector(2 downto 0);
		cmp_mode : std_logic;
		cmp_pol  : std_LOGIC;
		cmp_lat  : std_logic;
		cmp_que  : std_logic_vector(1 downto 0);
	end record;

	function config_to_std_vector (
		config : in config_reg
	) return std_logic_vector;

	--function std_vector_to_config (
	--    config_vector  : in std_logic_vector
	--    )
	--    return config_reg is
	--	variable config : config_reg;
	--  begin
	--	config.os<=config_vector(15);
	--	config.pin_mux<=config_vector(14 downto 12);
	--	config.pga<=config_vector(11 downto 9);
	--	config.mode<=config_vector(8);
	--	config.dr<=config_vector(7 downto 5);
	--	config.cmp_mode<=config_vector(4);
	--	config.cmp_pol<=config_vector(3);
	--	config.cmp_lat<=config_vector(2);
	--	config.cmp_que<=config_vector(1 downto 0);
	--    return (config);
	--  end function std_vector_to__config;
end package ads1115_package;

package body ads1115_package is

	function config_to_std_vector (
		config : in config_reg)
		return std_logic_vector is
		--variable temp:std_logic_vector;
	begin
		--temp:=config.os&config.pin_mux&config.pga&config.mode&config.dr&config.cmp_mode&config.cmp_pol&config.cmp_lat&config.cmp_que;
		return std_logic_vector(config.os & config.pin_mux & config.pga & config.mode & config.dr & config.cmp_mode & config.cmp_pol & config.cmp_lat & config.cmp_que);
	end function config_to_std_vector;

end package body ads1115_package;