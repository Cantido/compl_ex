defmodule ComplexPropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  def complex_cartesian() do
    map({integer(-100..100), integer(-100..100)}, fn {re, im} ->
      Complex.from_cartesian(re, im)
    end)
  end

  def complex_polar() do
    {float(min: 0, max: 100), float(min: -:math.pi(), max: :math.pi())}
    |> filter(fn {angle, mag} ->
      angle != 0 or mag != 0
    end)
    |> map(fn {angle, mag} ->
      Complex.from_polar(angle, mag)
    end)
  end

  def complex() do
    frequency([
      {1, complex_cartesian()},
      {1, complex_polar()}
    ])
  end

  def nonzero_complex() do
    complex()
    |> filter(fn z ->
      not (Complex.real(z) == 0 && Complex.imaginary(z) == 0)
    end)
  end

  def number() do
    frequency([
      {2, complex()},
      {1, float()}
    ])
  end

  def nonzero_number() do
    number()
    |> filter(&(&1 != 0))
    |> filter(fn z ->
      not (Complex.real(z) == 0 && Complex.imaginary(z) == 0)
    end)
  end

  property "we can get the real part of any number" do
    check all z1 <- number() do

      assert is_number(Complex.real(z1))
    end
  end

  property "we can get the imaginary part of any number" do
    check all z1 <- number() do

      assert is_number(Complex.imaginary(z1))
    end
  end

  property "we can get the magnitude of any number" do
    check all z1 <- number() do

      assert is_number(Complex.magnitude(z1))
    end
  end

  property "we can get the angle of any number" do
    check all z1 <- nonzero_number() do

      assert is_number(Complex.angle(z1))
    end
  end

  property "we can invert any nonzero number" do
    check all z1 <- nonzero_number() do

      Complex.invert(z1)
    end
  end

  property "conjugating any number flips the sign of its imaginary part" do
    check all z1 <- number() do

      conj = Complex.conjugate(z1)

      assert Complex.imaginary(conj) == -Complex.imaginary(z1)
    end
  end

  property "conjugating any number keeps the same real part" do
    check all z1 <- number() do

      conj = Complex.conjugate(z1)

      assert Complex.real(conj) == Complex.real(z1)
    end
  end

  property "adding two complex numbers adds their real parts" do
    check all z1 <- number(),
              z2 <- number() do
      sum = Complex.add(z1, z2)

      assert Complex.real(sum) == Complex.real(z1) + Complex.real(z2)
    end
  end

  property "adding two complex numbers adds their imaginary parts" do
    check all z1 <- number(),
              z2 <- number() do
      sum = Complex.add(z1, z2)

      assert Complex.imaginary(sum) == Complex.imaginary(z1) + Complex.imaginary(z2)
    end
  end

  property "multiplying two complex numbers results in another complex number with a real part" do
    check all z1 <- number(),
              z2 <- number() do
      product = Complex.multiply(z1, z2)

      assert is_number(Complex.real(product))
    end
  end

  property "multiplying two complex numbers results in another complex number with an imaginary part" do
    check all z1 <- number(),
              z2 <- number() do
      product = Complex.multiply(z1, z2)

      assert is_number(Complex.imaginary(product))
    end
  end

  property "multiplying a number by its conjugate results in a number with no imaginary part" do
    check all z1 <- number() do
      product = Complex.multiply(z1, Complex.conjugate(z1))

      assert Complex.imaginary(product) == 0
    end
  end

  property "dividing two complex numbers results in another complex number with a real part" do
    check all z1 <- number(),
              z2 <- nonzero_number() do
      quotient = Complex.divide(z1, z2)

      assert is_number(Complex.real(quotient))
    end
  end

  property "dividing two complex numbers results in another complex number with an imaginary part" do
    check all z1 <- number(),
              z2 <- nonzero_number() do
      quotient = Complex.divide(z1, z2)

      assert is_number(Complex.imaginary(quotient))
    end
  end

  property "finding the sine of a complex number results in another complex number" do
    check all z1 <- number() do
      result = Complex.sin(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the arcsine of a complex number results in another complex number" do
    check all z1 <- complex() do
      result = Complex.asin(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the cosine of a complex number results in another complex number" do
    check all z1 <- complex() do
      result = Complex.cos(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the arccosine of a complex number results in another complex number" do
    check all z1 <- complex() do
      result = Complex.acos(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the tangent of a complex number results in another complex number" do
    check all z1 <- complex() do
      result = Complex.tan(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the arctangent of a complex number results in another complex number" do
    check all z1 <- complex() do
      result = Complex.atan(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the cosecant of a complex number results in another complex number" do
    check all z1 <- nonzero_complex() do
      result = Complex.csc(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the arccosecant of a complex number results in another complex number" do
    check all z1 <- nonzero_complex() do
      result = Complex.acsc(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the secant of a complex number results in another complex number" do
    check all z1 <- complex() do
      result = Complex.sec(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the arcsecant of a complex number results in another complex number" do
    check all z1 <- nonzero_complex() do
      result = Complex.asec(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the cotangent of a complex number results in another complex number" do
    check all z1 <- nonzero_complex() do
      result = Complex.cot(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "finding the arccotangent of a complex number results in another complex number" do
    check all z1 <- nonzero_complex() do
      result = Complex.acot(z1)

      assert is_number(Complex.real(result))
      assert is_number(Complex.imaginary(result))
    end
  end

  property "inspecting a number in cartesian form contains its cartesian real value" do
    check all z1 <- complex_cartesian() do
      inspect_result = inspect(z1)
      expected_substring = inspect(Complex.real(z1))

      assert String.contains?(inspect_result, expected_substring)
    end
  end

  property "inspecting a number in cartesian form contains its cartesian imaginary value" do
    check all z1 <- complex_cartesian() do
      inspect_result = inspect(z1, custom_options: [complex: :cartesian])
      expected_substring = inspect(abs(Complex.imaginary(z1)))

      assert String.contains?(inspect_result, expected_substring)
    end
  end

  property "inspecting a number with a positive imaginary value prints it as a positive j" do
    check all z1 <- complex_cartesian() |> filter(&(Complex.imaginary(&1) >= 0))do
      inspect_result = inspect(z1, custom_options: [complex: :cartesian])
      expected_substring = "+j"

      assert String.contains?(inspect_result, expected_substring)
    end
  end

  property "inspecting a number with a negative imaginary value prints it as a negative j" do
    check all z1 <- complex_cartesian() |> filter(&(Complex.imaginary(&1) < 0))do
      inspect_result = inspect(z1, custom_options: [complex: :cartesian])
      expected_substring = "-j"

      assert String.contains?(inspect_result, expected_substring)
    end
  end

  property "inspecting a number in polar form contains its magnitude value" do
    check all z1 <- complex_cartesian() do
      inspect_result = inspect(z1, custom_options: [complex: :polar])
      expected_substring = inspect(Complex.magnitude(z1))

      assert String.contains?(inspect_result, expected_substring)
    end
  end

  property "inspecting a number in polar form contains its angular value" do
    check all z1 <- complex_cartesian() do
      inspect_result = inspect(z1, custom_options: [complex: :polar])
      expected_substring = inspect(Complex.angle(z1))

      assert String.contains?(inspect_result, expected_substring)
    end
  end

  property "inspecting a number in polar form with degrees contains its angular value in degrees" do
    check all z1 <- complex_cartesian() do
      inspect_result = inspect(z1, custom_options: [complex: :polar, angle: :degrees])
      expected_substring = inspect(Complex.angle(z1) * 180 / :math.pi) <> "°"

      assert String.contains?(inspect_result, expected_substring)
    end
  end
end
