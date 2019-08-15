use mysql;
create database test;
use test;
create table user
(
    id int auto_increment primary key,
    username varchar(64) unique not null,
    password varchar(128) not null,
);
insert into user values( 'sunny','123456');
