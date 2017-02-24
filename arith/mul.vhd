library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul is
  port (
  da : in std_logic_vector(15 downto 0);
  db : in std_logic_vector(15 downto 0);
  do : out std_logic_vector(15 downto 0));
end mul;

architecture default of mul is
  signal a,b,c : signed(15 downto 0);
begin
  a <= signed(da);
  b <= signed(db);
  c <= a+b;
  do <= std_logic_vector(c);
end default;

