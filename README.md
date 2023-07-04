# streamETL

Example project of a streaming pipeline in a docker environnement. the docker environnemnt includes: 
- Postgres instance
- Kafka instance
- Zookeeper instance 
- Jobmanager Flink
- Task manager Flink
- Mongodb instance
- Mongodb exporter
- Promotheus
- Grafana

The streaming Flink job aggregates the events in Kafka by windowing the events on each 10 seconds, and count only the number of insertion of new items (only the new items, not the deleted or the updated), and store them in Mongo in a collection containing the date and the result. 

Requirements
---
- Docker
- Docker compose

Run 
--- 
1. Start docker containers
    ```
    docker-compose up -d
    ```
2. Check if the containers are up, you can check the logs of a specific container
    ```
    docker logs <container name> -f 
    ```
Deployment instructions for flink job and debezium connector
--- 
1. Debezium connector requires the wal_level in postgres to be set to logical
 ```
docker-compose exec postgres psql -U dev_data
ALTER SYSTEM SET wal_level = logical;
 ```
:exclamation: Then restart the postgres service or else the the wal_level won't be set 

2. Check if the property was set properly  
 ```
docker-compose exec postgres psql -U dev_data
Show wal_level;    
 ```
3. Create a schema dev and the table users
```
CREATE SCHEMA dev;

CREATE TABLE dev.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    creation_date DATE
);

```
4. Insert a line into the table
```
INSERT INTO dev.users (name, creation_date)
VALUES
    ('John Doe', '2022-01-01');
```
:information_source: inserting the line into the table allows for the kafka topic of the debezium connector to be auto created upon posting the connector  

5. Post the debezium connector
```
docker exec -it streametl-debezium-connector-1 curl -X POST -H "Content-Type: application/json" --data @/kafka/db-config.json http://streametl-debezium-connector-1:8083/connectors
```
6. Check if the connector was posted
```
docker exec -it streametl-debezium-connector-1 curl http://streametl-debezium-connector-1:8083/connectors
```
7. Deploy the flink job on the flink cluster
```
docker exec streametl-jobmanager-1 flink run -d -c org.example.FlinkKafkaProcess /opt/flink/FlinkKafka.jar
```
8. Check the job on the web UI
```
http://localhost:8081/#/overview
```
or by command line 
```
docker exec streametl-jobmanager-1 flink list
```
Results
--- 



