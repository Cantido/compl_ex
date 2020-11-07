defmodule Complex.InspectTest do
  use ExUnit.Case

  test "cartesian form" do
    assert inspect(Complex.from_cartesian(2, 3)) == "2+j3"
  end

  test "cartesian form with a negative imaginary part" do
    assert inspect(Complex.from_cartesian(2, -3)) == "2-j3"
  end

  test "polar form" do
    str = inspect(Complex.from_polar(2, 3), custom_options: [complex: :polar])
    assert str == "2∠3"
  end
end
