library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add is
  port (
  da : in std_logic_vector(15 downto 0);
  db : in std_logic_vector(15 downto 0);
  do : out std_logic_vector(15 downto 0));
end add;

architecture default of add is
  signal a,b,c : unsigned(15 downto 0);
begin
  a <= unsigned(da);
  b <= unsigned(db);
  c <= a+b;
  do <= std_logic_vector(c);
end default;
