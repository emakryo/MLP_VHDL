library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_half is
  generic (
  DATA_WIDTH : integer := 14);
  port (
  di : in std_logic_vector(DATA_WIDTH-1 downto 0);
  do : out std_logic_vector(15 downto 0));
end conv_half;

architecture default of conv_half is
  signal tmp : std_logic_vector(15 downto DATA_WIDTH);
begin
  do <= tmp & di;
end default;
