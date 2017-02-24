library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity activate is
  port (
  da : in std_logic_vector(15 downto 0);
  do : out std_logic_vector(15 downto 0));
end activate;

architecture default of activate is
begin
  do <= da;
end default;
