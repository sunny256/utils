-- $Id$

SELECT count(*)
    AS "Antall i wayp før rensking"
    FROM wayp;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (lat,lon,name) *
            FROM wayp
    );
    TRUNCATE wayp;
    INSERT INTO wayp (
        SELECT *
            FROM dupfri
            ORDER BY name
    );
COMMIT;

SELECT count(*)
    AS "Antall i wayp etter rensking"
    FROM wayp;

SELECT count(*)
    AS "Antall i events før rensking"
    FROM events;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (date,lat,lon,descr) *
            FROM events
    );
    TRUNCATE events;
    INSERT INTO events (
        SELECT *
            FROM dupfri
            ORDER BY date
    );
COMMIT;

SELECT count(*)
    AS "Antall i events etter rensking"
    FROM events;
