-- $Id$
-- File ID: 21f7f30e-fafb-11dd-8266-000475e441b9

CREATE TABLE logg (
    date timestamptz,
    coor point,
    ele numeric(6, 1),
    name text,
    dist numeric(8, 5),
    description text,
    id serial
);

CREATE TABLE wayp (
    coor point,
    name text,
    ele numeric(6, 1),
    type text,
    time timestamptz,
    cmt text, -- GPS waypoint comment. Sent to the GPS as comment.
    descr text, -- A text description. Additional info intended for the user, not the GPS.
    src text,
    sym text,
    numpoints integer,
    id integer
);

CREATE TABLE wayp_new (
    coor point,
    name text,
    ele numeric(6, 1),
    type text,
    time timestamptz,
    cmt text, -- GPS waypoint comment. Sent to the GPS as comment.
    descr text, -- A text description. Additional info intended for the user, not the GPS.
    src text,
    sym text,
    numpoints integer,
    id serial
);

CREATE TABLE wayp_rej (
    coor point,
    name text,
    ele numeric(6, 1),
    type text,
    time timestamptz,
    cmt text, -- GPS waypoint comment. Sent to the GPS as comment.
    descr text, -- A text description. Additional info intended for the user, not the GPS.
    src text,
    sym text,
    numpoints integer,
    id integer
);

CREATE TABLE tmpwayp AS
    SELECT * FROM wayp LIMIT 0;

CREATE TABLE events (
    date timestamptz,
    coor point,
    descr text,
    begindate timestamptz, -- Ganske eksakt tidspunt ved start
    enddate timestamptz, -- Ganske eksakt tidspunkt ved slutt
    cabegin interval,
    caend interval,
    flags text[],
    persons text[],
    data bytea
);

CREATE TABLE pictures (
    version smallint,
    date timestamptz,
    coor point,
    descr text,
    filename text,
    author text
);

CREATE TABLE film (
    version smallint,
    date timestamptz,
    coor point,
    descr text,
    filename text,
    author text
);

CREATE TABLE lyd (
    version smallint,
    date timestamptz,
    coor point,
    descr text,
    filename text,
    author text
);

CREATE TABLE stat (
    lastupdate timestamptz,
    lastname timestamptz
);