class Location

  attr_accessor :lat, :lng

  def initialize(lat,lng)
    @lat = lat
    @lng = lng
  end

  def address
    nearest_roads.first.name
  end

  def nearest_roads(diff=0.01)
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
      LIMIT 10
    SQL
    DB[sql].all
  end
end


