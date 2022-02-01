defmodule Guilda.Geo do
  @doc """
  Returns a random lat/lng coordinate within the given radius
  of a location.

  Adapted from https://gis.stackexchange.com/questions/25877/generating-random-locations-nearby

  ## Example

      iex> random_nearby_lng_lat(39.74, -104.99, 3)
      {39.7494, -105.0014}
  """
  def random_nearby_lng_lat(lng, lat, radiusKm, precision \\ 3) do
    radius_rad = radiusKm / 111.3

    u = :rand.uniform()
    v = :rand.uniform()

    w = radius_rad * :math.sqrt(u)
    t = 2 * :math.pi() * v

    x = w * :math.cos(t)
    y1 = w * :math.sin(t)

    # Adjust the x-coordinate for the shrinking
    # of the east-west distances
    lat_rads = lat / (180 / :math.pi())
    x1 = x / :math.cos(lat_rads)

    new_lng = Float.round(lng + x1, precision)
    new_lat = Float.round(lat + y1, precision)

    {new_lng, new_lat}
  end
end
