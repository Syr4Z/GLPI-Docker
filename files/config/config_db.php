<?php
class DB extends DBmysql {
   public $dbhost = "#DBHOST#";
   public $dbport = "#DBPORT#";
   public $dbuser = "#DBUSER#";
   public $dbpassword = "#DBPASSWORD#";
   public $dbdefault = "#DBDEFAULT#";
   public $use_utf8mb4 = true;
   public $allow_myisam = false;
   public $allow_datetime = false;
   public $allow_signed_keys = false;
}