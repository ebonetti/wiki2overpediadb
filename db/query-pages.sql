/*Define the query used for exporting informations for articles, topics and global*/
WITH topics AS (
    SELECT page_id AS topic_id
    FROM w2o.pages
    WHERE page_depth = 1
), percentiledindices AS (
    SELECT type, page_id, year, weight,
    percent_rank() OVER w AS percentile,
    (dense_rank() OVER w - 1.0)/GREATEST((dense_rank() OVER wd + dense_rank() OVER w - 2),1) AS dense_percentile,
    rank() OVER wd AS rank,
    (dense_rank() OVER tw - 1.0)/GREATEST((dense_rank() OVER twd + dense_rank() OVER tw - 2),1) AS topic_dense_percentile,
    percent_rank() OVER tw AS topic_percentile,
    rank() OVER twd AS topic_rank
    FROM w2o.indicesbyyear
    WINDOW w AS (PARTITION BY type, year, page_depth ORDER BY weight),
    wd AS (PARTITION BY type, year, page_depth ORDER BY weight DESC),
    tw AS (PARTITION BY type, year, page_depth, topic_id ORDER BY weight),
    twd AS (PARTITION BY type, year, page_depth, topic_id ORDER BY weight DESC)
), percentiledindicesagg AS (
    SELECT page_id, type,array_agg(CAST((weight, percentile, dense_percentile, rank, topic_percentile, topic_dense_percentile, topic_rank, year) AS w2o.yearmeasurement) ORDER BY year ASC) AS measurements
    FROM percentiledindices
    GROUP BY page_id, type
), percentiledindicesaggagg AS (
    SELECT page_id, array_agg(CAST((type, measurements) AS w2o.indextype2measurements) ORDER BY type ASC) AS stats
    FROM percentiledindicesagg
    GROUP BY page_id
) SELECT row_to_json(CAST((
    CAST((page_id, page_title, page_abstract, parent_id, page_depth, page_creationyear) AS w2o.page),
    COALESCE(stats,array[]::w2o.indextype2measurements[]),
    COALESCE(socialjumps,array[]::w2o.page[])
) AS w2o.pageinfo))
FROM w2o.pages p LEFT JOIN LATERAL (
    SELECT array_agg(CAST((page_id, page_title, page_abstract, parent_id, page_depth, page_creationyear) AS w2o.page) ORDER BY nr) AS socialjumps
    FROM unnest(p.page_socialjumps) WITH ORDINALITY _(page_id, nr) JOIN w2o.pages USING (page_id)
) _ ON TRUE
JOIN percentiledindicesaggagg USING (page_id)
ORDER BY p.page_depth,p.page_title;
