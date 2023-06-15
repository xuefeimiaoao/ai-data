SELECT count(1) FROM {} where height = 1170;
select count(1) from (
SELECT EXPLODE(objects) AS exploded_object
          FROM {} ) t where t.exploded_object.shape.shape_type = "17c112a7fa";
select count(1) from (
SELECT EXPLODE(objects) AS exploded_object
          FROM {} ) t where t.exploded_object.classification = "d6bdcb3634";
SELECT height FROM {} where height = 1170;
select t.exploded_object.shape.shape_type from (
SELECT EXPLODE(objects) AS exploded_object
          FROM {} ) t where t.exploded_object.shape.shape_type = "17c112a7fa";
select t.exploded_object.classification from (
SELECT EXPLODE(objects) AS exploded_object
          FROM {} ) t where t.exploded_object.classification = "d6bdcb3634";
select count(1) as agg_query from {} group by format,version;
SELECT avg(bit_depth),avg(size),avg(width),avg(height) as ordered_avg
  from {}
  where format in ('JPG', 'JPEG', 'PNG', 'cdr', 'pcd', 'dxf', 'ufo', 'eps', 'ai', 'raw', 'WMF')
  group by format,version
  order by version;
SELECT count(1) as cnt
  from {}
  group by format,version
  having count(*) >= 50
  order by cnt,version;
