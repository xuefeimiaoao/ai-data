SELECT count(1) FROM test_view where height = 1170;
select count(1) from (
SELECT EXPLODE(objects) AS exploded_object
          FROM test_view ) t where t.exploded_object.shape.shape_type = "17c112a7fa";
select count(1) from (
SELECT EXPLODE(objects) AS exploded_object
          FROM test_view ) t where t.exploded_object.classification = "d6bdcb3634";
SELECT height FROM test_view where height = 1170;
select t.exploded_object.shape.shape_type from (
SELECT EXPLODE(objects) AS exploded_object
          FROM test_view ) t where t.exploded_object.shape.shape_type = "17c112a7fa";
select t.exploded_object.classification from (
SELECT EXPLODE(objects) AS exploded_object
          FROM test_view ) t where t.exploded_object.classification = "d6bdcb3634";
