+--------------+--------------+------+-----+---------------------+-------------------------------+
| Field        | Type         | Null | Key | Default             | Extra                         |
+--------------+--------------+------+-----+---------------------+-------------------------------+
| id           | int(11)      | NO   | PRI | NULL                | auto_increment                |
| title        | varchar(128) | YES  |     | NULL                |                               |
| description  | longtext     | YES  |     | NULL                |                               |
| alias        | varchar(64)  | YES  | UNI | NULL                |                               |
| sfid         | bigint(20)   | NO   | UNI | NULL                |                               |
| category_id  | int(11)      | YES  | MUL | NULL                |                               |
| run_policy   | int(11)      | YES  |     | NULL                |                               |
| auth_policy  | tinyint(4)   | NO   |     | NULL                |                               |
| details      | longtext     | YES  |     | NULL                |                               |
| status       | int(11)      | YES  |     | NULL                |                               |
| date_created | timestamp    | NO   |     | current_timestamp() |                               |
| date_updated | timestamp    | NO   |     | current_timestamp() | on update current_timestamp() |
| conditions   | longtext     | YES  |     | NULL                |                               |
+--------------+--------------+------+-----+---------------------+-------------------------------+