+---------------------------+--------------+------+-----+---------------------+----------------+
| Field                     | Type         | Null | Key | Default             | Extra          |
+---------------------------+--------------+------+-----+---------------------+----------------+
| id                        | int(11)      | NO   | PRI | NULL                | auto_increment |
| email                     | varchar(180) | NO   | UNI | NULL                |                |
| sfid                      | bigint(20)   | NO   | UNI | NULL                |                |
| enabled                   | int(11)      | NO   |     | 0                   |                |
| salt                      | varchar(255) | YES  |     | NULL                |                |
| password                  | varchar(255) | NO   |     | NULL                |                |
| last_login                | timestamp    | YES  |     | NULL                |                |
| confirmation_token        | varchar(180) | YES  | UNI | NULL                |                |
| password_requested_at     | timestamp    | YES  |     | NULL                |                |
| roles                     | longtext     | NO   |     | NULL                |                |
| phone                     | varchar(255) | YES  |     | NULL                |                |
| region                    | varchar(255) | YES  |     | NULL                |                |
| first_name                | varchar(255) | YES  | MUL | NULL                |                |
| last_name                 | varchar(255) | YES  |     | NULL                |                |
| owner_url                 | varchar(174) | YES  | UNI | NULL                |                |
| address                   | varchar(255) | YES  |     | NULL                |                |
| city                      | varchar(255) | YES  |     | NULL                |                |
| country                   | varchar(3)   | YES  |     | NULL                |                |
| post_number               | varchar(16)  | YES  |     | NULL                |                |
| provider                  | varchar(32)  | YES  |     | NULL                |                |
| date_created              | timestamp    | NO   |     | 0000-00-00 00:00:00 |                |
| date_updated              | timestamp    | NO   |     | current_timestamp() |                |
| key_date                  | timestamp    | YES  |     | NULL                |                |
| confirmed                 | int(11)      | NO   |     | 0                   |                |
| terms_accepted            | int(11)      | NO   |     | 0                   |                |
| verified                  | int(11)      | NO   |     | 0                   |                |
| verified_name             | varchar(255) | YES  |     | NULL                |                |
| googleAuthenticatorSecret | varchar(255) | YES  |     | NULL                |                |
| auth_code                 | int(11)      | YES  |     | NULL                |                |
+---------------------------+--------------+------+-----+---------------------+----------------+

+--------------+--------------+------+-----+---------+----------------+
| Field        | Type         | Null | Key | Default | Extra          |
+--------------+--------------+------+-----+---------+----------------+
| id           | int(11)      | NO   | PRI | NULL    | auto_increment |
| user_id      | int(11)      | YES  | MUL | NULL    |                |
| name         | varchar(128) | NO   | MUL | NULL    |                |
| value        | longtext     | NO   |     | NULL    |                |
| date_updated | datetime     | NO   |     | NULL    |                |
+--------------+--------------+------+-----+---------+----------------+