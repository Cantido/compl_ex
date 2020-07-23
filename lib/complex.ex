defmodule Complex do
  import Inspect.Algebra

  @moduledoc """
  Create and manipulate complex numbers.

  To create complex numbers, you can use either cartesian coordinates or polar coordinates.
  This library is polymorphic based on the way a complex number is created,
  so that errors are not introduced in the conversion process.

      iex> comp = Complex.from_cartesian(2, 5)
      ...> Complex.real(comp)
      2
      iex> Complex.imaginary(comp)
      5

      iex> comp = Complex.from_polar(6, 1)
      ...> Complex.magnitude(comp)
      6
      iex> Complex.angle(comp)
      1

  You can do simple arithmetic on complex numbers with `add/2`, `subtract/2`, `multiply/2`, and `divide/2`.
  You can invert a complex number with `invert/1`,
  and find a number's conjugate with `conjugate/1`.

  All arithmetic functions in this library take regular Elixir numbers
  in place of complex numbers, so you don't have to wrap real numbers to include
  a zero imaginary part if you don't need to.

      iex> Complex.from_cartesian(3, 4) |> Complex.add(2) |> inspect()
      "5+j4"

  ## Inspecting numbers

  The `Inspect` protocol is implemented for these complex numbers, and you can pass in options to `inspect/2`
  to customize how they are displayed.
  The options are:

    - `:complex`: can either be `:cartesian` to print the number in *x+jy* form (the default), or `:polar` for *x∠y* form.
    - `:angle`: when printing a number in polar form, this can either be `:radians` (default) or `:degrees`.

  For example:

      iex> comp = Complex.from_cartesian(3, 4)
      ...> inspect comp, custom_options: [complex: :cartesian]
      "3+j4"

      iex> comp = Complex.from_polar(3, 1.3)
      ...> inspect comp, custom_options: [complex: :polar]
      "3∠1.3"

      iex> comp = Complex.from_polar(3, 1)
      ...> inspect comp, custom_options: [complex: :polar, angle: :degrees]
      "3∠57.29577951308232°"
  """

  @doc """
  Create a complex number from its cartesian coordinates.

  ## Examples

      iex> Complex.from_cartesian(2, 4) |> inspect()
      "2+j4"
  """
  def from_cartesian(real, imaginary)

  def from_cartesian(real, imaginary) when is_number(real) and is_number(imaginary) do
    %Complex.Cartesian{
      re: real,
      im: imaginary
    }
  end

  def from_cartesian(real, imaginary) when is_number(real) and imaginary == 0 do
    real
  end

  @doc """
  Create a complex number from its polar coordinates.

  ## Examples

      iex> comp = Complex.from_polar(4, 1.3)
      ...> Complex.magnitude(comp)
      4
      iex> Complex.angle(comp)
      1.3
  """
  def from_polar(magnitude, angle)

  def from_polar(magnitude, angle) when is_number(magnitude) and magnitude >= 0 and is_number(angle) do
    %Complex.Polar{
      magnitude: magnitude,
      angle: angle
    }
  end

  def from_polar(magnitude, angle) when is_number(magnitude) and angle == 0 do
    magnitude
  end

  @doc """
  Get the real part of a complex number.

  ## Examples

      iex> Complex.from_cartesian(3, 4) |> Complex.real()
      3
  """
  def real(z)

  def real(%Complex.Cartesian{re: real}) do
    real
  end

  def real(%Complex.Polar{magnitude: magnitude, angle: angle}) do
    :math.cos(angle) * magnitude
  end

  def real(z) when is_number(z) do
    z
  end

  @doc """
  Get the imaginary part of a complex number.

  ## Examples

      iex> Complex.from_cartesian(3, 4) |> Complex.imaginary()
      4
  """
  def imaginary(z)

  def imaginary(%Complex.Cartesian{im: imaginary}) do
    imaginary
  end

  def imaginary(%Complex.Polar{angle: angle, magnitude: magnitude}) do
    :math.sin(angle) * magnitude
  end

  def imaginary(z) when is_number(z) do
    0
  end

  @doc """
  Get the magnitude of a complex number.

  ## Examples

      iex> Complex.from_polar(5, 1.3) |> Complex.magnitude()
      5
  """
  def magnitude(z)

  def magnitude(%Complex.Cartesian{re: r1, im: j1}) do
    :math.sqrt((r1 * r1) + (j1 * j1))
  end

  def magnitude(%Complex.Polar{magnitude: mag}) do
    mag
  end

  def magnitude(z) when is_number(z) do
    z
  end

  @doc """
  Get the angle of a complex number, in radians.

  ## Examples

      iex> Complex.from_polar(5, 1.3) |> Complex.angle()
      1.3
  """
  def angle(z)

  def angle(%Complex.Cartesian{re: r1, im: j1}) when r1 > 0 do
    :math.atan(j1 / r1)
  end

  def angle(%Complex.Cartesian{re: r1, im: j1}) when r1 < 0 and j1 >= 0 do
    :math.atan(j1 / r1) + :math.pi()
  end

  def angle(%Complex.Cartesian{re: r1, im: j1}) when r1 < 0 and j1 < 0 do
    :math.atan(j1 / r1) - :math.pi()
  end

  def angle(%Complex.Cartesian{re: r1, im: j1}) when r1 == 0 or j1 > 0 do
    :math.pi() / 2
  end

  def angle(%Complex.Cartesian{re: r1, im: j1}) when r1 == 0 or j1 < 0 do
    -:math.pi() / 2
  end

  # This leaves when r1 == 0 and j1 == 0, which is undefined.
  # I will leave it as a match error.

  def angle(%Complex.Polar{angle: angle}) do
    angle
  end

  def angle(z) when is_number(z) and z != 0 do
    0
  end

  @doc """
  Get the inverse of a complex number.

  ## Examples

      iex> Complex.from_cartesian(2, 2) |> Complex.invert() |> inspect()
      "0.25-j0.25"
  """
  def invert(z)

  def invert(comp) do
    divide(1, comp)
  end

  def invert(z) when is_number(z) and z != 0 do
    1 / z
  end

  @doc """
  Get the conjugate of a complex number.

  ## Examples

      iex> Complex.from_cartesian(1, 1) |> Complex.conjugate() |> inspect()
      "1-j1"
  """
  def conjugate(z)

  def conjugate(%Complex.Cartesian{re: r1, im: j1}) do
    from_cartesian(r1, -j1)
  end

  def conjugate(%Complex.Polar{} = comp) do
    from_cartesian(
      real(comp),
      -imaginary(comp)
    )
  end

  def conjugate(z) when is_number(z) do
    z
  end

  @doc """
  Add two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(2, 2)
      ...> b = Complex.from_cartesian(3, 3)
      ...> Complex.add(a, b) |> inspect()
      "5+j5"
  """
  def add(z1, z2)

  def add(z1, z2) do
    from_cartesian(
      real(z1) + real(z2),
      imaginary(z1) + imaginary(z2)
    )
  end

  @doc """
  Subtract two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(3, 3)
      ...> b = Complex.from_cartesian(1, 1)
      ...> Complex.subtract(a, b) |> inspect()
      "2+j2"
  """
  def subtract(z1, z2)

  def subtract(z1, z2) do
    from_cartesian(
      real(z1) - real(z2),
      imaginary(z1) - imaginary(z2)
    )
  end

  @doc """
  Multiply two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(2, 3)
      ...> b = Complex.from_cartesian(3, -6)
      ...> Complex.multiply(a, b) |> inspect()
      "24-j3"
  """
  def multiply(z1, z2)

  def multiply(z1, z2) do
    real = (real(z1) * real(z2)) - (imaginary(z1) * imaginary(z2))
    imaginary = (real(z1) * imaginary(z2)) + (imaginary(z1) * real(z2))
    from_cartesian(real, imaginary)
  end

  @doc """
  Divide two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(2, 3)
      ...> b = Complex.from_cartesian(3, 6)
      ...> Complex.divide(a, b) |> inspect()
      "0.5333333333333333-j0.06666666666666667"
  """
  def divide(z1, z2)

  def divide(numerator, denominator) do
    simp_num = multiply(numerator, conjugate(denominator))
    simp_denom = multiply(denominator, conjugate(denominator))

    if imaginary(simp_denom) != 0 do
      raise "multiplying a number by its conjugate resulted in a number that still has an imaginary part; something is wrong."
    end

    from_cartesian(
      real(simp_num) / real(simp_denom),
      imaginary(simp_num) / real(simp_denom)
    )
  end

  @doc false
  def inspect(comp, opts) do
    case Keyword.get(opts.custom_options, :complex, :cartesian) do
      :cartesian -> inspect_cartesian(comp, opts)
      :polar -> inspect_polar(comp, opts)
    end
  end

  defp inspect_cartesian(comp, opts) do
    sign = if Complex.imaginary(comp) < 0 do
      "-"
    else
      "+"
    end

    concat([
      to_doc(Complex.real(comp), opts),
      sign,
      "j",
      to_doc(Complex.imaginary(comp) |> abs(), opts)
    ])
  end

  defp inspect_polar(comp, opts) do
    angle = case Keyword.get(opts.custom_options, :angle, :radians) do
      :radians -> to_doc(Complex.angle(comp), opts)
      :degrees -> concat([to_doc(Complex.angle(comp) * 180 / :math.pi, opts), "°"])
    end

    concat([
      to_doc(Complex.magnitude(comp), opts),
      "∠",
      angle
    ])
  end

  defimpl Inspect, for: Complex.Cartesian do
    def inspect(comp, opts) do
      Complex.inspect(comp, opts)
    end
  end

  defimpl Inspect, for: Complex.Polar do
    def inspect(comp, opts) do
      Complex.inspect(comp, opts)
    end
  end
end
