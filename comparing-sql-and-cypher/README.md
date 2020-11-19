# SQL vs Cypher

https://neo4j.com/graphgist/cypher-vs-sql

Docker compose will spin up mariaDB and Neo4j. MariaDB will be populated with a default database and data via the init.sql script.

Neo4j UI is available on `http://localhost:7474/`. Default username and password - `neo4j/neo4j`.

 Neo4j doesn't necessary need a schema up front. Populate data by:
 
 ```
CREATE (TheMatrix:Movie {title:'The Matrix', released:1999, tagline:'Welcome to the Real World'})
CREATE (Keanu:Person    {name:'Keanu Reeves',       born:1964})
CREATE (Carrie:Person   {name:'Carrie-Anne Moss',   born:1967})
CREATE (Laurence:Person {name:'Laurence Fishburne', born:1961})
CREATE (Hugo:Person     {name:'Hugo Weaving',       born:1960})
CREATE (AndyW:Person    {name:'Andy Wachowski',     born:1967})
CREATE (LanaW:Person    {name:'Lana Wachowski',     born:1965})
CREATE (JoelS:Person    {name:'Joel Silver',        born:1952})
CREATE
  (Keanu)    -[:ACTED_IN {roles:['Neo']}]->         (TheMatrix),
  (Carrie)   -[:ACTED_IN {roles:['Trinity']}]->     (TheMatrix),
  (Laurence) -[:ACTED_IN {roles:['Morpheus']}]->    (TheMatrix),
  (Hugo)     -[:ACTED_IN {roles:['Agent Smith']}]-> (TheMatrix),
  (AndyW)    -[:DIRECTED]->    (TheMatrix),
  (LanaW)    -[:DIRECTED]->    (TheMatrix),
  (JoelS)    -[:PRODUCED]->    (TheMatrix)
CREATE (TheDevilsAdvocate:Movie {title:"The Devil's Advocate", released:1997, tagline: 'Evil has its winning ways'})
CREATE (Monster:Movie {title: 'Monster', released: 2003, tagline: 'The first female serial killer of America'})
CREATE (Charlize:Person {name:'Charlize Theron', born:1975})
CREATE (Al:Person       {name:'Al Pacino',       born:1940})
CREATE (Taylor:Person   {name:'Taylor Hackford', born:1944})
CREATE
  (Keanu)    -[:ACTED_IN {roles:['Kevin Lomax']}]->    (TheDevilsAdvocate),
  (Charlize) -[:ACTED_IN {roles:['Mary Ann Lomax']}]-> (TheDevilsAdvocate),
  (Al)       -[:ACTED_IN {roles:['John Milton']}]->    (TheDevilsAdvocate),
  (Taylor)   -[:DIRECTED]->                            (TheDevilsAdvocate),
  (Charlize) -[:ACTED_IN {roles:['Aileen']}]->         (Monster),
  (Charlize) -[:PRODUCED {roles:['Aileen']}]->         (Monster)
```

## Simple read of data

Let’s find all entries in the movie table and output their title attribute in our RDBMS:

```
SELECT movie.title
FROM movie;
```
Using Neo4j, find all nodes labeled Movie and output their title property:
```
MATCH (movie:Movie)
RETURN movie.title;
```

MATCH tells Neo4j to match a pattern in the graph. In this case the pattern is very simple: any node with a Movie label on it. We bind the result of the pattern matching to the identifier movie, for use in the RETURN clause. And as you can see, the RETURN keyword of Cypher is similar to SELECT in SQL.

Now let’s get movies released after 1998.

```
SELECT movie.title
FROM movie
WHERE movie.released > 1998;
```
In this case the addition actually looks identical in Cypher.
```
MATCH (movie:Movie)
WHERE movie.released > 1998
RETURN movie.title;
```

## Join

Let’s list all persons and the movies they acted in.

```
SELECT person.name, movie.title
FROM person
  JOIN acted_in AS acted_in ON acted_in.person_id = person.id
  JOIN movie ON acted_in.movie_id = movie.id;
```
The same using Cypher:

```
MATCH (person:Person)-[:ACTED_IN]->(movie:Movie)
RETURN person.name, movie.title;
```

To make things slightly more complex, let’s search for the co-actors of Keanu Reeves. In SQL we use a self join on the person table and join on the acted_in table once for Keanu, and once for the co-actors.
```
SELECT DISTINCT co_actor.name
FROM person AS keanu
  JOIN acted_in AS acted_in1 ON acted_in1.person_id = keanu.id
  JOIN acted_in AS acted_in2 ON acted_in2.movie_id = acted_in1.movie_id
  JOIN person AS co_actor
    ON acted_in2.person_id = co_actor.id AND co_actor.id <> keanu.id
WHERE keanu.name = 'Keanu Reeves';
```

In Cypher, we use a pattern with two paths that target the same Movie node.

```
MATCH (keanu:Person)-[:ACTED_IN]->(movie:Movie),
      (coActor:Person)-[:ACTED_IN]->(movie)
WHERE keanu.name = 'Keanu Reeves'
RETURN DISTINCT coActor.name;
```

You may have noticed that we used the co_actor.id <> keanu.id predicate in SQL only. This is because Neo4j will only match on the ACTED_IN relationship once in the same pattern. If this is not what we want, we can split the pattern up by using two MATCH clauses like this:

```
MATCH (keanu:Person)-[:ACTED_IN]->(movie:Movie)
MATCH (coActor:Person)-[:ACTED_IN]->(movie)
WHERE keanu.name = 'Keanu Reeves'
RETURN DISTINCT coActor.name;
```

Next, let’s find out who has both acted in and produced movies.
```
SELECT person.name
FROM person
WHERE person.id IN (SELECT person_id FROM acted_in)
  AND person.id IN (SELECT person_id FROM produced)
```

In Cypher, we use patterns as predicates in this case. That is, we require the relationships to exist, but don’t care about the connected nodes; thus the empty parentheses.

```
MATCH (person:Person)
WHERE (person)-[:ACTED_IN]->() AND (person)-[:PRODUCED]->()
RETURN person.name
```
## Aggregation

Now let’s find out a bit about the directors in movies that Keanu Reeves acted in. We want to know how many of those movies each of them directed.
```
SELECT director.name, count(*)
FROM person keanu
  JOIN acted_in ON keanu.id = acted_in.person_id
  JOIN directed ON acted_in.movie_id = directed.movie_id
  JOIN person AS director ON directed.person_id = director.id
WHERE keanu.name = 'Keanu Reeves'
GROUP BY director.name
ORDER BY count(*) DESC
```
Here’s how we’ll do the same in Cypher:

```
MATCH (keanu:Person {name: 'Keanu Reeves'})-[:ACTED_IN]->(movie:Movie),
     (director:Person)-[:DIRECTED]->(movie)
RETURN director.name, count(*)
ORDER BY count(*) DESC
```