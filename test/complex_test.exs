defmodule ComplexTest do
  use ExUnit.Case
  doctest Complex

  describe "inspecting a complex number" do
    test "in cartesian form" do
      comp = Complex.from_cartesian(3, 4)

      str = inspect comp, custom_options: [complex: :cartesian]

      assert str == "3+j4"
    end

    test "in cartesian form, negative imaginary part" do
      comp = Complex.from_cartesian(3, -4)

      str = inspect comp, custom_options: [complex: :cartesian]

      assert str == "3-j4"
    end

    test "in polar form" do
      comp = Complex.from_polar(3, 1.3)

      str = inspect comp, custom_options: [complex: :polar]

      assert str == "3.0∠1.3"
    end

    test "in polar form as degrees" do
      comp = Complex.from_polar(3, 1)

      str = inspect comp, custom_options: [complex: :polar, angle: :degrees]

      assert str == "3.0∠57.295779513082316°"
    end
  end
end
