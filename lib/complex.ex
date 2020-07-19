defmodule Complex do
  @moduledoc """
  Documentation for Complex.
  """

  defstruct [:real, :imaginary]

  @doc """
  Create a complex number from its cartesian coordinates.

  ## Examples

      iex> Complex.from_cartesian(2, 4) |> inspect()
      "2+j4"
  """
  def from_cartesian(real, imaginary) when is_number(real) and is_number(imaginary) do
    %__MODULE__{
      real: real,
      imaginary: imaginary
    }
  end

  @doc """
  Create a complex number from its polar coordinates.

  ## Examples

      iex> comp = Complex.from_polar(4, 1.3)
      ...> Complex.magnitude(comp)
      4.0
      iex> Complex.angle(comp)
      1.3
  """
  def from_polar(magnitude, angle) when is_number(magnitude) and magnitude >= 0 and is_number(angle) do
    from_cartesian(
      :math.cos(angle) * magnitude,
      :math.sin(angle) * magnitude
    )
  end

  @doc """
  Get the real part of a complex number.

  ## Examples

      iex> Complex.from_cartesian(3, 4) |> Complex.real()
      3
  """
  def real(%__MODULE__{real: real}) do
    real
  end

  @doc """
  Get the imaginary part of a complex number.

  ## Examples

      iex> Complex.from_cartesian(3, 4) |> Complex.imaginary()
      4
  """
  def imaginary(%__MODULE__{imaginary: imaginary}) do
    imaginary
  end

  @doc """
  Get the magnitude of a complex number.

  ## Examples

      iex> Complex.from_polar(5, 1.3) |> Complex.magnitude()
      5.0
  """
  def magnitude(%__MODULE__{real: r1, imaginary: j1}) do
    :math.sqrt((r1 * r1) + (j1 * j1))
  end

  @doc """
  Get the angle of a complex number, in radians.

  ## Examples

      iex> Complex.from_polar(5, 1.3) |> Complex.angle()
      1.3
  """
  def angle(%__MODULE__{real: r1, imaginary: j1}) do
    :math.atan(j1/r1)
  end

  @doc """
  Get the inverse of a complex number.

  ## Examples

      iex> Complex.from_cartesian(2, 2) |> Complex.invert() |> inspect()
      "0.25-j0.25"
  """
  def invert(%__MODULE__{} = comp) do
    divide(
      from_cartesian(1, 0),
      comp
    )
  end

  @doc """
  Get the conjugate of a complex number.

  ## Examples

      iex> Complex.from_cartesian(1, 1) |> Complex.conjugate() |> inspect()
      "1-j1"
  """
  def conjugate(%__MODULE__{real: r1, imaginary: j1}) do
    from_cartesian(r1, -j1)
  end

  @doc """
  Add two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(2, 2)
      ...> b = Complex.from_cartesian(3, 3)
      ...> Complex.add(a, b) |> inspect()
      "5+j5"
  """
  def add(%__MODULE__{real: r1, imaginary: j1}, %__MODULE__{real: r2, imaginary: j2}) do
    from_cartesian(r1 + r2, j1 + j2)
  end

  @doc """
  Subtract two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(3, 3)
      ...> b = Complex.from_cartesian(1, 1)
      ...> Complex.subtract(a, b) |> inspect()
      "2+j2"
  """
  def subtract(%__MODULE__{real: r1, imaginary: j1}, %__MODULE__{real: r2, imaginary: j2}) do
    from_cartesian(r1 - r2, j1 - j2)
  end

  @doc """
  Multiply two complex numbers.

  ## Examples

      iex> a = Complex.from_cartesian(2, 3)
      ...> b = Complex.from_cartesian(3, -6)
      ...> Complex.multiply(a, b) |> inspect()
      "24-j3"
  """
  def multiply(%__MODULE__{real: r1, imaginary: j1}, %__MODULE__{real: r2, imaginary: j2}) do
    real = r1 * r2 - (j1 * j2)
    imaginary = (r1 * j2) + (j1 * r2)
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
  def divide(numerator, denominator)

  def divide(%__MODULE__{real: r1, imaginary: j1}, %__MODULE__{real: r2, imaginary: 0}) do
    from_cartesian(r1/r2, j1/r2)
  end

  def divide(%__MODULE__{} = numerator, %__MODULE__{} = denominator) do
    divide(
      multiply(numerator, conjugate(denominator)),
      multiply(denominator, conjugate(denominator))
    )
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

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
  end
end
