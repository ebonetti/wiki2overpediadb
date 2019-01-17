/*Free space since revisions table will not be anymore useful and indexes will take a lot of space*/
DROP TABLE w2o.revisions;

/*Define indexes over indicesbyyear*/
CREATE INDEX ON w2o.indicesbyyear (page_id);
/*Used by LATERAL JOIN in queries*/
CREATE INDEX ON w2o.indicesbyyear (weight DESC, year, topic_id, type, page_type);
ANALYZE w2o.indicesbyyear;


/*The following types are used by the pages and toptenbyyear queries*/

CREATE TYPE w2o.yearmeasurement AS (
    Value                 FLOAT,
    Percentile            FLOAT,
    DensePercentile       FLOAT,
    Rank                  INTEGER,
    TopicPercentile       FLOAT,
    TopicDensePercentile  FLOAT,
    TopicRank             INTEGER,
    Year                  INTEGER
);

CREATE TYPE w2o.indextype2measurements AS (
    IndexType             w2o.myindex,
    Measurements          w2o.yearmeasurement[]
);

CREATE TYPE w2o.page AS (
    ID                    INTEGER,
    Title                 VARCHAR(512),
    Abstract              TEXT,
    ParentID              INTEGER,
    PageType              w2o.mypagetype,
    CreationYear          INTEGER
);

CREATE TYPE w2o.pageinfo  AS (
    Page                  w2o.page,
    Stats                 w2o.indextype2measurements[],
    Links                 w2o.page[]
);

CREATE TYPE w2o.indexranking AS (
    Index                 w2o.myindex,
    Ranking               w2o.page[]
);

CREATE TYPE w2o.annualindexesranking AS (
    Year                  INTEGER,
    IndexesRanking        w2o.indexranking[]
);
