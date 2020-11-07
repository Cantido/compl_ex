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

  ## Simple creation and manipulation functions

  - `from_cartesian/2`
  - `from_polar/2`
  - `from_polar_degrees/2`
  - `real/1`
  - `imaginary/1`
  - `magnitude/1`
  - `angle/1`
  - `angle_degrees/1`

  ## Arithmetic functions

  - `add/2`
  - `subtract/2`
  - `multiply/2`
  - `divide/2`
  - `invert/1`
  - `conjugate/1`

  All arithmetic functions in this library take real numbers in place of complex numbers,
  so you don't have to wrap real numbers to include a zero imaginary part if you don't need to.
  This preserves a lot of accuracy if you're dealing with a mix of complex and real numbers.

      iex> Complex.from_cartesian(3, 4) |> Complex.add(2) |> inspect()
      "5+j4"

  ## Trigonometric functions

  - `sin/1`
  - `cos/1`
  - `tan/1`
  - `csc/1`
  - `sec/1`
  - `cot/1`

  ## Inverse trigonometric functions

  - `asin/1`
  - `acos/1`
  - `atan/1`
  - `acsc/1`
  - `asec/1`
  - `acot/1`

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
  Create a complex number from its polar coordinates, with the given angle in degrees.

  Note that errors will be introduced by the internal conversion to radians.

  ## Examples

      iex> comp = Complex.from_polar_degrees(120, 60)
      ...> Complex.magnitude(comp)
      120
      iex> Complex.angle_degrees(comp)
      59.99999999999999
  """
  def from_polar_degrees(magnitude, angle) when is_number(magnitude) and magnitude >= 0 and is_number(angle) do
    %Complex.Polar{
      magnitude: magnitude,
      angle: (angle * :math.pi() / 180)
    }
  end

  @doc """
  Get the imaginary number *i*.
  """
  def i do
    from_cartesian(0, 1)
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

  def angle(%Complex.Cartesian{re: r1, im: j1}) do
    :math.atan2(j1, r1)
  end

  def angle(%Complex.Polar{angle: angle}) do
    angle
  end

  def angle(z) when is_number(z) and z != 0 do
    0
  end

  @doc """
  Get the angle of a complex number, in degrees.

  ## Examples

      iex> Complex.from_polar(5, 1) |> Complex.angle_degrees()
      57.29577951308232
  """
  def angle_degrees(z) do
    Complex.angle(z) * 180 / :math.pi()
  end

  @doc """
  Get the inverse of a complex number.

  ## Examples

      iex> Complex.from_cartesian(2, 2) |> Complex.invert() |> inspect()
      "0.25-j0.25"
  """
  def invert(z)

  def invert(z) when is_number(z) and z != 0 do
    1 / z
  end

  def invert(comp) do
    divide(1, comp)
  end

  @doc """
  Negate a complex number.

  ## Examples

      iex> Complex.from_cartesian(2, 2) |> Complex.negate() |> inspect()
      "-2-j2"
  """
  def negate(z) do
    from_cartesian(
      -real(z),
      -imaginary(z)
    )
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
  Find the square root of a complex number.

  ## Example

      iex> Complex.from_polar(2, :math.pi()) |> Complex.sqrt() |> inspect()
      "8.659560562354934e-17+j1.4142135623730951"
  """
  def sqrt(z)

  def sqrt(%Complex.Polar{magnitude: mag, angle: angle}) do
    from_polar(
      :math.sqrt(mag),
      angle/2
    )
  end

  def sqrt(%Complex.Cartesian{re: re, im: im} = z) do
    result_re = :math.sqrt((magnitude(z) + re) / 2)
    result_im = :math.sqrt((magnitude(z) - re) / 2)

    if im >= 0 do
      from_cartesian(
        result_re,
        result_im
      )
    else
      from_cartesian(
        result_re,
        -result_im
      )
    end
  end

  def sqrt(z) when is_number(z) do
    :math.sqrt(z)
  end

  @doc """
  Find the value of a complex number raised to the value of *e*.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.exp() |> inspect()
      "0.1353352832366127+j3.3147584285483636e-17"
  """
  def exp(z)

  def exp(z) when is_number(z) do
    :math.exp(z)
  end

  def exp(z) do
    exp = :math.exp(real(z))
    im = imaginary(z)
    from_cartesian(
      exp * :math.cos(im),
      exp * :math.sin(im)
    )
  end

  @doc """
  Find the natural log of a complex number.

  The natural log of a complex number is multivalued.
  This function finds the principal value.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.ln() |> inspect()
      "0.6931471805599453+j3.141592653589793"
  """
  def ln(z)

  def ln(z) when is_number(z) do
    :math.log(z)
  end

  def ln(z) do
    from_cartesian(
      :math.log(magnitude(z)),
      :math.atan2(imaginary(z), real(z))
    )
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

  def add(z1, z2) when is_number(z1) and is_number(z2) do
    z1 + z2
  end

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

  def subtract(z1, z2) when is_number(z1) and is_number(z2) do
    z1 - z2
  end

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

  def multiply(z1, z2) when is_number(z1) and is_number(z2) do
    z1 * z2
  end

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

  def divide(z1, z2) when is_number(z1) and is_number(z2) do
    z1 / z2
  end

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

  @doc """
  Find the value of a complex number raised to the power of another complex value.

  Complex exponents are multivalued.
  This function finds the principal value.

  ## Examples

      iex> a = Complex.from_cartesian(2, 3)
      ...> Complex.pow(a, 2) |> inspect()
      "-5.0+j12.0"

      iex> Complex.pow(2, 3)
      8.0
  """
  def pow(z, w)

  def pow(z, w) when is_number(z) and is_number(w) do
    :math.pow(z, w)
  end

  def pow(z, w) do
    exp(multiply(w, ln(z)))
  end


  @doc """
  Find the sine of a complex number.

  ## Example

      iex> Complex.from_polar(2, :math.pi()) |> Complex.sin() |> inspect()
      "-0.9092974268256817-j1.0192657827055095e-16"
  """
  def sin(z)

  def sin(z) when is_number(z) do
    :math.sin(z)
  end

  def sin(z) do
    re = real(z)
    im = imaginary(z)

    from_cartesian(
      :math.sin(re) * :math.cosh(im),
      :math.cos(re) * :math.sinh(im)
    )
  end

  @doc """
  Find the arcsine (inverse sine) if a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.asin() |> inspect()
      "-1.5707963267948974+j1.3169578969248164"
  """
  def asin(z)

  def asin(z) when is_number(z) do
    :math.asin(z)
  end

  def asin(z) do
    ln_t1 = multiply(i(), z)
    ln_t2 = sqrt(subtract(1, multiply(z, z)))
    multiply(negate(i()), ln(add(ln_t1, ln_t2)))
  end

  @doc """
  Find the cosine of a complex number.

  ## Example

      iex> Complex.from_polar(2, :math.pi()) |> Complex.cos() |> inspect()
      "-0.4161468365471424+j2.2271363664699914e-16"
  """

  def cos(z)

  def cos(z) when is_number(z) do
    :math.cos(z)
  end

  def cos(z) do
    re = real(z)
    im = imaginary(z)

    from_cartesian(
      :math.cos(re) * :math.cosh(im),
      -:math.sin(re) * :math.sinh(im)
    )
  end

  @doc """
  Find the arccosine (inverse cosine) of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.acos() |> inspect()
      "3.141592653589794-j1.3169578969248164"
  """
  def acos(z)

  def acos(z) when is_number(z) do
    :math.acos(z)
  end

  def acos(z) do
    subtract(:math.pi() / 2, asin(z))
  end

  @doc """
  Find the tangent of a complex number.

  ## Example

      iex> Complex.from_polar(2, :math.pi()) |> Complex.tan() |> inspect()
      "2.185039863261519+j1.4143199004457915e-15"
  """
  def tan(z)

  def tan(z) when is_number(z) do
    :math.tan(z)
  end

  def tan(z) do
    divide(
      sin(z),
      cos(z)
    )
  end

  @doc """
  Find the arctangent (inverse tangent) of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.atan() |> inspect()
      "-1.1071487177940904+j0.0"
  """
  def atan(z)

  def atan(z) when is_number(z) do
    :math.atan(z)
  end

  def atan(z) do
    multiply(
      divide(i(), 2),
      subtract(
        ln(subtract(1, multiply(i(), z))),
        ln(add(1, multiply(i(), z)))
      )
    )
  end

  @doc """
  Find the cosecant of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.csc() |> inspect()
      "-1.0997501702946164+j1.2327514463765779e-16"
  """
  def csc(z) do
    divide(1, sin(z))
  end

  @doc """
  Find the arccosecant (inverse cosecant) of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.acsc() |> inspect()
      "-0.5235987755982988+j0.0"
  """
  def acsc(z) do
    asin(divide(1, z))
  end

  @doc """
  Find the secant of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.sec() |> inspect()
      "-2.402997961722381-j1.2860374461837126e-15"
  """
  def sec(z) do
    divide(1, cos(z))
  end

  @doc """
  Find the arcsecant (inverse secant) of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.asec() |> inspect()
      "2.0943951023931953+j0.0"
  """
  def asec(z) do
    acos(divide(1, z))
  end

  @doc """
  Find the cotantent of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.cot() |> inspect()
      "0.45765755436028577-j2.962299212953233e-16"
  """
  def cot(z) do
    divide(cos(z), sin(z))
  end

  @doc """
  Find the arccotangent (inverse cotangent) of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.acot() |> inspect()
      "-0.46364760900080615-j9.71445146547012e-17"
  """
  def acot(z) do
    atan(divide(1, z))
  end

  @doc """
  Find the hyperbolic sine of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.sinh() |> inspect()
      "-3.6268604078470186+j9.214721821703068e-16"
  """
  def sinh(z)

  def sinh(z) when is_number(z) do
    :math.sinh(z)
  end

  def sinh(z) do
    multiply(
      negate(i()),
      sin(multiply(i(), z))
    )
  end

  @doc """
  Find the hyperbolic cosine of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.cosh() |> inspect()
      "3.7621956910836314-j8.88324597884823e-16"
  """
  def cosh(z)

  def cosh(z) when is_number(z) do
    :math.cosh(z)
  end

  def cosh(z) do
    cos(multiply(i(), z))
  end

  @doc """
  Find the hyperbolic tangent of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.tanh() |> inspect()
      "-0.9640275800758168+j1.730446130270963e-17"
  """
  def tanh(z)

  def tanh(z) when is_number(z) do
    :math.tanh(z)
  end

  def tanh(z) do
    multiply(
      negate(i()),
      tan(multiply(i(), z))
    )
  end

  @doc """
  Find the hyperbolic cosecant of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.csch() |> inspect()
      "-0.27572056477178325-j7.005200143346713e-17"
  """
  def csch(z) do
    multiply(
      i(),
      csc(multiply(i(), z))
    )
  end

  @doc """
  Find the hyperbolic secant of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.sech() |> inspect()
      "0.26580222883407967+j6.276086557791839e-17"
  """
  def sech(z) do
    sec(multiply(i(), z))
  end

  @doc """
  Find the hyperbolic cotangent of a complex number.

  ## Examples

      iex> Complex.from_polar(2, :math.pi()) |> Complex.coth() |> inspect()
      "-1.0373147207275482-j1.8619978115303712e-17"
  """
  def coth(z) do
    multiply(
      i(),
      cot(multiply(i(), z))
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
      :degrees -> concat([to_doc(Complex.angle_degrees(comp), opts), "°"])
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
