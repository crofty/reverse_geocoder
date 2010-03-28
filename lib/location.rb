class Location

  attr_accessor :lat, :lng

  def initialize(lat,lng)
    @lat = lat
    @lng = lng
  end

  def address(road_diff=0.0000000001, place_diff=0.01)
    [nearest_road(road_diff), nearest_place(place_diff)].compact.map{|x| x[:name]}.join(', ')
  end

  def nearest_road(diff=0.01)
    xmin = @lng - diff
    xmax = @lng + diff
    ymin = @lat - diff
    ymax = @lat + diff
    sql = <<-SQL
      SELECT wt.v AS name, ordered_nodes.distance
      FROM ways w,
           way_nodes wn,
           way_tags wt,
           (SELECT nearby_nodes.*, ST_Distance(nearby_nodes.geom, GeomFromText('POINT(#{@lng} #{@lat})', 4326)) AS distance
            FROM 
              (SELECT n.*
              FROM nodes n,
                   way_tags wt,
                   ways w,
                   way_nodes wn
              WHERE (w.bbox && SetSRID('BOX3D(#{xmin} #{ymin}, #{xmax} #{ymax}))'::box3d,4326))
              AND w.id = wn.way_id
              AND wn.node_id = n.id
              AND wt.way_id = w.id
              AND wt.k = 'highway') nearby_nodes
            ORDER BY distance ASC
           )  ordered_nodes
      WHERE w.id = wn.way_id
      AND wn.node_id = ordered_nodes.id
      AND wt.way_id = w.id
      AND wt.k IN ('name','ref')
      ORDER BY ordered_nodes.distance ASC, wt.k ASC
      LIMIT 1
    SQL
    DB[sql].first
  end

  def nearest_place(diff=0.01)
    xmin = @lng - diff
    xmax = @lng + diff
    ymin = @lat - diff
    ymax = @lat + diff
    sql = <<-SQL
      SELECT nt.v AS name
        FROM nodes n,
             node_tags nt
        WHERE (n.geom && SetSRID('BOX3D(#{xmin} #{ymin}, #{xmax} #{ymax})))'::box3d,4326))
        AND n.id = nt.node_id
        AND nt.k = 'is_in'
        ORDER BY ST_Distance(n.geom, GeomFromText('POINT(#{@lng} #{@lat})', 4326)) ASC
        LIMIT 1
      SQL
    DB[sql].first
  end
end


