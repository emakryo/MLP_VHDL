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
  signal a,b : unsigned(15 downto 0);
  signal c : unsigned(31 downto 0);
begin
  a <= unsigned(da);
  b <= unsigned(db);
  c <= a*b;
  do <= std_logic_vector(c(15 downto 0));
end default;

